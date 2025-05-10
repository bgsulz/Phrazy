import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/puzzle_loader.dart';
import '../data/tail.dart';
import '../utility/debug.dart';
import '../data/puzzle.dart';
import '../utility/ext.dart';

typedef PhraseMap = Map<String, List<Tail>>;

class Load {
  static final DateTime startDate = DateTime(2024, 10, 1, 12);
  static DateTime get endDate => DateTime.now()
      .copyWith(hour: 23, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  static int get totalDailies => endDate.difference(startDate).inDays + 1;

  static String path = 'phrases.yaml';
  static PhraseMap _phrases = {};

  final String dailiesCollectionName;
  final String puzzlesCollectionName;

  Load({
    required this.dailiesCollectionName,
    required this.puzzlesCollectionName,
  });

  static Future<PhraseMap> _loadPhrasesForPuzzle(Puzzle puzzle) async {
    if (puzzle.bundledInteractions != null) {
      return Future.value(puzzle.bundledInteractions);
    }

    try {
      final PhraseMap phraseMap = {};
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection("phrases");

      final queryResults = await Future.wait(
          puzzle.words.map((word) => collection.doc(word).get()));

      for (var result in queryResults) {
        final data = result.data();
        if (data == null) {
          continue;
        }
        final head = result.id;
        final tails = data.entries
            .where((e) =>
                (puzzle.connectors?.contains(e.value) ?? false) ||
                e.value == "" ||
                e.value == " " ||
                e.value == "-")
            .map((e) => Tail(e.value, e.key));
        phraseMap[head] = tails.toList();
      }

      return phraseMap;
    } on FirebaseException catch (e) {
      debug(e);
      rethrow;
    }
  }

  static Future<Puzzle> puzzle(Puzzle puzzle) async {
    _phrases = await _loadPhrasesForPuzzle(puzzle);
    return puzzle;
  }

  Future<Puzzle> puzzleForDate(DateTime date) async {
    final puzzleLoader = PuzzleLoader<Puzzle>(
      dailiesCollectionName: dailiesCollectionName,
      puzzlesCollectionName: puzzlesCollectionName,
      fromFirebase: Puzzle.fromFirebase,
    );

    try {
      final puzzleData = await puzzleLoader.loadPuzzleForDate(date);

      if (puzzleData == null) {
        debug("Today's puzzle does not exist. Returning an empty puzzle.");
        return Puzzle.empty();
      }

      final puzzle = puzzleLoader.fromFirebase(puzzleData);

      _phrases = await _loadPhrasesForPuzzle(puzzle);

      return puzzle;
    } on FirebaseException catch (f) {
      debug(f);
      return Puzzle.empty();
    }
  }

  static Tail isValidPhrase(String a, String b) {
    if (a.isEmpty || b.isEmpty) return Tail.empty;
    var head = a.trim();
    var tail = b.trim();

    if (!_phrases.containsKey(head)) {
      return Tail.fail;
    }
    return _phrases[head]!.firstWhere((t) => t.tail.equalsIgnoreCase(tail),
        orElse: () => Tail.fail);
  }
}
