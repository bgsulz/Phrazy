import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/puzzle.dart';
import '../utility/debug.dart';
import '../utility/ext.dart';
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

  static void saveBoardForDate(BoardState state, String date) {
    debug("Saving state for $date");
    final historyString = state.toJson();
    _localStorage[date] = historyString;
  }

  static BoardState? loadBoardForDate(String date) {
    debug("Loading state for $date");
    final historyString = _localStorage[date];

    if (historyString == null) {
      debug("No saved state for $date");
      return null;
    } else {
      try {
        // debug('attempting json');
        Map<String, dynamic> history = jsonDecode(historyString);
        return BoardState.fromJson(history);
      } on Exception catch (e) {
        debug('Failed to load state from $date: $e');
        _localStorage[date] = '';
        return null;
      }
    }
  }

  static void saveTimeForDate(TimerState state, String date) {
    debug("Saving state $state for $date");
    final stateString = state.toJson();
    _localStorage["${date}_time"] = stateString;
  }

  static TimerState? loadTimeForDate(String date) {
    final stateString = _localStorage["${date}_time"];

    if (stateString == null) {
      debug("No saved time for $date");
      return null;
    } else {
      try {
        // debug('attempting json');
        Map<String, dynamic> state = jsonDecode(stateString);
        var res = TimerState.fromJson(state);
        debug("Loading time $res for $date");
        return res;
      } on Exception catch (e) {
        debug('Failed to load state from $date: $e');
        _localStorage["${date}_time"] = '';
        return null;
      }
    }
  }
}

class BoardState {
  final List<String> wordBank;
  final List<String> grid;

  BoardState({
    required this.wordBank,
    required this.grid,
  });

  factory BoardState.fromJson(Map<String, dynamic> json) {
    return BoardState(
      wordBank: (json['wordBank'] as List<dynamic>).cast<String>(),
      grid: (json['grid'] as List<dynamic>).cast<String>(),
    );
  }

  String toJson() {
    return jsonEncode({
      'wordBank': wordBank,
      'grid': grid,
    });
  }
}

class TimerState {
  final int time;
  final bool isSolved;

  TimerState({
    required this.time,
    required this.isSolved,
  });

  factory TimerState.fromJson(Map<String, dynamic> json) {
    return TimerState(
      time: json['time'] as int,
      isSolved: json['isSolved'] as bool,
    );
  }

  String toJson() {
    return jsonEncode({
      'time': time,
      'isSolved': isSolved,
    });
  }

  @override
  String toString() {
    return "${time.toDisplayTime}${isSolved ? "" : "+"}";
  }
}
