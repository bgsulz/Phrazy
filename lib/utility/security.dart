import 'dart:convert';
import 'package:crypto/crypto.dart';

class Security {
  static String hashLobbyName(String lobbyName) {
    var bytes = utf8.encode(lobbyName); // Convert string to bytes
    var digest = sha256.convert(bytes); // Hash the bytes
    return digest.toString();
  }

  static String encodePlayerName(String playerName, String lobbyName) {
    String key = lobbyName;
    String encoded = '';
    for (int i = 0; i < playerName.length; i++) {
      encoded += String.fromCharCode(
          playerName.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return encoded;
  }

  static String decodePlayerName(String encodedName, String lobbyName) {
    String key = lobbyName;
    String decoded = '';
    for (int i = 0; i < encodedName.length; i++) {
      decoded += String.fromCharCode(
          encodedName.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return decoded;
  }
}
