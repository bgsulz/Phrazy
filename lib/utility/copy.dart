import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../utility/ext.dart';
import 'dart:math';

class Copy {
  static const String gameName = "Phrazy";
  static const String title = Copy.gameName;
  static const String subtitle = 'Assemble the words into phrases!';
  static const String rules1 =
      "<style fontWeight='bold'>Drag</style> the words into the grid!\n\n"
      "All neighboring words must <style fontWeight='bold'>connect</style>\n"
      "to form <style fontWeight='bold'>phrases</style> or <style fontWeight='bold'>compound words</style>.";
  static const String rules2 =
      "If there's a <style fontWeight='bold'>wall</style> between two words,\nthey don't need to form a phrase.\n\n"
      "Some phrases have a '<style fontWeight='bold'>connector word</style>.'\n"
      "All connector words appear above the puzzle.";
  static const String info =
      "Howdy, I'm Ben. I made ${Copy.gameName} and most of its daily puzzles.\n\n"
      "Thanks to the <style fontWeight='bold'>guest puzzle creators</style> (see byline beneath certain puzzle grids!)\n"
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
      ][Random().nextInt(6)];

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

  static IconData congratsIcon(int value) {
    final duration = Duration(milliseconds: value);
    var minutes = duration.inMinutes;
    if (minutes < 1) return HugeIcons.strokeRoundedZap;
    if (minutes < 2) return HugeIcons.strokeRoundedMotorbike01;
    if (minutes < 3) return HugeIcons.strokeRoundedClean;
    if (minutes < 5) return HugeIcons.strokeRoundedChampion;
    if (minutes < 10) return HugeIcons.strokeRoundedAward02;
    return HugeIcons.strokeRoundedBoxingGlove;
  }

  static String summaryString(DateTime date, String displayTime) {
    final datePart = date.year < 1980 ? '' : ' for ${date.toDisplayDate}';
    return 'You solved the ${Copy.gameName}$datePart in $displayTime.';
  }

  static String shareString(DateTime date, String displayTime, int solveTime) {
    final datePart = date.year < 1980 ? 'Tutorial' : date.toDisplayDate;
    String emoji;
    final duration = Duration(milliseconds: solveTime);
    var minutes = duration.inMinutes;

    if (minutes < 1) {
      emoji = "⚡️";
    } else if (minutes < 2) {
      emoji = "🏍️";
    } else if (minutes < 3) {
      emoji = "🧹";
    } else if (minutes < 5) {
      emoji = "🏆";
    } else if (minutes < 10) {
      emoji = "🏅";
    } else {
      emoji = "🥊";
    }
    return '${Copy.gameName} $datePart\n'
        '$emoji $displayTime\n'
        'https://phrazy.fun';
  }
}
