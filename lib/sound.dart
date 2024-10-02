import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

final pool = Soundpool.fromOptions();
final soundIds = <String, int>{};

Future<void> loadSounds() async {
  soundIds['click'] = await rootBundle
      .load("assets/click_003.ogg")
      .then((soundData) => pool.load(soundData));
  soundIds['drop'] = await rootBundle
      .load("assets/click1.ogg")
      .then((soundData) => pool.load(soundData));
  soundIds['win'] = await rootBundle
      .load("assets/confirmation_001.ogg")
      .then((soundData) => pool.load(soundData));
  soundIds['rollover'] = await rootBundle
      .load("assets/rollover4.ogg")
      .then((soundData) => pool.load(soundData));
  pool.setVolume(soundId: soundIds['rollover'], volume: 0.25);
}

Future<int> playSound(String key) async {
  return await pool.play(soundIds[key]!);
}
