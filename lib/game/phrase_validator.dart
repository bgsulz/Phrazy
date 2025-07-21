import '../data/tail.dart';
import '../utility/ext.dart';

typedef PhraseMap = Map<String, List<Tail>>;

class PhraseValidator {
  final PhraseMap _phrases;

  // The validator is initialized with the phrases for ONE puzzle.
  PhraseValidator(this._phrases);

  // This is the old Load.isValidPhrase, now as a pure instance method.
  Tail validate(String a, String b) {
    if (a.isEmpty || b.isEmpty) return Tail.empty;
    var head = a.trim();
    var tail = b.trim();

    if (!_phrases.containsKey(head)) {
      return Tail.fail;
    }
    return _phrases[head]!.firstWhere((t) => t.tail.equalsIgnoreCase(tail),
        orElse: () => Tail.fail);
  }
}
