import 'dart:convert';
import 'package:web/web.dart' as web;

import '../../data/web_storage/board_save.dart';
import '../../data/web_storage/timer_save.dart';
import '../../utility/debug.dart';

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

  static void saveBoardForDate(BoardSave state, String date) {
    final historyString = state.toJson();
    _localStorage[date] = historyString;
  }

  static BoardSave? loadBoardForDate(String date) {
    debug("Loading state for $date");
    final historyString = _localStorage[date];

    if (historyString == null) {
      debug("No saved state for $date");
      return null;
    } else {
      try {
        Map<String, dynamic> history = jsonDecode(historyString);
        return BoardSave.fromJson(history);
      } on Exception catch (e) {
        debug('Failed to load state from $date: $e');
        _localStorage[date] = '';
        return null;
      }
    }
  }

  static void saveTimeForDate(TimerSave state, String date) {
    final stateString = state.toJson();
    _localStorage["${date}_time"] = stateString;
    print("Saved time ${state.time}, ${state.isSolved} for date $date");
  }

  static TimerSave? loadTimeForDate(String date) {
    final stateString = _localStorage["${date}_time"];

    if (stateString == null) {
      return null;
    } else {
      try {
        Map<String, dynamic> state = jsonDecode(stateString);
        var res = TimerSave.fromJson(state);
        return res;
      } on Exception catch (e) {
        debug('Failed to load state from $date: $e');
        _localStorage["${date}_time"] = '';
        return null;
      }
    }
  }
}
