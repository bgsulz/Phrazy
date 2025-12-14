import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phrazy/core/puzzle_interface.dart';
import 'package:phrazy/core/ext_ymd.dart';
import 'package:phrazy/utility/debug.dart';

class PuzzleLoader<T extends PuzzleInterface> {
  final String dailiesCollectionName;
  final String puzzlesCollectionName;
  final T Function(Map<String, dynamic>, int?) fromFirebase;

  PuzzleLoader({
    required this.dailiesCollectionName,
    required this.puzzlesCollectionName,
    required this.fromFirebase,
  });

  /// Fetches a puzzle ID from the dailies collection based on the given date.
  Future<int?> getPuzzleIdForDate(DateTime date) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final dailyDocRef =
          firestore.collection(dailiesCollectionName).doc(date.toYMD);
      final dailyDocSnap = await dailyDocRef.get();

      if (!dailyDocSnap.exists) {
        debug("Daily document for ${date.toIso8601String()} does not exist.");
        return null;
      }

      final dailyData = dailyDocSnap.data();
      if (dailyData == null || !dailyData.containsKey('id')) {
        debug(
            "Daily document for ${date.toIso8601String()} is missing the 'id' field.");
        return null;
      }

      return dailyData['id'] as int?;
    } catch (e) {
      debug("Error fetching puzzle ID: $e");
      return null;
    }
  }

  /// Fetches a puzzle document from the puzzles collection based on the given puzzle ID.
  Future<Map<String, dynamic>?> getPuzzleData(int puzzleId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final puzzleQuerySnapshot = await firestore
          .collection(puzzlesCollectionName)
          .where("id", isEqualTo: puzzleId)
          .limit(1)
          .get();

      if (puzzleQuerySnapshot.docs.isEmpty) {
        debug("Puzzle with ID $puzzleId does not exist.");
        return null;
      }

      final puzzleDocSnap = puzzleQuerySnapshot.docs.first;
      return puzzleDocSnap.data();
    } catch (e) {
      debug("Error fetching puzzle  $e");
      return null;
    }
  }

  /// Loads a puzzle from Firestore based on the given date.
  ///
  /// Returns a map containing the puzzle data if successful, otherwise returns null.
  Future<Map<String, dynamic>?> loadPuzzleForDate(DateTime date) async {
    final puzzleId = await getPuzzleIdForDate(date);
    if (puzzleId == null) {
      return null;
    }

    return getPuzzleData(puzzleId);
  }

  Future<List<DateTime>> getAvailableDailyDates({DateTime? upTo}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot =
          await firestore.collection(dailiesCollectionName).get();

      final cutoff = (upTo ?? DateTime.now())
          .copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);

      final dates = <DateTime>[];
      for (final doc in querySnapshot.docs) {
        try {
          final date = doc.id.fromYMD.copyWith(hour: 12);
          if (!date.isAfter(cutoff)) {
            dates.add(date);
          }
        } catch (e) {
          debug("Error parsing daily doc id ${doc.id}: $e");
        }
      }

      dates.sort();
      return dates;
    } catch (e) {
      debug("Error listing daily docs: $e");
      return [];
    }
  }
}
