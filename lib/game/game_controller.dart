import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:phrazy/data/interaction.dart';
import 'package:phrazy/data/loaded_game_data.dart';
import 'package:phrazy/game/stats_block.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'package:phrazy/data/game_repository.dart';
import 'package:phrazy/data/puzzle.dart';
import 'package:phrazy/data/tail.dart';
import 'package:phrazy/data/web_storage/board_save.dart';
import 'package:phrazy/data/web_storage/timer_save.dart';
import 'package:phrazy/game/phrase_validator.dart';
import 'package:phrazy/game_widgets/grid_position.dart';
import 'package:phrazy/sound.dart';
import 'package:phrazy/utility/debug.dart';
import 'package:phrazy/utility/events.dart';

enum GameLifecycleState { preparing, error, puzzle, solved }

class GameController extends ChangeNotifier {
  final GameRepository _repository;

  // Constructor
  GameController({required GameRepository repository})
      : _repository = repository;

  // UI and Effects State
  final ConfettiController confetti =
      ConfettiController(duration: Durations.long1);
  final _winEventController = StreamController<void>.broadcast();
  Stream<void> get onWin => _winEventController.stream;
  final StopWatchTimer timer = StopWatchTimer();

  // Game State
  GameLifecycleState currentState = GameLifecycleState.preparing;
  DateTime loadedDate = DateTime.fromMillisecondsSinceEpoch(0);
  Puzzle loadedPuzzle = Puzzle.empty();
  StatsBlock statsBlock = StatsBlock.empty();
  late PhraseValidator _validator;

  List<String> _wordBankState = [];
  List<String> _gridState = [];
  List<Interaction> interactionState = [];
  List<String> activeConnections = [];
  bool _isPaused = false;

  // Getters
  bool get isSolved => currentState == GameLifecycleState.solved;
  bool get isPaused => _isPaused;
  bool get isPreparing => currentState == GameLifecycleState.preparing;
  bool get isError => currentState == GameLifecycleState.error;
  int get time => timer.rawTime.value;
  List<String> get wordBank => _wordBankState;
  List<String> get grid => _gridState;

  // Core Game Logic

  Future<void> prepare({DateTime? date, Puzzle? puzzle}) async {
    confetti.stop();
    if (!loadedPuzzle.isEmpty && !isSolved) {
      recordTime();
    }
    timer.onStopTimer();
    currentState = GameLifecycleState.preparing;
    notifyListeners();

    // DELEGATED: All loading logic is now in the repository
    final LoadedGameData data;
    if (puzzle != null) {
      // Handle demo/special puzzles
      loadedDate = DateTime.fromMillisecondsSinceEpoch(0);
      _validator = await _repository
          .loadGameDataForPuzzle(puzzle)
          .then((d) => d.validator);
      data = LoadedGameData(puzzle: puzzle, validator: _validator);
    } else {
      loadedDate =
          date?.copyWith(hour: 12) ?? DateTime.now().copyWith(hour: 12);
      data = await _repository.loadGameDataByDate(loadedDate);
    }

    if (data.isError) {
      currentState = GameLifecycleState.error;
      notifyListeners();
      return;
    }

    // Populate state from the loaded data object
    loadedPuzzle = data.puzzle;
    _validator = data.validator;

    _gridState = data.savedBoard?.grid ??
        List.generate(loadedPuzzle.grid.length, (_) => '');
    _wordBankState =
        data.savedBoard?.wordBank ?? (List.from(loadedPuzzle.words)..shuffle());
    interactionState =
        List.generate(loadedPuzzle.grid.length, (_) => Interaction.empty);

    timer.onResetTimer();
    if (data.savedTime != null) {
      timer.setPresetTime(mSec: data.savedTime!.time, add: false);
      if (data.savedTime!.isSolved) {
        currentState = GameLifecycleState.solved;
        loadStats(overrideTime: data.savedTime!.time);
      }
    }

    recalculateInteractions(List.generate(_gridState.length, (i) => i),
        isFirstTime: true);

    if (!isSolved && checkWin()) {
      _handleWinAchieved();
    } else if (isSolved && data.savedTime?.isSolved == false) {
      // This case handles loading a game that is now solved but wasn't saved as such
      _handleWinAchieved();
      recordTime(overrideTime: data.savedTime!.time);
    }

    if (currentState != GameLifecycleState.solved) {
      currentState = GameLifecycleState.puzzle;
      timer.onStartTimer();
    }

    notifyListeners();
  }

  void updateState(List<int> modifiedIndices) {
    recalculateInteractions(modifiedIndices);

    if (currentState == GameLifecycleState.puzzle && checkWin()) {
      debug("looks like a new win!");
      _handleWinAchieved();
      _playWinEffects();
    }

    recordTime();
    _repository.saveBoard(
      BoardSave(wordBank: _wordBankState, grid: _gridState),
      loadedDate,
    );
    notifyListeners();
  }

