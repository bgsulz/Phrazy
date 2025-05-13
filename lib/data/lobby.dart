import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phrazy/state/state.dart';
import 'package:phrazy/utility/debug.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      debug('Error signing in anonymously: $e');
      return null;
    }
  }
}

class Lobby {
  static Future<void> saveToLobby(
      GameState state, String lobbyName, String myName) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final AuthService auth = AuthService();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      user = await auth.signInAnonymously();
      if (user == null) {
        throw Exception('Failed to authenticate');
      }
    }

    lobbyName = lobbyName.replaceAll(" ", "").toLowerCase();

    await firestore
        .doc("lobbies/$lobbyName/scores/${state.loadedPuzzle.remoteId}")
        .set(
      {
        myName: state.time,
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  static Future<Map<String, int>?> getScoreboard(
      String lobbyName, int puzzleId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await firestore.doc("lobbies/$lobbyName/scores/$puzzleId").get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        return null;
      }

      return _parseScoreboardData(data);
    } else {
      return {};
    }
  }

  static Map<String, int> _parseScoreboardData(Map<String, dynamic> data) {
    Map<String, int> result = {};
    data.forEach((key, value) {
      int? parsedValue = _tryParseInt(value);
      if (parsedValue != null) {
        result[key] = parsedValue;
      }
    });
    return result;
  }

  static int? _tryParseInt(dynamic value) {
    return value is int
        ? value
        : value is String
            ? int.tryParse(value)
            : null;
  }
}
