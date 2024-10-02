import 'package:flutter/material.dart';
import 'package:phrasewalk/data/load.dart';
import 'package:phrasewalk/game_widgets/grid.dart';
import 'package:phrasewalk/utility/debug.dart';
import '../data/puzzle.dart';

enum SolutionState { unsolved, solved, failed }

class PhraseInteraction {
  PhraseInteraction({
    required this.tailDown,
    required this.tailRight,
  });

  PhraseTail tailDown;
  PhraseTail tailRight;

  bool get interactsDown => !tailDown.isEmpty;
  bool get interactsRight => !tailRight.isEmpty;

  static PhraseInteraction get none =>
      PhraseInteraction(tailDown: PhraseTail.none, tailRight: PhraseTail.none);

  @override
  String toString() => '(down: $tailDown, right: $tailRight)';
}

class GameState extends ChangeNotifier {
  DateTime loadedDate = DateTime.fromMillisecondsSinceEpoch(0);
  Puzzle loadedPuzzle = Puzzle.empty();

  List<String> _wordBankState = [];
  List<String> _gridState = [];
  List<PhraseInteraction> interactionState = [];
  bool isSolved = false;

  String wordOn(GridPosition position) {
    if (position.isWordBank) {
      return _wordBankState[position.index];
    }
    return _gridState[position.index];
  }

  Future<void> prepare([DateTime? date]) async {
    debug("Preparing for $date");
    loadedDate = date ?? DateTime.now();
    debug("Loading puzzle for $loadedDate");
    loadedPuzzle = await Load.puzzleForDate(loadedDate);
    debug("Loaded puzzle $loadedPuzzle");
    _wordBankState = loadedPuzzle.words;
    _wordBankState.shuffle();
    debug("Shuffled words: $_wordBankState");
    _gridState = List.generate(loadedPuzzle.grid.length, (_) => '');
    interactionState =
        List.generate(loadedPuzzle.grid.length, (_) => PhraseInteraction.none);
    notifyListeners();
  }

  void reportDrop(GridPosition destination, GridPosition source) {
    var sourceList = source.isWordBank ? _wordBankState : _gridState;
    var destinationList = destination.isWordBank ? _wordBankState : _gridState;

    final temp = sourceList[source.index];
    sourceList[source.index] = destinationList[destination.index];
    destinationList[destination.index] = temp;

    updateState({
      if (!destination.isWordBank) destination.index,
      if (!source.isWordBank) source.index
    }.toList());
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

    isSolved = checkWin();
    notifyListeners();
  }

  void recalculateInteractions(List<int> modifiedIndices) {
    for (var index in modifiedIndices) {
      var (up, left, right, down) = loadedPuzzle.getSurrounding(index);

      if (right >= 0) {
        interactionState[index].tailRight = doesInteract(index, right);
      }
      if (down >= 0) {
        interactionState[index].tailDown = doesInteract(index, down);
      }
      if (left >= 0) {
        interactionState[left].tailRight = doesInteract(left, index);
      }
      if (up >= 0) {
        interactionState[up].tailDown = doesInteract(up, index);
      }
    }
  }

  PhraseTail doesInteract(int a, int b) =>
      Load.isValidPhrase(_gridState[a], _gridState[b]);

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
    return true;
  }
}