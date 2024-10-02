extension CaseIndependentEquality on String {
  bool equalsIgnoreCase(String other) =>
      toLowerCase().trim() == other.toLowerCase().trim();
}

extension FromYMD on String {
  DateTime fromYMD() {
    int year = int.parse(substring(0, 4));
    int month = int.parse(substring(4, 6));
    int day = int.parse(substring(6));
    return DateTime(year, month, day);
  }
}

extension ToYMD on DateTime {
  String toYMD() {
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
