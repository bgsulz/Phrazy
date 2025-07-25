import 'package:flutter/foundation.dart';
import 'package:phrazy/data/web_storage/web_storage.dart';

class SettingsNotifier extends ChangeNotifier {
  SettingsNotifier() {
    _isMuted = WebStorage.isMuted;
  }

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  void toggleMute([bool? value]) {
    WebStorage.toggleMute(value);
    _isMuted = WebStorage.isMuted;
    notifyListeners();
  }
}
