import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phrazy/data/phrasetail.dart';
import 'package:phrazy/utility/debug.dart';
import '../data/puzzle.dart';
// import '../utility/debug.dart';
import '../utility/ext.dart';

typedef PhraseMap = Map<String, List<Tail>>;

class Load {
  static final DateTime startDate = DateTime(2024, 10, 1, 12);
  static DateTime get endDate => DateTime.now()
      .copyWith(hour: 23, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  static int get totalDailies => endDate.difference(startDate).inDays + 1;

  static String path = 'phrases.yaml';
  static PhraseMap _phrases = {};

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
        final tails = data.entries.map((e) => Tail(e.value, e.key));
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

  static Future<Puzzle> puzzleForDate(DateTime date) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final dailiesCollection = firestore.collection("dailies");
      final dailyDocRef = dailiesCollection.doc(date.toYMD);
      final dailyDocSnap = await dailyDocRef.get();
      if (!dailyDocSnap.exists) {
        throw Exception("Today's daily (${date.toYMD}) does not exist.");
      }

      final dailyData = dailyDocSnap.data() as Map<String, dynamic>;
      final id = dailyData['id'] as int;

      final docRef = await firestore
          .collection("puzzles")
          .where("id", isEqualTo: id)
          .limit(1)
          .get()
          .then((snap) => snap.docs.first.reference);

      final puzzleDocSnap = await docRef.get();
      if (!puzzleDocSnap.exists) {
        throw Exception("Today's puzzle does not exist.");
      }

      final puzzleData = puzzleDocSnap.data() as Map<String, dynamic>;
      final puzzle = Puzzle.fromFirebase(puzzleData);

      _phrases = await _loadPhrasesForPuzzle(puzzle);

      return puzzle;
    } on FirebaseException catch (f) {
      debug(f);
      // rethrow;
    }

    return Puzzle.empty();
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
