import 'package:phrazy/data/puzzle.dart';
import 'package:phrazy/data/web_storage/board_save.dart';
import 'package:phrazy/data/web_storage/timer_save.dart';
import 'package:phrazy/game/phrase_validator.dart';

class LoadedGameData {
  final Puzzle puzzle;
  final PhraseValidator validator;
  final BoardSave? savedBoard;
  final TimerSave? savedTime;
  final String? errorMessage;

  LoadedGameData({
    required this.puzzle,
    required this.validator,
    this.savedBoard,
    this.savedTime,
    this.errorMessage,
  });

  bool get isError => errorMessage != null;

  factory LoadedGameData.error(String message) {
    return LoadedGameData(
      puzzle: Puzzle.empty(),
      validator: PhraseValidator({}),
      errorMessage: message,
    );
  }
}
