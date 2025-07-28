import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import '../models/video_model.dart';

class VideoProvider with ChangeNotifier {
  final List<VideoModel> _videos = [
    VideoModel(
      title: "Mux Test Stream",
      url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
      thumbnail: "https://via.placeholder.com/320x180?text=Mux+Stream",
    ),
    VideoModel(
      title: "Sintel Movie",
      url: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
      thumbnail: "https://via.placeholder.com/320x180?text=Sintel+Movie",
    ),
    VideoModel(
      title: "Al Jazeera English",
      url: "https://live-hls-web-aje.getaj.net/AJE/01.m3u8",
      thumbnail: "https://via.placeholder.com/320x180?text=Al+Jazeera",
    ),
    VideoModel(
      title: "RT News Stream",
      url: "https://rt-glb.rttv.com/live/rtnews/playlist.m3u8",
      thumbnail: "https://via.placeholder.com/320x180?text=RT+News",
    ),
    VideoModel(
      title: "Apple HLS Test",
      url:
          "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8",
      thumbnail: "https://via.placeholder.com/320x180?text=Apple+HLS",
    ),
  ];

  final Set<int> _loadedVideos = {};
  final Map<int, String> _videoStates = {};
  final Map<int, BetterPlayerController> _videoControllers = {};

  List<VideoModel> get videos => _videos;
  Set<int> get loadedVideos => _loadedVideos;
  Map<int, String> get videoStates => _videoStates;

  void setController(int index, BetterPlayerController controller) {
    _videoControllers[index] = controller;
     notifyListeners();
  }

  BetterPlayerController? getController(int index) => _videoControllers[index];

  void markVideoAsLoaded(int index) {
    if (!_loadedVideos.contains(index)) {
      _loadedVideos.add(index);
     notifyListeners();
    }
  }

  void updateVideoState(int index, String state) {
    if (_videoStates[index] != state) {
      _videoStates[index] = state;
      notifyListeners();
    }
  }

  bool isVideoLoaded(int index) {
    return _loadedVideos.contains(index);
  }

  String getVideoState(int index) {
    return _videoStates[index] ?? 'idle';
  }

  void disposeVideo(int index) {
    if (_videoControllers.containsKey(index)) {
      _videoControllers[index]?.dispose();
      _videoControllers.remove(index);
    }
    _loadedVideos.remove(index);
    _videoStates.remove(index);
    // notifyListeners();
  }

  void pauseAllVideosExcept(int exceptIndex) {
    _videoControllers.forEach((i, controller) {
      if (i != exceptIndex && (controller.isPlaying() ?? false)) {
        controller.pause();
        updateVideoState(i, 'paused');
      }
    });
  }

  void disposeAllVideos() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    _videoStates.clear();
    _loadedVideos.clear();
   // notifyListeners();
  }
}