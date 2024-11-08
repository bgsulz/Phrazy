import 'package:phrazy/data/load.dart';
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
    print(e);
    rethrow;
  }
}

void playSound(String key) {
  if (Load.isMuted) {
    return;
  }
  playSoundAsync(key);
}

Future<int> playSoundAsync(String key) async {
  return await pool.play(soundIds[key]!);
}
