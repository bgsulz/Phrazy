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
  bool isSameAs(List<T> other, {bool Function(T, T)? equals}) {
    final thisSorted = [...this];
    final otherSorted = [...other];
    thisSorted.sort();
    otherSorted.sort();
    if (otherSorted.length != thisSorted.length) return false;
    for (int i = 0; i < thisSorted.length; i++) {
      if (equals?.call(thisSorted[i], otherSorted[i]) != true &&
          thisSorted[i] != otherSorted[i]) {
        return false;
      }
    }
    return true;
  }
}
