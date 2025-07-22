import 'dart:convert';
import 'package:web/web.dart' as web;

import '../../data/web_storage/board_save.dart';
import '../../data/web_storage/timer_save.dart';
import '../../utility/debug.dart';

class WebStorage {
  static const String _muteSoundsKey = "muteSounds";
  static const String _developerModeKey = "developerMode";
  static const String _firstTimeKey = "firstTime";
  static const String _timeSuffix = "_time";
  static const String _highContrastKey = "highContrast";

  static final _localStorage = web.window.localStorage;

  static bool get isSafari =>
      web.window.navigator.userAgent.contains("Safari") &&
      !web.window.navigator.userAgent.contains("Chrome");

  static bool get isMuted => _localStorage.getItem(_muteSoundsKey) == "true";
  static bool get isDeveloperMode =>
      _localStorage.getItem(_developerModeKey) == "true";
  static bool get isHighContrast =>
      _localStorage.getItem(_highContrastKey) == "true";

  static void toggleMute() {
    final isMuted = _localStorage.getItem(_muteSoundsKey);
    _localStorage.setItem(_muteSoundsKey, isMuted == "true" ? "false" : "true");
  }

  static void toggleDeveloperMode() {
    final isDevMode = _localStorage.getItem(_developerModeKey);
    _localStorage.setItem(
        _developerModeKey, isDevMode == "true" ? "false" : "true");
  }

  static void toggleHighContrast() {
    final isHighContrast = _localStorage.getItem(_highContrastKey);
    _localStorage.setItem(
        _highContrastKey, isHighContrast == "true" ? "false" : "true");
  }

  static bool get isFirstTime {
    final firstTime = _localStorage.getItem(_firstTimeKey);
    if (firstTime == null) {
      _localStorage.setItem(_firstTimeKey, "false");
      return true;
    }
    return false;
  }

  static void saveBoardForDate(BoardSave state, String date) {
    final historyString = state.toJson();
    _localStorage.setItem(date, historyString);
  }

  static BoardSave? loadBoardForDate(String date) {
    // debug("Loading state for $date");
    final historyString = _localStorage.getItem(date);

    if (historyString == null) {
      // debug("No saved state for $date");
      return null;
    } else {
      try {
        Map<String, dynamic> history = jsonDecode(historyString);
        return BoardSave.fromJson(history);
      } on Exception {
        // debug('Failed to load state from $date: $e');
        _localStorage.setItem(date, '');
        return null;
      }
    }
  }

  static void saveTimeForDate(TimerSave state, String date) {
    final stateString = state.toJson();
    _localStorage.setItem("$date$_timeSuffix", stateString);
    // debug("Saved time ${state.time}, ${state.isSolved} for date $date");
  }

  static TimerSave? loadTimeForDate(String date) {
    final stateString = _localStorage.getItem("$date$_timeSuffix");

    if (stateString == null) {
      return null;
    } else {
      try {
        Map<String, dynamic> state = jsonDecode(stateString);
        var res = TimerSave.fromJson(state);
        return res;
      } on Exception catch (e) {
        debug('Failed to load state from $date: $e');
        _localStorage.setItem("$date$_timeSuffix", '');
        return null;
      }
    }
  }
}
