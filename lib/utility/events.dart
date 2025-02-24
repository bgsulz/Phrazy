import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:phrazy/utility/ext.dart';

class Events {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static void logVisit() {
    _analytics.logEvent(name: 'app_visit', parameters: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void logWin({required DateTime date}) {
    _analytics.logEvent(name: 'puzzle_win', parameters: {
      'timestamp': DateTime.now().toIso8601String(),
      'loadedAt': date.toYMD,
    });
  }
}
