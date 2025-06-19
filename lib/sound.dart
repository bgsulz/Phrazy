// Remove the soundpool import
// import 'package:soundpool/soundpool.dart';

import '../data/web_storage/web_storage.dart';
import '../utility/debug.dart';
// Add flutter_soloud imports
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter/foundation.dart'; // Required for kIsWeb

// Remove Soundpool pool = Soundpool.fromOptions();
// Replace the soundIds map to store AudioSource objects
final soundIds = <String, AudioSource>{};
bool soundsInitialized = false;

final Map<String, double> _soundVolumes = {
  'click': 1.0,
  'drop': 1.0,
  'win': 0.75,
  'rollover': 0.125,
  'link': 0.5,
};

Future<void> loadSounds() async {
  if (WebStorage.isSafari) {
    debug(
      "Safari detected. flutter_soloud handles web audio context activation.",
    );
  }

  try {
    const loadMode = kIsWeb ? LoadMode.disk : LoadMode.memory;

    await Future.wait([
      SoLoud.instance
          .loadUrl("audio/click_003.ogg", mode: loadMode)
          .then((source) {
        soundIds['click'] = source;
      }),
      SoLoud.instance
          .loadUrl("audio/click1.ogg", mode: loadMode)
          .then((source) {
        soundIds['drop'] = source;
      }),
      SoLoud.instance
          .loadUrl("audio/phrazy_win_2.ogg", mode: loadMode)
          .then((source) {
        soundIds['win'] = source;
      }),
      SoLoud.instance
          .loadUrl("audio/rollover4.ogg", mode: loadMode)
          .then((source) {
        soundIds['rollover'] = source;
      }),
      SoLoud.instance
          .loadUrl("audio/switch16.ogg", mode: loadMode)
          .then((source) {
        soundIds['link'] = source;
      }),
    ]);
  } catch (e) {
    debug("Error loading sounds with flutter_soloud: $e");
    rethrow;
  }

  soundsInitialized = true;
}

void playSound(String key) {
  if (!soundsInitialized) {
    debug("Sounds not initialized. Cannot play sound '$key'.");
    return;
  }

  if (WebStorage.isMuted) {
    return;
  }

  playSoundAsync(key);
}

Future<SoundHandle?> playSoundAsync(String key) async {
  final AudioSource? audioSource = soundIds[key];

  if (audioSource != null) {
    final double volume = _soundVolumes[key] ?? 1.0;
    return await SoLoud.instance.play(audioSource, volume: volume);
  } else {
    debug("Sound key '$key' not found in soundIds map.");
  }
  return null;
}
