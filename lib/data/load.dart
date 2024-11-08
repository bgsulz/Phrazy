import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:phrazy/data/tail.dart';
import '../data/puzzle.dart';
import '../utility/debug.dart';
import '../utility/ext.dart';
import 'package:web/web.dart' as web;

typedef PhraseMap = Map<String, List<PhraseTail>>;

class Load {
  static final _localStorage = web.window.localStorage;

  static final DateTime startDate = DateTime(2024, 10, 1);
  static DateTime get endDate => DateTime.now()
      .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  static int get totalDailies => endDate.difference(startDate).inDays + 1;

  static String path = 'phrases.yaml';
  static Map<String, List<PhraseTail>> _phrases = {};

  static bool get isMuted => _localStorage["muteSounds"] == "true";
  static void toggleMute() {
    final isMuted = _localStorage["muteSounds"];
    if (isMuted == "true") {
      _localStorage["muteSounds"] = "false";
    } else {
      _localStorage["muteSounds"] = "true";
    }
  }

  static bool checkFirstTime() {
    final firstTime = _localStorage["firstTime"];
    if (firstTime == null) {
      _localStorage["firstTime"] = "false";
      return true;
    }
    return false;
  }

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

  List<String> allWords() =>
      [...wordBank, ...grid].where((element) => element.isNotEmpty).toList();
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
