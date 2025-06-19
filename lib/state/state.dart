import 'package:phrazy/core/ext_ymd.dart';
import 'package:phrazy/stats/t_digest.dart';
import 'package:phrazy/utility/debug.dart';
import 'package:phrazy/utility/events.dart';

import '../data/web_storage/board_save.dart';
import '../data/web_storage/timer_save.dart';
import '../data/web_storage/web_storage.dart';
import '../data/tail.dart';
import '../../game_widgets/grid_position.dart';
import '../../data/load.dart';
import '../../sound.dart';
import '../../utility/ext.dart';
import '../../data/puzzle.dart';

import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:confetti/confetti.dart';

enum SolutionState { unsolved, solved, failed }

enum GameLifecycleState { preparing, error, puzzle, solved }

class StatsBlock {
  bool isInitialized = false;
  double cdf;

  StatsBlock({required this.cdf});

  factory StatsBlock.empty() {
    return StatsBlock(cdf: -1);
  }

  void initialize(TDigest digest, double timeSeconds) {
    cdf = digest.size > 5 ? digest.cdf(timeSeconds) : -1;
    debug("CDF tested against $timeSeconds, set to $cdf");
    isInitialized = true;
  }

  @override
  String toString() {
    if (!isInitialized) return "";

    final cdfString = cdf >= 0
        ? "Faster than ${((1 - cdf) * 100).toStringAsFixed(1)} % of players!"
        : "You're one of the first to solve this Phrazy!";
    return cdfString;
  }
}

class Interaction {
  Interaction({
    this.tailDown = Tail.empty,
    this.tailRight = Tail.empty,
  });

  Tail tailDown;
  Tail tailRight;

  bool get interactsDown => tailDown.isValid;
  bool get interactsRight => tailRight.isValid;

  static Interaction get empty =>
      Interaction(tailDown: Tail.empty, tailRight: Tail.empty);

  @override
  String toString() => '(down: $tailDown, right: $tailRight)';
}

class GameState extends ChangeNotifier {
  final ConfettiController confetti =
      ConfettiController(duration: Durations.long1);

  DateTime loadedDate = DateTime.fromMillisecondsSinceEpoch(0);
  Puzzle loadedPuzzle = Puzzle.empty();
  StatsBlock statsBlock = StatsBlock.empty();

  List<String> _wordBankState = [];
  List<String> _gridState = [];
  List<String> activeConnections = [];
  List<Interaction> interactionState = [];

  GameLifecycleState currentState = GameLifecycleState.preparing;

  bool get isSolved => currentState == GameLifecycleState.solved;
  bool shouldCelebrateWin = false;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  bool get isPreparing => currentState == GameLifecycleState.preparing;
  bool get isError => currentState == GameLifecycleState.error;

  StopWatchTimer timer = StopWatchTimer();
  int get time => timer.rawTime.value;

  void recordTime({int? overrideTime}) {
    final currentTime = overrideTime ?? timer.rawTime.value;

    WebStorage.saveTimeForDate(
      TimerSave(
        time: currentTime,
        isSolved: isSolved,
      ),
      loadedDate.toYMD,
    );
  }

