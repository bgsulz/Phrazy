import 'dart:math';

class Copy {
  static const String gameName = "Phrazy";
  static const String title = Copy.gameName;
  static const String subtitle = 'Assemble the words into phrases!';
  static const String rules1 = "Drag and drop the words into the grid.\n"
      "All adjacent pairs of words (vertical and horizontal) must form phrases or compound words.";
  static const String rules2 =
      "Pairs of words can be joined by one or more of the following common words:\n"
      "a, of, an, to, in, the, for";
  static const String info =
      "${Copy.gameName} was created and programmed by me, Ben Sulzinsky.\n"
      "Thanks to my brother for helping with the design of the game.\n"
      "Thanks to Kenney for the sound effects.\n";

  static String get motivation => [
        "You're doing great!",
        "Keep up the good work!",
        "You've got this one!"
      ][Random().nextInt(3)];
}
