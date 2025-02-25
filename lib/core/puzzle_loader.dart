import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phrazy/data/puzzle_interface.dart';

class PuzzleLoader<T extends PuzzleInterface> {
  final String dailiesCollectionName;
  final String puzzlesCollectionName;
  final T Function(Map<String, dynamic>) fromFirebase;

  PuzzleLoader({
    required this.dailiesCollectionName,
    required this.puzzlesCollectionName,
    required this.fromFirebase,
  });

  /// Fetches a puzzle ID from the dailies collection based on the given date.
  Future<int?> getPuzzleIdForDate(DateTime date) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final dailyDocRef = firestore
          .collection(dailiesCollectionName)
          .doc(date.toIso8601String().split('T')[0]);
      final dailyDocSnap = await dailyDocRef.get();

      if (!dailyDocSnap.exists) {
        print("Daily document for ${date.toIso8601String()} does not exist.");
        return null;
      }

      final dailyData = dailyDocSnap.data();
      if (dailyData == null || !dailyData.containsKey('id')) {
        print(
            "Daily document for ${date.toIso8601String()} is missing the 'id' field.");
        return null;
      }

      return dailyData['id'] as int?;
    } catch (e) {
      print("Error fetching puzzle ID: $e");
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
        print("Puzzle with ID $puzzleId does not exist.");
        return null;
      }

      final puzzleDocSnap = puzzleQuerySnapshot.docs.first;
      return puzzleDocSnap.data();
    } catch (e) {
      print("Error fetching puzzle  $e");
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
}
