import 'dart:async';
import 'package:digital_blogger_task/providers/video_provider.dart';
import 'package:digital_blogger_task/providers/theme_provider.dart';
import 'package:digital_blogger_task/utils/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LiveVideoScreen extends StatefulWidget {
  const LiveVideoScreen({super.key});

  @override
  State<LiveVideoScreen> createState() => _LiveVideoScreenState();
}

class _LiveVideoScreenState extends State<LiveVideoScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<int> _visibleVideos = {};
  Timer? _scrollDebounce;
  late VideoProvider _videoProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_onScroll);
    });
  }

  void _onScroll() {
    if (_scrollDebounce?.isActive ?? false) return;

    _scrollDebounce = Timer(const Duration(milliseconds: 100), () {
      final videoProvider = Provider.of<VideoProvider>(context, listen: false);
      final screenHeight = MediaQuery.of(context).size.height;

      final newVisibleVideos = <int>{};
      
      for (int i = 0; i < videoProvider.videos.length; i++) {
        final itemHeight = 300.0;
        final itemTop = i * itemHeight;
        final itemBottom = itemTop + itemHeight;

        final isVisible = itemBottom >= _scrollController.offset &&
            itemTop <= _scrollController.offset + screenHeight;

        if (isVisible) {
          newVisibleVideos.add(i);
        }
      }

      if (mounted) {
          _visibleVideos
            ..removeWhere((index) => !newVisibleVideos.contains(index))
            ..addAll(newVisibleVideos);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _videoProvider = Provider.of<VideoProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _videoProvider.disposeAllVideos();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live HLS Streaming"),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: themeProvider.isDarkMode
                ? [
                    const Color(0xFF1E1E1E),
                    const Color(0xFF121212),
                  ]
                : [
                    Colors.grey.shade50,
                    Colors.white,
                  ],
          ),
        ),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: videoProvider.videos.length,
          cacheExtent: 600,
          itemBuilder: (context, index) {
            final video = videoProvider.videos[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: VisibilityDetector(
                key: Key("video_$index"),
                onVisibilityChanged: (info) {
                  final visible = info.visibleFraction > 0.3;
                  if (mounted) {
                      if (visible) {
                        _visibleVideos.add(index);
                      } else {
                        _visibleVideos.remove(index);
                      }
                  }
                },
                child: VideoPlayerWidget(
                  url: video.url,
                  title: video.title,
                  index: index,
                  thumbnail: video.thumbnail,
                  // isVisible: _visibleVideos.contains(index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}