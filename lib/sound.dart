import 'package:phrazy/data/web_storage.dart';
import 'package:phrazy/utility/debug.dart';
import 'package:soundpool/soundpool.dart';

Soundpool pool = Soundpool.fromOptions();
final soundIds = <String, int>{};

Future<void> loadSounds() async {
  try {
    soundIds['click'] = await pool.loadUri("/audio/click_003.ogg");
    soundIds['drop'] = await pool.loadUri("/audio/click1.ogg");
    soundIds['win'] = await pool.loadUri("/audio/phrazy_win.ogg");
    soundIds['rollover'] = await pool.loadUri("/audio/rollover4.ogg");
    soundIds['link'] = await pool.loadUri("/audio/switch16.ogg");

    pool.setVolume(soundId: soundIds['link'], volume: 0.5);
    pool.setVolume(soundId: soundIds['rollover'], volume: 0.125);
    pool.setVolume(soundId: soundIds['win'], volume: 1.25);
  } catch (e) {
    debug(e);
    rethrow;
  }
}

void playSound(String key) {
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
