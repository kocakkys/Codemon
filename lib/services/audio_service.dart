import 'package:audioplayers/audioplayers.dart';

class GameAudio {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String file) async {
    try {
      await _player.stop();

      await _player.play(AssetSource('audio/$file'));
    } catch (_) {}
  }

  static Future<void> click() {
    return play('click.wav');
  }

  static Future<void> countdown() {
    return play('countdown.wav');
  }

  static Future<void> correct() {
    return play('correct.wav');
  }

  static Future<void> wrong() {
    return play('wrong.wav');
  }

  static Future<void> attack() {
    return play('attack.wav');
  }

  static Future<void> victory() {
    return play('victory.wav');
  }

  static Future<void> defeat() {
    return play('defeat.wav');
  }
}
