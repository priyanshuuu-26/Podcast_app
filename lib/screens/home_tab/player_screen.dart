import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:podcast_app/models/model.dart';
import 'package:podcast_app/services/api_service.dart';
import 'package:podcast_app/services/audio_service.dart';
import 'package:podcast_app/services/storage_service.dart';
import 'package:podcast_app/widgets/seek_bar.dart';

class PlayerScreen extends StatefulWidget {
  final Podcast podcast;
  const PlayerScreen({super.key, required this.podcast});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    final rssUrl = widget.podcast.audioUrl;
    final audioUrl = await _apiService.getAudioUrlFromRss(rssUrl);

    if (audioUrl != null && mounted) {
      _storageService.addToListened(widget.podcast);
      try {
        await _audioPlayerService.audioPlayer.setUrl(audioUrl);
      } catch (e) {
        if (mounted) setState(() => _errorMessage = "Error loading audio.");
      }
    } else if (mounted) {
      setState(() => _errorMessage = "Could not find a playable audio file.");
    }
  }

  @override
  void dispose() {
    _audioPlayerService.dispose();
    super.dispose();
  }

  /// Jumps the playback position by the given duration (delta).
  void _seek(Duration delta) {
    final newPosition = _audioPlayerService.audioPlayer.position + delta;
    // Add a check to prevent seeking to a negative position.
    if (newPosition < Duration.zero) {
      // If the new position is negative, seek to the beginning.
      _audioPlayerService.audioPlayer.seek(Duration.zero);
    } else {
      // Otherwise, seek to the calculated position.
      _audioPlayerService.audioPlayer.seek(newPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.podcast.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                widget.podcast.imageUrl,
                width: 250,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.podcasts, size: 250),
              ),
              const SizedBox(height: 20),
              Text(
                widget.podcast.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.podcast.author,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey.shade400),
              ),
              const SizedBox(height: 20),
              if (_errorMessage == null)
                SeekBar(audioPlayer: _audioPlayerService.audioPlayer),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center)
              else
                _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the row of player controls.
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10),
          iconSize: 42.0,
          onPressed: () => _seek(const Duration(seconds: -10)),
        ),
        const SizedBox(width: 24),
        _buildPlayPauseButton(),
        const SizedBox(width: 24),
        IconButton(
          icon: const Icon(Icons.forward_10),
          iconSize: 42.0,
          onPressed: () => _seek(const Duration(seconds: 10)),
        ),
      ],
    );
  }

  /// Builds the play/pause button based on the player's real-time state.
  Widget _buildPlayPauseButton() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayerService.audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.idle) {
          return const CircularProgressIndicator();
        }

        if (playing == true) {
          return IconButton(
            icon: const Icon(Icons.pause_circle_filled),
            iconSize: 64.0,
            onPressed: _audioPlayerService.pause,
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.play_circle_filled),
            iconSize: 64.0,
            onPressed: () => _audioPlayerService.audioPlayer.play(),
          );
        }
      },
    );
  }
}