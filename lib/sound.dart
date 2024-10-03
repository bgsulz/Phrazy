import 'package:soundpool/soundpool.dart';

Soundpool pool = Soundpool.fromOptions();
final soundIds = <String, int>{};

Future<void> loadSounds() async {
  try {
    soundIds['click'] = await pool.loadUri("/audio/click_003.ogg");
    soundIds['drop'] = await pool.loadUri("/audio/click1.ogg");
    soundIds['win'] = await pool.loadUri("/audio/confirmation_001.ogg");
    soundIds['rollover'] = await pool.loadUri("/audio/rollover4.ogg");

    pool.setVolume(soundId: soundIds['rollover'], volume: 0.25);
  } catch (e) {
    print(e);
    rethrow;
  }
}

Future<int> playSound(String key) async {
  return await pool.play(soundIds[key]!);
}
