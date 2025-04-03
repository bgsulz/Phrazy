extension CaseIndependentEquality on String {
  bool equalsIgnoreCase(String other) =>
      toLowerCase().trim() == other.toLowerCase().trim();
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

  String get toDisplayDateWithDay {
    return "${_dayOfWeek(this)} $toDisplayDate";
  }

  String _dayOfWeek(DateTime date) {
    List<String> days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    return days[date.weekday - 1];
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