  void recalculateInteractions(List<int> modifiedIndices,
      {bool isFirstTime = false}) {
    bool playLinkSound = false;
    for (var index in modifiedIndices) {
      var (up, left, right, down) = loadedPuzzle.getSurrounding(index);

      // REFACTORED: Uses the injected validator instance
      Tail doesInteract(int a, int b) =>
          _validator.validate(_gridState[a], _gridState[b]);

      if (right >= 0) {
        var interaction = doesInteract(index, right);
        interactionState[index].tailRight = interaction;
        playLinkSound = playLinkSound || interaction.isValid;
      }
      if (down >= 0) {
        var interaction = doesInteract(index, down);
        interactionState[index].tailDown = interaction;
        playLinkSound = playLinkSound || interaction.isValid;
      }
      if (left >= 0) {
        var interaction = doesInteract(left, index);
        interactionState[left].tailRight = interaction;
        playLinkSound = playLinkSound || interaction.isValid;
      }
      if (up >= 0) {
        var interaction = doesInteract(up, index);
        interactionState[up].tailDown = interaction;
        playLinkSound = playLinkSound || interaction.isValid;
      }
    }

    activeConnections = interactionState
        .expand((x) => [
              if (x.tailDown.isValid) x.tailDown.connector,
              if (x.tailRight.isValid) x.tailRight.connector
            ])
        .toList();

    if (!isFirstTime && playLinkSound) {
      playSound("link");
    }
  }

  bool checkWin() {
    if (_wordBankState.any((s) => s.isNotEmpty)) return false;

    for (var i = 0; i < _gridState.length; i++) {
      if (loadedPuzzle.grid[i] == TileData.filled) continue;
      var (right, down) = loadedPuzzle.getRightDown(i);
      if (right >= 0 &&
          _gridState[right].isNotEmpty &&
          !interactionState[i].interactsRight) {
        return false;
      }
      if (down >= 0 &&
          _gridState[down].isNotEmpty &&
          !interactionState[i].interactsDown) {
        return false;
      }
    }
    timer.onStopTimer();
    return true;
  }

  // User Actions

  void reportDrop(GridPosition destination, GridPosition source) {
    if (isSolved) return;
    var sourceList = source.isWordBank ? _wordBankState : _gridState;
    var destinationList = destination.isWordBank ? _wordBankState : _gridState;

    final temp = sourceList[source.index];
    sourceList[source.index] = destinationList[destination.index];
    destinationList[destination.index] = temp;

    updateState({
      if (!destination.isWordBank) destination.index,
      if (!source.isWordBank) source.index
    }.toList());
    playSound("drop");
  }

  void reportClicked(GridPosition source) {
    if (source.isWordBank) {
      for (var i = 0; i < _gridState.length; i++) {
        if (_gridState[i].isEmpty && loadedPuzzle.grid[i] != TileData.filled) {
          reportDrop(GridPosition(index: i, isWordBank: false), source);
          return;
        }
      }
    }
    var firstWordBankIndex = _wordBankState.indexWhere((e) => e.isEmpty);
    if (firstWordBankIndex != -1) {
      reportDrop(
          GridPosition(index: firstWordBankIndex, isWordBank: true), source);
    }
  }

  void clearBoard() {
    var modifiedIndices = <int>[];
    for (var i = 0; i < _gridState.length; i++) {
      if (_gridState[i].isNotEmpty) {
        modifiedIndices.add(i);
        for (var j = 0; j < _wordBankState.length; j++) {
          if (_wordBankState[j].isEmpty) {
            _wordBankState[j] = _gridState[i];
            _gridState[i] = '';
            break;
          }
        }
      }
    }
    updateState(modifiedIndices);
    playSound("drop");
  }

  // Helper & Private Methods

  void recordTime({int? overrideTime}) {
    final currentTime = overrideTime ?? timer.rawTime.value;
    _repository.saveTime(
      TimerSave(time: currentTime, isSolved: isSolved),
      loadedDate,
    );
  }

  Future<void> loadStats({int? overrideTime, bool shouldAdd = false}) async {
    final currentTime = overrideTime ?? timer.rawTime.value;
    final timeSeconds = currentTime / 1000.0;

    var digest = await _repository.getDigest(loadedDate);
    statsBlock.initialize(digest, timeSeconds);
    notifyListeners();

    if (shouldAdd) {
      debug("ADDING TO T-DIGEST!");
      digest.add(timeSeconds);
      _repository.saveDigest(digest, loadedDate);
    }
  }

  String wordAtPosition(GridPosition position) {
    if (position.isWordBank) {
      return _wordBankState[position.index];
    }
    return _gridState[position.index];
  }

  void togglePause(bool value) {
    _isPaused = value;
    notifyListeners();
  }

  void _playWinEffects() {
    _winEventController.add(null);
    playSound("win");
  }

  void _handleWinAchieved() {
    currentState = GameLifecycleState.solved;
    Events.logWin(date: loadedDate);
    loadStats(shouldAdd: true);
  }

  @override
  void dispose() {
    _winEventController.close();
    timer.dispose();
    confetti.dispose();
    super.dispose();
  }
}
