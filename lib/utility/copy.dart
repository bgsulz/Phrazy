import '../utility/ext.dart';
import 'dart:math';

class Copy {
  static const String gameName = "Phrazy";
  static const String title = Copy.gameName;
  static const String subtitle = 'Assemble the words into phrases!';
  static const String rules1 = "Drag and drop the words into the grid!\n\n"
      "Words next to each other must form\nphrases or compound words.";
  static const String rules2 =
      "If there's a wall between two words,\nthey don't need to form a phrase.\n\n"
      "Some phrases might be joined together\nby a 'connector word.'\n\n"
      "If that's the case,\nthe connector word appears above the puzzle.";
  static const String info =
      "${Copy.gameName} was created and programmed by me, Ben Sulzinsky.\n"
      "Thanks to my brother for helping with the design of the game.\n"
      "Thanks to Kenney for the sound effects.\n";

  static String get motivation => [
        "You're doing great.",
        "Take a breather!",
        "Keep it up!",
        "You've got this, boss.",
        "No one Phrazys like you!",
        "Trust me. You're killing it.",
        "Deep breaths, deep breaths.",
        "This one's all you!",
        "You're a total pro."
      ][Random().nextInt(9)];

  static String get downloading => [
        "Downloading your puzzle from the interwebs...",
        "Politely requesting your puzzle from the server...",
        "Retriving your puzzle from the binary soup...",
        "Summoning your puzzle from the digital ether...",
        "Grabbing your puzzle from a random hard drive somewhere...",
        "Delivering your puzzle by carrier pigeon...",
      ][Random().nextInt(7)];

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
