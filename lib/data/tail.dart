class Tail {
  static const emptyString = '<empty>';
  static const failString = '<fail>';

  static const empty = Tail(emptyString, '');
  static const fail = Tail(failString, '');

  final String connector;
  final String tail;

  const Tail(this.connector, this.tail);

  bool get isEmpty => connector == emptyString;
  bool get isFail => connector == failString;
  bool get isValid => !isEmpty && !isFail;

  @override
  String toString() => isEmpty ? 'Empty' : '$connector $tail';

  factory Tail.from(String s) {
    final match = RegExp(r'(\w+)$').firstMatch(s);
    final connector = s.substring(0, match?.start).trim();
    final tail = match?.group(0) ?? '';
    return Tail(connector, tail);
  }
}
