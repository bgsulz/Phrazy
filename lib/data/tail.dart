class PhraseTail {
  static const emptyString = '<empty>';
  static const failString = '<fail>';

  static const empty = PhraseTail(emptyString, '');
  static const fail = PhraseTail(failString, '');

  final String connector;
  final String tail;

  const PhraseTail(this.connector, this.tail);

  bool get isEmpty => connector == emptyString;
  bool get isFail => connector == failString;
  bool get isValid => !isEmpty && !isFail;

  @override
  String toString() => isEmpty ? 'Empty' : '$connector $tail';
}
