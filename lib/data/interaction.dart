import 'phrasetail.dart';

class Interaction {
  Interaction({
    this.tailDown = Tail.empty,
    this.tailRight = Tail.empty,
  });
  Tail tailDown;
  Tail tailRight;
  bool get interactsDown => tailDown.isValid;
  bool get interactsRight => tailRight.isValid;
  static Interaction get empty =>
      Interaction(tailDown: Tail.empty, tailRight: Tail.empty);
  @override
  String toString() => '(down: $tailDown, right: $tailRight)';
}
