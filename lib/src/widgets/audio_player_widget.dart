import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;

  AudioPlayerWidget({required this.audioPath});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  void _initAudioPlayer() async {
    await _audioPlayer.setSourceDeviceFile(widget.audioPath);
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        setState(() {
          isPlaying = true;
        });
      } else {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isPlaying) {
          _audioPlayer.pause();
        } else {
          _audioPlayer.play(UrlSource(widget.audioPath));
        }
      },
      child: Container(
        height: 100,
        width: 100,
        color: Colors.grey[300],
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          size: 50,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
