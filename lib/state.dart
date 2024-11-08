import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phrazy/data/tail.dart';
import '../data/load.dart';
import '../game_widgets/grid.dart';
import '../sound.dart';
import '../utility/ext.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../data/puzzle.dart';

enum SolutionState { unsolved, solved, failed }

class PhraseInteraction {
  PhraseInteraction({
    required this.tailDown,
    required this.tailRight,
  });

  PhraseTail tailDown;
  PhraseTail tailRight;

  bool get interactsDown => tailDown.isValid;
  bool get interactsRight => tailRight.isValid;

  static PhraseInteraction get empty => PhraseInteraction(
      tailDown: PhraseTail.empty, tailRight: PhraseTail.empty);

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
  List<PhraseInteraction> interactionState = [];
  bool isSolved = false;
  bool shouldCelebrateWin = false;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  StopWatchTimer timer = StopWatchTimer();

  void recordTime() {
    Load.saveTimeForDate(
      TimerState(
        time: timer.rawTime.value,
        isSolved: isSolved,
      ),
      loadedDate.toYMD,
    );
  }

  String wordOn(GridPosition position) {
    if (position.isWordBank) {
      return _wordBankState[position.index];
    }
    return _gridState[position.index];
  }

  void togglePause(bool value) {
    _isPaused = value;
    notifyListeners();
  }

  Future<void> prepare([DateTime? date]) async {
    await loadSounds();

    if (kDebugMode) {
      loadedDate = DateTime.fromMillisecondsSinceEpoch(0);
      await Future.delayed(Durations.medium1);
      loadedPuzzle = Puzzle.demo();
    } else {
      // debug("Loading puzzle for $loadedDate");
      loadedDate = date ?? DateTime.now();
      loadedPuzzle = await Load.puzzleForDate(loadedDate);
    }

    // debug("Loaded puzzle $loadedPuzzle");
    _wordBankState = loadedPuzzle.words;
    _wordBankState.shuffle();

    _gridState = List.generate(loadedPuzzle.grid.length, (_) => '');
    interactionState =
        List.generate(loadedPuzzle.grid.length, (_) => PhraseInteraction.empty);
    isSolved = false;

    BoardState? state;
    if (kDebugMode) {
      state = null;
    } else {
      state = Load.loadBoardForDate(loadedDate.toYMD);
    }

    final wordsChanged =
        state == null ? false : !state.allWords().isSameAs(loadedPuzzle.words);
    if (state != null && !wordsChanged) {
      _gridState = state.grid;
      _wordBankState = state.wordBank;
    }

    timer.onResetTimer();
    var time = Load.loadTimeForDate(loadedDate.toYMD);
    if (time != null && !wordsChanged) {
      timer.setPresetTime(mSec: time.time, add: false);
      isSolved = time.isSolved;
    } else {
      timer.setPresetTime(mSec: 0, add: false);
      isSolved = false;
    }
    if (!isSolved) timer.onStartTimer();

    recalculateInteractions(List.generate(_gridState.length, (i) => i));

    shouldCelebrateWin = false;
    isSolved = checkWin();
    notifyListeners();
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

    recordTime();
    Load.saveBoardForDate(
      BoardState(wordBank: _wordBankState, grid: _gridState),
      loadedDate.toYMD,
    );
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
    notifyListeners();
  }

  void recalculateInteractions(List<int> modifiedIndices) {
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

    if (playLinkSound) {
      playSound("link");
    }
  }

  PhraseTail doesInteract(int a, int b) =>
      Load.isValidPhrase(_gridState[a], _gridState[b]);

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

    if (shouldCelebrate) {
      playSound("win");
      confetti.play();
      shouldCelebrateWin = true;
    }
    return true;
  }
}
