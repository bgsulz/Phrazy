extension CaseIndependentEquality on String {
  bool equalsIgnoreCase(String other) =>
      toLowerCase().trim() == other.toLowerCase().trim();
}

extension FromYMD on String {
  DateTime get fromYMD {
    int year = int.parse(substring(0, 4));
    int month = int.parse(substring(4, 6));
    int day = int.parse(substring(6));
    return DateTime(year, month, day);
  }
}

extension ToYMD on DateTime {
  String get toYMD {
    return "${year.toString().padLeft(4, '0')}${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}";
  }
}

extension IsToday on DateTime {
  bool get isToday {
    return isSameDayAs(DateTime.now());
  }

  bool isSameDayAs(DateTime other) {
    return other.day == day && other.month == month && other.year == year;
  }
}

extension DisplayDate on DateTime {
  String get toDisplayDate {
    return "$month/$day/$year";
  }
}

extension DisplayTime on int {
  String get toDisplayTime {
    Duration duration = Duration(milliseconds: this);
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    if (duration.inHours == 0) {
      return "${duration.inMinutes}:${twoDigits(duration.inSeconds.remainder(60))}";
    } else {
      return "${duration.inHours}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
    }
  }

  String get toDisplayTimeFromSeconds => (this * 1000).toDisplayTime;
}

extension SameList<T> on List<T> {
  bool isSameAs(List<T> other) {
    final sorted1 = [...this]..sort();
    final sorted2 = [...other]..sort();
    if (sorted1.length != sorted2.length) return false;
    for (int i = 0; i < sorted1.length; i++) {
      if (sorted1[i] != sorted2[i]) return false;
    }
    return true;
  }
}
