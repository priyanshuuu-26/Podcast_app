import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;

  // Play a podcast from a URL
  Future<void> play(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  // Pause the podcast
  void pause() {
    _audioPlayer.pause();
  }

  // Stop the podcast
  void stop() {
    _audioPlayer.stop();
  }

  // Dispose of the player when it's no longer needed
  void dispose() {
    _audioPlayer.dispose();
  }
}