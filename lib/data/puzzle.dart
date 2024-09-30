enum TileData { empty, filled, wallRight, wallDown, wallBoth }

class Puzzle {
  Puzzle({
    required this.words,
    required this.columns,
    required this.grid,
  });

  final List<String> words;
  final int columns;
  final List<TileData> grid;

  factory Puzzle.empty() => Puzzle(
        words: [],
        columns: 0,
        grid: [],
      );

  factory Puzzle.demo() {
    const grid = "0000f0000";
    return Puzzle(
      words: ['lemon', 'head', 'count', 'bar', 'out', 'fly', 'wheel', 'house'],
      columns: 3,
      grid: _parseGrid(grid),
    );
  }

  factory Puzzle.fromFirebase(Map<String, dynamic> data) {
    final gridData = data['grid'].split(',');
    return Puzzle(
      words: List<String>.from(data['words']),
      columns: int.parse(gridData[0]),
      grid: _parseGrid(gridData[1]),
    );
  }

  static List<TileData> _parseGrid(String gridString) {
    return gridString.split('').map((e) {
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
    if (top < 0 || bottom < 0) return false;
    return grid[top] == TileData.wallDown || grid[top] == TileData.wallBoth;
  }

  bool isRightWallBetween(int left, int right) {
    if (left < 0 || right < 0) return false;
    return grid[left] == TileData.wallRight || grid[left] == TileData.wallBoth;
  }

  bool isAtTop(int index) => index < columns;
  bool isAtBottom(int index) => index >= grid.length - columns;
  bool isAtLeft(int index) => index % columns == 0;
  bool isAtRight(int index) => (index + 1) % columns == 0;

  int getUp(int index) {
    var res = isAtTop(index) ? -1 : index - columns;
    if (isBlocked(res) || isDownWallBetween(res, index)) res = -1;
    return res;
  }

  int getLeft(int index) {
    var res = isAtLeft(index) ? -1 : index - 1;
    if (isBlocked(res) || isRightWallBetween(res, index)) res = -1;
    return res;
  }

  int getRight(int index) {
    var res = isAtRight(index) ? -1 : index + 1;
    if (isBlocked(res) || isRightWallBetween(index, res)) res = -1;
    return res;
  }

  int getDown(int index) {
    var res = isAtBottom(index) ? -1 : index + columns;
    if (isBlocked(res) || isDownWallBetween(index, res)) res = -1;
    return res;
  }

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
