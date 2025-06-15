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

// A map to store the desired volume for each sound key
// SoLoud applies volume at the time of playing, not loading.
final Map<String, double> _soundVolumes = {
  'click': 1.0, // Default volume for click
  'drop': 1.0, // Default volume for drop
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
    // For web platforms, LoadMode.disk is generally recommended for performance
    // as it streams directly from the web server. For other platforms, LoadMode.file
    // is efficient.
    const loadMode = kIsWeb ? LoadMode.disk : LoadMode.memory;

    // Load sounds using SoLoud.instance.loadAsset
    // Note: asset paths usually don't start with a leading '/' when used with loadAsset
    soundIds['click'] =
        await SoLoud.instance.loadAsset("audio/click_003.ogg", mode: loadMode);
    soundIds['drop'] =
        await SoLoud.instance.loadAsset("audio/click1.ogg", mode: loadMode);
    soundIds['win'] = await SoLoud.instance
        .loadAsset("audio/phrazy_win_2.ogg", mode: loadMode);
    soundIds['rollover'] =
        await SoLoud.instance.loadAsset("audio/rollover4.ogg", mode: loadMode);
    soundIds['link'] =
        await SoLoud.instance.loadAsset("audio/switch16.ogg", mode: loadMode);

    // With flutter_soloud, volumes are set when the sound is played,
    // not when it's loaded. We've set up the _soundVolumes map for this.
    // The original `pool.setVolume` calls are replaced by passing volume
    // directly to SoLoud.instance.play in playSoundAsync.
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

  // Await is not needed here as playSound is void and we just fire and forget.
  // The actual playing happens in playSoundAsync.
  playSoundAsync(key);
}

// Change the return type from Future<int> to Future<PlayerHandle>
Future<SoundHandle?> playSoundAsync(String key) async {
  final AudioSource? audioSource = soundIds[key];

  if (audioSource != null) {
    // Retrieve the specific volume for this sound, or default to 1.0
    final double volume = _soundVolumes[key] ?? 1.0;
    // Play the sound with the specified volume
    return await SoLoud.instance.play(audioSource, volume: volume);
  } else {
    debug("Sound key '$key' not found in soundIds map.");
  }
  // Return an invalid handle if the sound key is not found
  return null;
}

// Optional: Add a dispose function if your sound manager has a clear lifecycle
// to deinitialize SoLoud when no longer needed (e.g., app shutdown).
// void disposeSoundManager() {
//   SoLoud.instance.deinit();
//   soundsInitialized = false;
//   soundIds.clear();
// }