  Future<void> loadStats({int? overrideTime, bool shouldAdd = false}) async {
    final currentTime = overrideTime ?? timer.rawTime.value;
    final timeSeconds = currentTime / 1000.0;

    var digest = await Load.digest(loadedDate);

    statsBlock.initialize(digest, timeSeconds);
    notifyListeners();

    if (shouldAdd) {
      debug("ADDING TO T-DIGEST!");
      digest.add(timeSeconds);
      Load.saveDigest(digest, loadedDate);
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

  Future prepare({DateTime? date, Puzzle? puzzle}) async {
    if (!loadedPuzzle.isEmpty && !isSolved) {
      // debug("Saving time on the way out.");
      recordTime();
    }
    timer.onStopTimer();

    currentState = GameLifecycleState.preparing;

    if (puzzle != null) {
      loadedDate = DateTime.fromMillisecondsSinceEpoch(0);
      loadedPuzzle = await Load.puzzle(puzzle);
    } else {
      loadedDate =
          date?.copyWith(hour: 12) ?? DateTime.now().copyWith(hour: 12);
      final load = Load(
          dailiesCollectionName: "dailies", puzzlesCollectionName: "puzzles");
      loadedPuzzle = await load.puzzleForDate(loadedDate);
    }

    // debug("Loaded puzzle");

    if (loadedPuzzle.isEmpty) {
      debug("It's empty...!");
      currentState = GameLifecycleState.error;
      notifyListeners();
      return;
    }

    _wordBankState = loadedPuzzle.words;
    _wordBankState.shuffle();

    _gridState = List.generate(loadedPuzzle.grid.length, (_) => '');
    interactionState =
        List.generate(loadedPuzzle.grid.length, (_) => Interaction.empty);
    currentState = GameLifecycleState.puzzle;

    var state = WebStorage.loadBoardForDate(loadedDate.toYMD);

    final wordsChanged =
        state == null ? false : !state.allWords().isSameAs(loadedPuzzle.words);
    if (state != null && !wordsChanged) {
      _gridState = state.grid;
      _wordBankState = state.wordBank;
    }

    timer.onResetTimer();
    var time = WebStorage.loadTimeForDate(loadedDate.toYMD);
    if (time != null && !wordsChanged) {
      timer.setPresetTime(mSec: time.time, add: false);
      if (time.isSolved) {
        currentState = GameLifecycleState.solved;
        loadStats(overrideTime: time.time);
      }
    } else {
      timer.setPresetTime(mSec: 0, add: false);
    }

    recalculateInteractions(List.generate(_gridState.length, (i) => i),
        isFirstTime: true);

    shouldCelebrateWin = false;
    if (!isSolved && checkWin()) {
      currentState = GameLifecycleState.solved;
    }
    if (time != null && isSolved && !time.isSolved) {
      _handleWinAchieved();
      timer.setPresetTime(mSec: time.time, add: false);
      recordTime(overrideTime: time.time);
    }
    if (!isSolved) timer.onStartTimer();

    notifyListeners();
  }

  void acknowledgeWinCelebration() {
    shouldCelebrateWin = false;
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
    reportDrop(
        GridPosition(index: firstWordBankIndex, isWordBank: true), source);
  }

  void updateState(List<int> modifiedIndices) {
    recalculateInteractions(modifiedIndices);

    final bool wasPuzzleState = currentState == GameLifecycleState.puzzle;
    if (wasPuzzleState && checkWin()) {
      _handleWinAchieved();
      _playWinEffects();
    }
    // debug("Saving time in response to updated state.");
    recordTime();
    WebStorage.saveBoardForDate(
      BoardSave(wordBank: _wordBankState, grid: _gridState),
      loadedDate.toYMD, // This line still has the toYMD error in load.dart
    );
    notifyListeners();
  }

  Tail doesInteract(int a, int b) =>
      Load.isValidPhrase(_gridState[a], _gridState[b]);

  void recalculateInteractions(List<int> modifiedIndices,
      {bool isFirstTime = false}) {
    bool playLinkSound = false;
    for (var index in modifiedIndices) {
      var (up, left, right, down) = loadedPuzzle.getSurrounding(index);

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

    activeConnections = interactionState.expand((x) {
      return [
        if (x.tailDown.isValid) x.tailDown.connector,
        if (x.tailRight.isValid) x.tailRight.connector
      ];
    }).toList();

    if (!isFirstTime && playLinkSound) {
      playSound("link");
    }
  }

  bool checkWin() {
    if (_wordBankState.any((s) => s.isNotEmpty)) {
      return false;
    }
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

  void _playWinEffects() {
    confetti.play();
    shouldCelebrateWin = true;
    playSound("win");
  }

  void _handleWinAchieved() {
    currentState = GameLifecycleState.solved;
    Events.logWin(date: loadedDate);
    loadStats(shouldAdd: true);
  }
}
