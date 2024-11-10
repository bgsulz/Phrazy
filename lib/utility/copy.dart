import 'dart:math';
import 'package:phrazy/utility/ext.dart';

class Copy {
  static const String gameName = "Phrazy";
  static const String title = Copy.gameName;
  static const String subtitle = 'Assemble the words into phrases!';
  static const String rules1 = "Drag and drop the words into the grid!\n\n"
      "Words next to each other must form\nphrases or compound words.";
  static const String rules2 =
      "If there's a wall between two words,\nthey don't need to form a phrase.\n\n"
      "Words might be separated by a common word:\na, an, and, the, of";
  static const String info =
      "${Copy.gameName} was created and programmed by me, Ben Sulzinsky.\n"
      "Thanks to my brother for helping with the design of the game.\n"
      "Thanks to Kenney for the sound effects.\n";

  static String get motivation => [
        "You're doing great!",
        "Keep up the good work!",
        "You've got this one!"
      ][Random().nextInt(3)];

  static String congratsString(int value) {
    final duration = Duration(milliseconds: value);
    var minutes = duration.inMinutes;
    if (minutes < 1) return "Lightspeed!";
    if (minutes < 2) return "Blistering speed!";
    if (minutes < 3) return "Done and dusted!";
    if (minutes < 5) return "Nicely done!";
    if (minutes < 10) return "Solved!";
    return "Stuck with it!";
  }

  static String summaryString(DateTime date, String displayTime) {
    final datePart = date.year < 1980 ? '' : ' for ${date.toDisplayDate}';
    return 'You solved the ${Copy.gameName}$datePart in $displayTime.';
  }

  static String shareString(DateTime date, String displayTime) {
    final datePart = date.year < 1980 ? 'demo' : date.toDisplayDate;
    return '${Copy.gameName} $datePart\n'
        '$displayTime\n'
        'https://phrazy.fun';
  }
}
