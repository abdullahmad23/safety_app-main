// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewDetails extends StatefulWidget {
  const VideoPreviewDetails({Key? key, required this.video}) : super(key: key);
  final dynamic video;
  @override
  State<VideoPreviewDetails> createState() => _VideoPreviewDetailsState();
}

class _VideoPreviewDetailsState extends State<VideoPreviewDetails> {
  late VideoPlayerController _controller;
  bool isShow = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.video)
      ..initialize().then((_) async {
        var time = await _controller.value.duration;
        print(time);
        _controller.addListener(() {
          if (_controller.value.position == time) {
            setState(() {});
          }
        });
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        isShow = true;
        setState(() {});
      });
  }

  // setLandScape() async {
  //   await SystemChrome.setEnabledSystemUIOverlays([]);
  //   await SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.landscapeLeft,
  //     DeviceOrientation.landscapeRight,
  //   ]);
  // }
  //
  // reset() async {
  //   await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  //   await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  // }
  TextEditingController controller = TextEditingController();
  String link = "";
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview"),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Center(child: CircularProgressIndicator()),
          ),
          isShow
              ? Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child: CircleAvatar(
                      radius: 33,
                      backgroundColor: Colors.black26,
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                )
              : SizedBox(),
          Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              )),
        ],
      ),
    );
  }
}
