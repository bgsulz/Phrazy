import 'package:flutter/material.dart';
import 'package:phrazy/data/web_storage.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:confetti/confetti.dart';

import '../../data/phrasetail.dart';
import '../../game_widgets/grid_position.dart';
import '../../data/load.dart';
import '../../sound.dart';
import '../../utility/ext.dart';
import '../../data/puzzle.dart';

enum SolutionState { unsolved, solved, failed }

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

  List<String> _wordBankState = [];
  List<String> _gridState = [];
  List<Interaction> interactionState = [];

  bool isSolved = false;
  bool shouldCelebrateWin = false;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  bool _isPreparing = false;
  bool get isPreparing => _isPreparing;

  StopWatchTimer timer = StopWatchTimer();

  void recordTime() {
    final time = timer.rawTime.value;
    WebStorage.saveTimeForDate(
      TimerState(
        time: time,
        isSolved: isSolved,
      ),
      loadedDate.toYMD,
    );
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
    if (!loadedPuzzle.isEmpty && !isSolved) recordTime();
    timer.onStopTimer();

    _isPreparing = true;

    await loadSounds();

    if (puzzle != null) {
      loadedDate = DateTime.fromMillisecondsSinceEpoch(0);
      loadedPuzzle = await Load.puzzle(puzzle);
    } else {
      loadedDate =
          date?.copyWith(hour: 12) ?? DateTime.now().copyWith(hour: 12);
      loadedPuzzle = await Load.puzzleForDate(loadedDate);
    }

    _wordBankState = loadedPuzzle.words;
    _wordBankState.shuffle();

    _gridState = List.generate(loadedPuzzle.grid.length, (_) => '');
    interactionState =
        List.generate(loadedPuzzle.grid.length, (_) => Interaction.empty);
    isSolved = false;

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
      isSolved = time.isSolved;
    } else {
      timer.setPresetTime(mSec: 0, add: false);
      isSolved = false;
    }
    recordTime();

    if (!isSolved) timer.onStartTimer();

    recalculateInteractions(List.generate(_gridState.length, (i) => i),
        isFirstTime: true);

    if (!isSolved) {
      shouldCelebrateWin = false;
      isSolved = checkWin();
    }

    _isPreparing = false;
    notifyListeners();
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

    isSolved = checkWin(shouldCelebrate: true);
    recordTime();
    WebStorage.saveBoardForDate(
      BoardState(wordBank: _wordBankState, grid: _gridState),
      loadedDate.toYMD,
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

    if (!isFirstTime && playLinkSound) {
      playSound("link");
    }
  }

  bool checkWin({bool shouldCelebrate = false}) {
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
    recordTime();

    if (shouldCelebrate) {
      playSound("win");
      confetti.play();
      shouldCelebrateWin = true;
    }
    return true;
  }
}
