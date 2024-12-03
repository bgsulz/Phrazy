import 'dart:convert';
import 'package:phrazy/utility/debug.dart';
import 'package:phrazy/utility/ext.dart';
import 'package:web/web.dart' as web;

class WebStorage {
  static final _localStorage = web.window.localStorage;

  static bool get isSafari =>
      web.window.navigator.userAgent.contains("Safari") &&
      !web.window.navigator.userAgent.contains("Chrome");

  static bool get isMuted => _localStorage["muteSounds"] == "true";
  static void toggleMute() {
    final isMuted = _localStorage["muteSounds"];
    _localStorage["muteSounds"] = isMuted == "true" ? "false" : "true";
  }

  static bool get isFirstTime {
    final firstTime = _localStorage["firstTime"];
    if (firstTime == null) {
      _localStorage["firstTime"] = "false";
      return true;
    }
    return false;
  }

  static void saveBoardForDate(BoardState state, String date) {
    // debug("Saving state for $date");
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
    // debug("Saving state $state for $date");
    final stateString = state.toJson();
    _localStorage["${date}_time"] = stateString;
  }

  static TimerState? loadTimeForDate(String date) {
    final stateString = _localStorage["${date}_time"];

    if (stateString == null) {
      // debug("No saved time for $date");
      return null;
    } else {
      try {
        // debug('attempting json');
        Map<String, dynamic> state = jsonDecode(stateString);
        var res = TimerState.fromJson(state);
        // debug("Loading time $res for $date");
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
