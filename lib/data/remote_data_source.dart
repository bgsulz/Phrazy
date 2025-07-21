import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:phrazy/core/ext_ymd.dart';
import 'package:phrazy/core/puzzle_loader.dart';
import 'package:phrazy/data/lobby.dart';
import 'package:phrazy/data/puzzle.dart';
import 'package:phrazy/data/tail.dart';
import 'package:phrazy/game/phrase_validator.dart';
import 'package:phrazy/stats/t_digest.dart';
import 'package:phrazy/utility/debug.dart';

class RemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches the core puzzle data from Firebase for a given date.
  Future<Puzzle> fetchPuzzleForDate(DateTime date) async {
    final puzzleLoader = PuzzleLoader<Puzzle>(
      dailiesCollectionName: "dailies",
      puzzlesCollectionName: "puzzles",
      fromFirebase: Puzzle.fromFirebase,
    );

    try {
      final puzzleId = await puzzleLoader.getPuzzleIdForDate(date);
      if (puzzleId == null) {
        debug("Puzzle ID for $date not found. Returning empty puzzle.");
        return Puzzle.empty();
      }

      final puzzleData = await puzzleLoader.getPuzzleData(puzzleId);
      if (puzzleData == null) {
        debug(
            "Puzzle data for ID $puzzleId not found. Returning empty puzzle.");
        return Puzzle.empty();
      }

      return puzzleLoader.fromFirebase(puzzleData, puzzleId);
    } on FirebaseException catch (f) {
      debug("Firebase error fetching puzzle for date: $f");
      return Puzzle.empty();
    }
  }

  /// Fetches the phrase interactions for a specific puzzle and returns a validator.
  Future<PhraseValidator> fetchPhraseValidator(Puzzle puzzle) async {
    if (puzzle.bundledInteractions != null) {
      return PhraseValidator(puzzle.bundledInteractions!);
    }

    try {
      final PhraseMap phraseMap = {};
      final collection = _firestore.collection("phrases");

      final queryResults = await Future.wait(
          puzzle.words.map((word) => collection.doc(word).get()));

      for (var result in queryResults) {
        final data = result.data();
        if (data == null) continue;

        final head = result.id;
        final tails = data.entries
            .where((e) =>
                (puzzle.connectors?.contains(e.value) ?? false) ||
                ["", " ", "-"].contains(e.value))
            .map((e) => Tail(e.value, e.key));
        phraseMap[head] = tails.toList();
      }

      return PhraseValidator(phraseMap);
    } on FirebaseException catch (e) {
      debug("Firebase error fetching phrases: $e");
      rethrow;
    }
  }

  /// Fetches the T-Digest statistics object for a given date.
  Future<TDigest> fetchDigest(DateTime date) async {
    final dateString = date.toYMD;
    final docRef = _firestore.collection('stats').doc(dateString);

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('digest')) {
          final list = (data['digest'] as List<dynamic>?)?.cast<int>();
          if (list != null) {
            return TDigest.fromBytes(Uint8List.fromList(list));
          }
        }
      }

      // Document doesn't exist or is invalid, create a new one.
      final newDigest = TDigest.merging(compression: 100);
      if (kDebugMode) {
        // Your debug logic for populating stats
      }
      await docRef.set({
        'digest': newDigest.asBytes(),
        'created_at': FieldValue.serverTimestamp(),
      });
      return newDigest;
    } on FirebaseException catch (e) {
      debug('Error accessing T-Digest from Firebase: $e');
      return TDigest.merging(compression: 100);
    }
  }

  /// Saves the T-Digest statistics object for a given date.
  Future<void> saveDigest(TDigest digest, DateTime date) async {
    if (_auth.currentUser == null) {
      await AuthService().signInAnonymously();
    }

    final bytesToSave = digest.asBytes();
    final dateString = date.toYMD;
    final docRef = _firestore.collection('stats').doc(dateString);

    try {
      await docRef.set({
        'digest': bytesToSave,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      debug('Error saving T-Digest to Firebase: $e');
    }
  }
}
