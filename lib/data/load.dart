import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:phrazy/data/phrasetail.dart';
import '../data/puzzle.dart';
import '../utility/debug.dart';
import '../utility/ext.dart';

typedef PhraseMap = Map<String, List<PhraseTail>>;

class Load {
  static final DateTime startDate = DateTime(2024, 10, 1);
  static DateTime get endDate => DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  static int get totalDailies => endDate.difference(startDate).inDays + 1;

  static String path = 'phrases.yaml';
  static Map<String, List<PhraseTail>> _phrases = {};

  static Future<PhraseMap> _loadPhrasesForPuzzle(Puzzle puzzle) async {
    try {
      final PhraseMap phraseMap = {};
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection("phrases");

      final queryResults = await Future.wait(puzzle.words
          .map((word) => collection.where("name", isEqualTo: word).get()));

      for (var result in queryResults) {
        for (var doc in result.docs) {
          final data = doc.data();
          final head = doc.id;
          final tails = data.entries.map((e) => PhraseTail(e.value, e.key));
          phraseMap[head] = tails.toList();
        }
      }

      return phraseMap;
    } on FirebaseException catch (e) {
      debug("Failed to load phrases: $e");
      rethrow;
    }
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
      debug("Failed to load puzzle: $f");
      rethrow;
    } on Exception catch (e) {
      debug("Failed to load today's puzzle: $e");
    }

    return Puzzle.empty();
  }

  static PhraseTail isValidPhrase(String a, String b) {
    if (a.isEmpty || b.isEmpty) return PhraseTail.empty;
    var head = a.trim();
    var tail = b.trim();

    if (kDebugMode) {
      if (head == "count" && tail == "out") {
        return const PhraseTail("", "out");
      }
    }

    if (!_phrases.containsKey(head)) return PhraseTail.fail;
    return _phrases[head]!.firstWhere((t) => t.tail.equalsIgnoreCase(tail),
        orElse: () => PhraseTail.fail);
  }
}
