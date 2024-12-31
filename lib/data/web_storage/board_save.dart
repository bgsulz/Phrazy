import 'dart:convert';

class BoardSave {
  final List<String> wordBank;
  final List<String> grid;

  BoardSave({
    required this.wordBank,
    required this.grid,
  });

  factory BoardSave.fromJson(Map<String, dynamic> json) {
    return BoardSave(
      wordBank: (json['wordBank'] as List<dynamic>).cast<String>(),
      grid: (json['grid'] as List<dynamic>).cast<String>(),
    );
  }

  String toJson() {
    return jsonEncode({
      'wordBank': wordBank,
      'grid': grid,
    });
  }

  List<String> allWords() =>
      [...wordBank, ...grid].where((element) => element.isNotEmpty).toList();
}
