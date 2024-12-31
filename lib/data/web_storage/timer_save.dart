import 'dart:convert';

import '../../utility/ext.dart';

class TimerSave {
  final int time;
  final bool isSolved;

  TimerSave({
    required this.time,
    required this.isSolved,
  });

  factory TimerSave.fromJson(Map<String, dynamic> json) {
    return TimerSave(
      time: json['time'] as int,
      isSolved: json['isSolved'] as bool,
    );
  }

  String toJson() {
    return jsonEncode({
      'time': time,
      'isSolved': isSolved,
    });
  }

  @override
  String toString() {
    return "${time.toDisplayTime}${isSolved ? "" : "+"}";
  }
}
