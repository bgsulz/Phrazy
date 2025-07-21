import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phrazy/game/game_controller.dart';
import 'package:phrazy/utility/debug.dart';
import 'package:phrazy/utility/security.dart';

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
      GameController state, String lobbyName, String myName) async {
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
    String hashedLobbyName = Security.hashLobbyName(lobbyName);
    String encodedMyName = Security.encodePlayerName(myName, lobbyName);

    await firestore
        .doc("lobbies/$hashedLobbyName/scores/${state.loadedPuzzle.remoteId}")
        .set(
      {
        encodedMyName: state.time,
      },
      SetOptions(
        merge: true,
      ),
    );
  }

  static Future<Map<String, int>?> getScoreboard(
      String lobbyName, int puzzleId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String hashedLobbyName = Security.hashLobbyName(lobbyName);
    DocumentSnapshot snapshot =
        await firestore.doc("lobbies/$hashedLobbyName/scores/$puzzleId").get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        return null;
      }

      return _parseScoreboardData(data, lobbyName);
    } else {
      return {};
    }
  }

  static Map<String, int> _parseScoreboardData(
      Map<String, dynamic> data, String lobbyName) {
    Map<String, int> result = {};
    data.forEach((key, value) {
      String decodedKey = Security.decodePlayerName(key, lobbyName);
      int? parsedValue = _tryParseInt(value);
      if (parsedValue != null) {
        result[decodedKey] = parsedValue;
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
