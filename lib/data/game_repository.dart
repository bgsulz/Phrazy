import 'package:phrazy/data/loaded_game_data.dart';
import 'package:phrazy/data/local_data_source.dart';
import 'package:phrazy/data/puzzle.dart';
import 'package:phrazy/data/remote_data_source.dart';
import 'package:phrazy/data/web_storage/board_save.dart';
import 'package:phrazy/data/web_storage/timer_save.dart';
import 'package:phrazy/stats/t_digest.dart';
import 'package:phrazy/utility/ext.dart';

class GameRepository {
  final RemoteDataSource _remote;
  final LocalDataSource _local;

  GameRepository(
      {required RemoteDataSource remote, required LocalDataSource local})
      : _remote = remote,
        _local = local;

  /// Orchestrates loading all necessary data for a game on a specific date.
  Future<LoadedGameData> loadGameDataByDate(DateTime date) async {
    // Renamed for clarity
    // 1. Fetch puzzle structure from remote
    final puzzle = await _remote.fetchPuzzleForDate(date);
    if (puzzle.isEmpty) {
      return LoadedGameData.error("Could not load puzzle for this date.");
    }

    // 2. Fetch phrase validator for this specific puzzle
    final validator = await _remote.fetchPhraseValidator(puzzle);

    // 3. Load progress from local storage
    final boardSave = _local.loadBoardForDate(date);
    final timerSave = _local.loadTimeForDate(date);

    // 4. Validate that the local save matches the remote puzzle words
    final bool isSaveValid =
        boardSave != null && !boardSave.allWords().isSameAs(puzzle.words);

    return LoadedGameData(
      puzzle: puzzle,
      validator: validator,
      savedBoard: isSaveValid ? null : boardSave,
      savedTime: isSaveValid ? null : timerSave,
    );
  }

  /// **NEW METHOD**: Creates game data for a pre-existing puzzle object (e.g., a demo).
  /// This path skips remote puzzle fetching and local storage loading.
  Future<LoadedGameData> loadGameDataForPuzzle(Puzzle puzzle) async {
    // Only fetch the validator, as the puzzle is already provided.
    final validator = await _remote.fetchPhraseValidator(puzzle);

    return LoadedGameData(
      puzzle: puzzle,
      validator: validator,
      // No saved board or time for demos.
      savedBoard: null,
      savedTime: null,
    );
  }

  // Delegated Methods

  void saveBoard(BoardSave board, DateTime date) {
    // Don't save progress for demo puzzles (which have a zero date)
    if (date.millisecondsSinceEpoch == 0) return;
    _local.saveBoardForDate(board, date);
  }

  void saveTime(TimerSave time, DateTime date) {
    // Don't save progress for demo puzzles
    if (date.millisecondsSinceEpoch == 0) return;
    _local.saveTimeForDate(time, date);
  }

  Future<TDigest> getDigest(DateTime date) {
    return _remote.fetchDigest(date);
  }

  Future<void> saveDigest(TDigest digest, DateTime date) {
    return _remote.saveDigest(digest, date);
  }
}
