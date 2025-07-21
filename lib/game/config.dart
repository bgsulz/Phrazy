class AppConfig {
  /// The date of the very first daily puzzle.
  static final DateTime startDate = DateTime(2024, 10, 1, 12);

  /// The date of the most recent available daily puzzle (today).
  static DateTime get endDate => DateTime.now()
      .copyWith(hour: 23, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  /// The total number of daily puzzles available to play.
  static int get totalDailies => endDate.difference(startDate).inDays + 1;
}
