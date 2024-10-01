import 'package:flutter/services.dart';
import 'package:phrasewalk/data/puzzle.dart';
import 'package:phrasewalk/utility/ext.dart';
import 'package:yaml/yaml.dart';
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

  static final DateTime startDate = DateTime(2024, 9, 11);
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
    print("loading all phrases");
    final yamlString = await rootBundle.loadString(path);
    final yamlMap = loadYaml(yamlString) as Map;
    final PhraseMap phraseMap = {};
    for (final entry in yamlMap.entries) {
      final phrases = <PhraseTail>[];
      for (final phrase in entry.value as List<dynamic>) {
        phrases.add(PhraseTail(
            phrase['connector'] as String, phrase['tail'] as String));
      }
      phraseMap[entry.key] = phrases;
    }
    return phraseMap;
  }

  static Future<Puzzle> puzzleForDate(DateTime date) async {
    _allPhrases = await _loadAllPhrases();
    return Puzzle.demoHard();
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
