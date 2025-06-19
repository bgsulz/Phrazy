import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Import for Uint8List
import 'package:phrazy/core/ext_ymd.dart';
import 'package:phrazy/data/lobby.dart';
import '../stats/t_digest.dart'; // Import TDigest
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/puzzle_loader.dart';
import '../data/tail.dart';
import '../utility/debug.dart';
import '../data/puzzle.dart';
import '../utility/ext.dart'; // Explicitly ensuring this import is present and correctly placed

typedef PhraseMap = Map<String, List<Tail>>;

class Load {
  static final DateTime startDate = DateTime(2024, 10, 1, 12);
  static DateTime get endDate => DateTime.now()
      .copyWith(hour: 23, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  static int get totalDailies => endDate.difference(startDate).inDays + 1;

  static String path = 'phrases.yaml';
  static PhraseMap _phrases = {};

  final String dailiesCollectionName;
  final String puzzlesCollectionName;

  Load({
    required this.dailiesCollectionName,
    required this.puzzlesCollectionName,
  });

  static Future<PhraseMap> _loadPhrasesForPuzzle(Puzzle puzzle) async {
    if (puzzle.bundledInteractions != null) {
      return Future.value(puzzle.bundledInteractions);
    }

    try {
      final PhraseMap phraseMap = {};
      final firestore = FirebaseFirestore.instance;
      final collection = firestore.collection("phrases");

      final queryResults = await Future.wait(
          puzzle.words.map((word) => collection.doc(word).get()));

      for (var result in queryResults) {
        final data = result.data();
        if (data == null) {
          continue;
        }
        final head = result.id;
        final tails = data.entries
            .where((e) =>
                (puzzle.connectors?.contains(e.value) ?? false) ||
                e.value == "" ||
                e.value == " " ||
                e.value == "-")
            .map((e) => Tail(e.value, e.key));
        phraseMap[head] = tails.toList();
      }

      return phraseMap;
    } on FirebaseException catch (e) {
      debug(e);
      rethrow;
    }
  }

  static Future<Puzzle> puzzle(Puzzle puzzle) async {
    _phrases = await _loadPhrasesForPuzzle(puzzle);
    return puzzle;
  }

  Future<Puzzle> puzzleForDate(DateTime date) async {
    final puzzleLoader = PuzzleLoader<Puzzle>(
      dailiesCollectionName: dailiesCollectionName,
      puzzlesCollectionName: puzzlesCollectionName,
      fromFirebase: Puzzle.fromFirebase,
    );

    try {
      final puzzleId = await puzzleLoader.getPuzzleIdForDate(date);

      if (puzzleId == null) {
        debug("Today's puzzle ID was not found. Returning an empty puzzle.");
        return Puzzle.empty();
      }

      final puzzleData = await puzzleLoader.loadPuzzleForDate(date);

      if (puzzleData == null) {
        debug(
            "Puzzle for ID $puzzleId was not found. Returning an empty puzzle.");
        return Puzzle.empty();
      }

      final puzzle = puzzleLoader.fromFirebase(puzzleData, puzzleId);

      _phrases = await _loadPhrasesForPuzzle(puzzle);
      return puzzle;
    } on FirebaseException catch (f) {
      debug(f);
      return Puzzle.empty();
    }
  }

  static Future<TDigest> digest(DateTime date) async {
    final firestore = FirebaseFirestore.instance;
    final dateString = date.toYMD;
    final docRef = firestore.collection('stats').doc(dateString);

    try {
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('digest')) {
          final list = data['digest'] as List<dynamic>?;
          if (list != null) {
            final listInts = list.cast<int>();
            debug('Loading T-Digest from Firebase for $dateString');
            return TDigest.fromBytes(Uint8List.fromList(listInts));
          }
        }
      }

      // If document doesn't exist or data is missing/invalid, create a new one.
      debug('Creating new T-Digest for $dateString');
      final newDigest =
          TDigest.merging(compression: 100); // Default compression
      if (kDebugMode) {
        debug("ADDING RANDOM TIMES!");
        final random = Random(DateTime.now().millisecondsSinceEpoch % 1234567);
        for (var i = 0; i < 25; i++) {
          final time = random.nextInt(60) + 5;
          debug("ADDING: $time");
          newDigest.add(time as double);
        }
      }
      final bytesToSave = newDigest.asBytes();

      await docRef.set({
        'digest': bytesToSave,
        'created_at': FieldValue.serverTimestamp(),
      });

      return newDigest;
    } on FirebaseException catch (e) {
      debug('Error accessing T-Digest from Firebase: $e');
      return TDigest.merging(compression: 100);
    }
  }

  static Future<void> saveDigest(TDigest digest, DateTime date) async {
    final firestore = FirebaseFirestore.instance;

    final AuthService auth = AuthService();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      user = await auth.signInAnonymously();
      if (user == null) {
        throw Exception('Failed to authenticate');
      }
    }

    final bytesToSave = digest.asBytes();
    final dateString = date.toYMD;
    final docRef = firestore.collection('stats').doc(dateString);

    try {
      await docRef.set({
        'digest': bytesToSave,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to not overwrite other fields
    } on FirebaseException catch (e) {
      debug('Error saving T-Digest to Firebase: $e');
    }
  }

  static Tail isValidPhrase(String a, String b) {
    if (a.isEmpty || b.isEmpty) return Tail.empty;
    var head = a.trim();
    var tail = b.trim();

    if (!_phrases.containsKey(head)) {
      return Tail.fail;
    }
    return _phrases[head]!.firstWhere((t) => t.tail.equalsIgnoreCase(tail),
        orElse: () => Tail.fail);
  }
}
