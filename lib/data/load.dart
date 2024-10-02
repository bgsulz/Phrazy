import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phrasewalk/data/puzzle.dart';
import 'package:phrasewalk/utility/debug.dart';
import 'package:phrasewalk/utility/ext.dart';
import 'package:web/web.dart' as web;

typedef PhraseMap = Map<String, List<PhraseTail>>;

class PhraseTail {
  final String connector;
  final String tail;

  const PhraseTail(this.connector, this.tail);

  static PhraseTail get none => const PhraseTail('', '');
  bool get isEmpty => tail.isEmpty;

  @override
  String toString() => isEmpty ? 'Empty' : '$connector $tail';
}

class Load {
  static final _localStorage = web.window.localStorage;

  static final DateTime startDate = DateTime(2024, 10, 1);
  static DateTime get endDate => DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  static int get totalDailies => endDate.difference(startDate).inDays + 1;

  static String path = 'phrases.yaml';
  static Map<String, List<PhraseTail>> _allPhrases = {};

  static bool checkFirstTime() {
    final firstTime = _localStorage["firstTime"];
    if (firstTime == null) {
      _localStorage["firstTime"] = "false";
      return true;
    }
    return false;
  }

  static Future<PhraseMap> _loadAllPhrases() async {
    try {
      final PhraseMap phraseMap = {};
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection("phrases");
      final docs = await collection.get();

      for (var doc in docs.docs) {
        final data = doc.data();
        final head = doc.id;
        final tails = data.entries.map((e) => PhraseTail(data[e.key], e.key));
        phraseMap[head] = tails.toList();
      }

      return phraseMap;
    } on FirebaseException catch (e) {
      debug("Failed to load phrases: $e");
      rethrow;
    }
  }

  static Future<Puzzle> puzzleForDate(DateTime date) async {
    final firestore = FirebaseFirestore.instance;
    _allPhrases = await _loadAllPhrases();

    try {
      final dailiesCollection = firestore.collection("dailies");
      final dailyDocRef = dailiesCollection.doc(date.toYMD());
      final dailyDocSnap = await dailyDocRef.get();
      if (!dailyDocSnap.exists) {
        throw Exception("Today's daily (${date.toYMD()}) does not exist.");
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
      return Puzzle.fromFirebase(puzzleData);
    } on FirebaseException catch (f) {
      debug("Failed to load puzzle: $f");
      rethrow;
    } on Exception catch (e) {
      debug("Failed to load today's puzzle: $e");
    }

    return Puzzle.empty();
  }

  static PhraseTail isValidPhrase(String a, String b) {
    if (a.isEmpty || b.isEmpty) return PhraseTail.none;
    var head = a.toLowerCase().trim();
    var tail = b.toLowerCase().trim();

    if (!_allPhrases.containsKey(head)) return PhraseTail.none;
    return _allPhrases[head]!.firstWhere((t) => t.tail.equalsIgnoreCase(tail),
        orElse: () => PhraseTail.none);
  }
}
