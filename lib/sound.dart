import '../data/web_storage/web_storage.dart';
import '../utility/debug.dart';
import 'package:soundpool/soundpool.dart';

Soundpool pool = Soundpool.fromOptions();
final soundIds = <String, int>{};
bool soundsInitialized = false;

Future<void> loadSounds() async {
  if (WebStorage.isSafari) {
    debug("Safari detected.");
    await Future.delayed(const Duration(seconds: 0));
    return;
  }

  try {
    soundIds['click'] = await pool.loadUri("/audio/click_003.ogg");
    soundIds['drop'] = await pool.loadUri("/audio/click1.ogg");
    soundIds['win'] = await pool.loadUri("/audio/phrazy_win_2.ogg");
    soundIds['rollover'] = await pool.loadUri("/audio/rollover4.ogg");
    soundIds['link'] = await pool.loadUri("/audio/switch16.ogg");

    pool.setVolume(soundId: soundIds['link'], volume: 0.5);
    pool.setVolume(soundId: soundIds['rollover'], volume: 0.125);
    pool.setVolume(soundId: soundIds['win'], volume: 0.75);
  } catch (e) {
    debug(e);
    rethrow;
  }

  soundsInitialized = true;
}

void playSound(String key) {
  if (!soundsInitialized) {
    return;
  }

  if (WebStorage.isMuted) {
    return;
  }

  playSoundAsync(key);
}

Future<int> playSoundAsync(String key) async {
  if (soundIds.containsKey(key) && soundIds[key] != null) {
    return await pool.play(soundIds[key]!);
  }
  return -1;
}
