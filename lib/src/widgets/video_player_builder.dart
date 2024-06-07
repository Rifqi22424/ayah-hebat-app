import 'package:ayahhebat/src/consts/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerBuilder extends StatefulWidget {
  final String url;
  const VideoPlayerBuilder({super.key, required this.url});

  @override
  State<VideoPlayerBuilder> createState() => VideoPlayerBuilderState();
}

class VideoPlayerBuilderState extends State<VideoPlayerBuilder> {
  late VideoPlayerController _controller;
  late Future<void> _initializedVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _initializedVideoPlayerFuture = _controller.initialize().then((value) {
      setState(() {});
    });
    _controller.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializedVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryColor,
                    child: IconButton(
                        onPressed: onPressed,
                        icon: _controller.value.isPlaying
                            ? const Icon(
                                Icons.pause,
                                color: AppColors.whiteColor,
                              )
                            : const Icon(Icons.play_arrow,
                                color: AppColors.whiteColor)),
                  ),
                ),
              )
            ],
          );
        } else {
          return const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryColor),
              ),
            ),
          );
        }
      },
    );
  }

  void onPressed() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
