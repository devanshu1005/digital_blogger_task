import 'package:digital_blogger_task/providers/video_provider.dart';
import 'package:digital_blogger_task/utils/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LiveVideoScreen extends StatelessWidget {
  const LiveVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<VideoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Live HLS Streaming")),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: videoProvider.videos.length,
        itemBuilder: (context, index) {
          final video = videoProvider.videos[index];
          return VideoPlayerWidget(url: video.url, title: video.title);
        },
      ),
    );
  }
}