import 'dart:math';

import '../data/load.dart';
import '../data/tail.dart';
import 'puzzle_interface.dart';

enum TileData { empty, filled, wallRight, wallDown, wallBoth }

class Puzzle implements PuzzleInterface {
  Puzzle(
      {required this.words,
      required this.columns,
      required this.grid,
      this.author,
      this.bundledInteractions});

  final List<String> words;
  final int columns;
  final List<TileData> grid;

  final String? author;
  final PhraseMap? bundledInteractions;

  bool get isEmpty => words.isEmpty;

  factory Puzzle.empty() => Puzzle(
        words: [],
        columns: 0,
        grid: [],
      );

  factory Puzzle.demo() {
    const grid = "0d000f";
    return Puzzle(
      words: ['center', 'stage', 'fright', 'field', 'day'],
      columns: 3,
      grid: _parseGrid(grid),
      bundledInteractions: {
        'center': [Tail.from('stage'), Tail.from('field')],
        'stage': [Tail.from('fright')],
        'field': [Tail.from('day')],
      },
      author: "The Tutorializer",
    );
  }

  factory Puzzle.fromFirebase(Map<String, dynamic> data) {
    final gridData = data['grid'].split(',');
    return Puzzle(
      words: List<String>.from(data['words']),
      columns: int.parse(gridData[0]),
      grid: _parseGrid(gridData[1]),
      author: data.containsKey('author') ? data['author'] : null,
    );
  }

  static List<TileData> _parseGrid(String gridString) {
    return gridString.replaceAll(' ', '').split('').map((e) {
      switch (e) {
        case '0':
          return TileData.empty;
        case 'f':
          return TileData.filled;
        case 'r':
          return TileData.wallRight;
        case 'd':
          return TileData.wallDown;
        case 'b':
          return TileData.wallBoth;
      }
      throw Exception('Unknown GridTile: $e');
    }).toList();
  }

  @override
  String toString() {
    return 'Puzzle{words: $words, columns: $columns}';
  }

  bool isBlocked(int index) {
    if (index < 0) return false;
    return grid[index] == TileData.filled;
  }

  bool isDownWallBetween(int top, int bottom) {
    final minIndex = min(top, bottom);
    if (minIndex < 0) return false;
    return grid[minIndex] == TileData.wallDown ||
        grid[minIndex] == TileData.wallBoth;
  }

  bool isRightWallBetween(int left, int right) {
    final minIndex = min(left, right);
    if (minIndex < 0) return false;
    return grid[minIndex] == TileData.wallRight ||
        grid[minIndex] == TileData.wallBoth;
  }

  int _getAdjacent(int index, int offset, bool Function(int, int) isWallBetween,
      bool isEdge) {
    var res = isEdge ? -1 : index + offset;
    if (isBlocked(res) || isWallBetween(index, res)) res = -1;
    return res;
  }

  int getUp(int index) =>
      _getAdjacent(index, -columns, isDownWallBetween, index < columns);

  int getLeft(int index) =>
      _getAdjacent(index, -1, isRightWallBetween, index % columns == 0);

  int getRight(int index) =>
      _getAdjacent(index, 1, isRightWallBetween, (index + 1) % columns == 0);

  int getDown(int index) => _getAdjacent(
      index, columns, isDownWallBetween, index >= grid.length - columns);

  (int up, int left, int right, int down) getSurrounding(int index) {
    return (
      getUp(index),
      getLeft(index),
      getRight(index),
      getDown(index),
    );
  }

  (int right, int down) getRightDown(int index) {
    return (
      getRight(index),
      getDown(index),
    );
  }
}
