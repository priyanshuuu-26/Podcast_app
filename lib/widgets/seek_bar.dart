import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

// A helper class to hold the combined data from position and duration streams
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  const PositionData(this.position, this.bufferedPosition, this.duration);
}

class SeekBar extends StatefulWidget {
  final AudioPlayer audioPlayer;
  const SeekBar({super.key, required this.audioPlayer});

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  // Stream that combines position, buffered position, and duration
  Stream<PositionData> get _positionDataStream =>
      Stream.periodic(const Duration(milliseconds: 200), (_) {
        return PositionData(
          widget.audioPlayer.position,
          widget.audioPlayer.bufferedPosition,
          widget.audioPlayer.duration ?? Duration.zero,
        );
      });
  
  // A helper function to format duration into a readable string
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PositionData>(
      stream: _positionDataStream,
      builder: (context, snapshot) {
        final positionData = snapshot.data ?? const PositionData(Duration.zero, Duration.zero, Duration.zero);
        final position = positionData.position;
        final duration = positionData.duration;
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              min: 0.0,
              max: duration.inMilliseconds.toDouble() + 1.0, // Add 1 to avoid max <= min error
              value: min(position.inMilliseconds.toDouble(), duration.inMilliseconds.toDouble()),
              onChanged: (value) {
                widget.audioPlayer.seek(Duration(milliseconds: value.round()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position)),
                  Text(_formatDuration(duration)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}