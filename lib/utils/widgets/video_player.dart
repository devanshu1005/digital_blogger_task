import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../providers/video_provider.dart';
import 'custom_video_controls.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final String title;
  final int index;
  final String? thumbnail;
  final bool isVisible;

  const VideoPlayerWidget({
    super.key,
    required this.url,
    required this.title,
    required this.index,
    this.thumbnail,
    this.isVisible = true,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with AutomaticKeepAliveClientMixin {
  BetterPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoading = false;
  bool _showTapHint = true;
  late final VideoProvider _videoProvider;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _videoProvider = Provider.of<VideoProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showTapHint = false);
      }
    });
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !_isInitialized && !_isLoading) {
      _initializePlayer();
    } else if (!widget.isVisible && _isInitialized) {
      _pauseAndStopOthers();
    }
  }

  void _pauseAndStopOthers() {
    _controller?.pause();
    _videoProvider.pauseAllVideosExcept(widget.index);
  }

  void _playAndStopOthers() {
    _videoProvider.pauseAllVideosExcept(widget.index);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _controller != null) {
        _controller!.play();
      }
    });
  }

  Future<void> _initializePlayer() async {
    if (_isInitialized || _isLoading || !mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final isLiveStream = widget.url.contains('.m3u8');

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.url,
        liveStream: isLiveStream,
        videoFormat: isLiveStream
            ? BetterPlayerVideoFormat.hls
            : BetterPlayerVideoFormat.other,
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
          minBufferMs: 1500,
          maxBufferMs: 8000,
          bufferForPlaybackMs: 500,
          bufferForPlaybackAfterRebufferMs: 1000,
        ),
        cacheConfiguration: isLiveStream
            ? null
            : const BetterPlayerCacheConfiguration(
                useCache: true,
                preCacheSize: 10 * 1024 * 1024,
                maxCacheSize: 100 * 1024 * 1024,
                maxCacheFileSize: 50 * 1024 * 1024,
              ),
      );

      final controller = BetterPlayerController(
        BetterPlayerConfiguration(
          aspectRatio: 16 / 9,
          autoPlay: true,
          looping: false,
          allowedScreenSleep: false,
          showPlaceholderUntilPlay: false,
          placeholder: _buildPlaceholder(),
          autoDetectFullscreenDeviceOrientation: true,
          autoDetectFullscreenAspectRatio: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enablePlaybackSpeed: true,
            enableQualities: true,
            enableFullscreen: true,
            showControlsOnInitialize: false,
            controlsHideTime: const Duration(seconds: 3),
            progressBarPlayedColor: Colors.red,
            progressBarHandleColor: Colors.red,
            enablePlayPause: true,
            enableMute: true,
            enableOverflowMenu: false,
            playerTheme: BetterPlayerTheme.custom,
            customControlsBuilder: (controller, onPlayerVisibilityChanged) {
              return CustomVideoControls(
                controller: controller,
                onVisibilityChanged: onPlayerVisibilityChanged,
              );
            },
          ),
          errorBuilder: (context, errorMessage) =>
              _buildErrorWidget(errorMessage),
          eventListener: _onPlayerEvent,
          deviceOrientationsOnFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
          ],
          handleLifecycle: true,
        ),
      );

      controller.addEventsListener(_onPlayerEvent);
      await controller.setupDataSource(dataSource);

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
        _videoProvider.setController(widget.index, controller);
        _playAndStopOthers();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load video: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    if (!mounted) return;

    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _hasError = false;
        });
        _videoProvider.updateVideoState(widget.index, 'initialized');
        break;

      case BetterPlayerEventType.exception:
        setState(() {
          _hasError = true;
          _errorMessage = 'Playback error occurred';
          _isLoading = false;
        });
        _videoProvider.updateVideoState(widget.index, 'error');
        break;

      case BetterPlayerEventType.bufferingEnd:
        if (!(_controller?.isPlaying() ?? false)) {
          _playAndStopOthers();
        }
        break;

      default:
        break;
    }
  }

  Future<void> _retry() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _isInitialized = false;
    });

    _controller?.dispose();
    _controller = null;

    await _initializePlayer();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black12,
      child: widget.thumbnail != null
          ? Image.network(
              widget.thumbnail!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.play_circle_outline,
                size: 64,
                color: Colors.white70,
              ),
            )
          : const Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white70,
            ),
    );
  }

  Widget _buildErrorWidget(String? errorMessage) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Playback Error',
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                errorMessage ?? _errorMessage,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return VisibilityDetector(
      key: Key('video-${widget.index}'),
      onVisibilityChanged: (visibilityInfo) {
        final visibleFraction = visibilityInfo.visibleFraction;
        if (!mounted) return;

        if (visibleFraction > 0.7) {
          if (!_isInitialized && !_isLoading) {
            _initializePlayer();
          } else if (_controller != null &&
              !(_controller!.isPlaying() ?? false)) {
            _playAndStopOthers();
          }
        } else {
          _controller?.pause();
        }
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Stream #${widget.index + 1}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.url.contains('.m3u8'))
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildVideoContent(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Format: ${widget.url.contains('.m3u8') ? 'HLS' : 'MP4'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  Row(
                    children: [
                      if (_controller != null && _isInitialized)
                        PopupMenuButton<double>(
                          icon: const Icon(Icons.speed, size: 20),
                          tooltip: 'Playback Speed',
                          onSelected: (speed) {
                            _controller!.setSpeed(speed);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Speed set to ${speed}x'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 0.5, child: Text('0.5x')),
                            const PopupMenuItem(
                                value: 0.75, child: Text('0.75x')),
                            const PopupMenuItem(
                                value: 1.0, child: Text('1.0x (Normal)')),
                            const PopupMenuItem(
                                value: 1.25, child: Text('1.25x')),
                            const PopupMenuItem(
                                value: 1.5, child: Text('1.5x')),
                            const PopupMenuItem(
                                value: 2.0, child: Text('2.0x')),
                          ],
                        ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _retry,
                        iconSize: 20,
                        tooltip: 'Refresh',
                      ),
                      if (_controller != null && _isInitialized)
                        IconButton(
                          icon: const Icon(Icons.fullscreen),
                          onPressed: () {
                            final wasPlaying =
                                _controller!.isPlaying() ?? false;
                            _controller!.toggleFullScreen();
                            if (wasPlaying) {
                              Future.delayed(const Duration(milliseconds: 500),
                                  () => _controller?.play());
                            }
                          },
                          iconSize: 20,
                          tooltip: 'Fullscreen',
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) return _buildErrorWidget(_errorMessage);
    if (_isLoading || !_isInitialized || _controller == null)
      return _buildLoadingWidget();

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(controller: _controller!),
        ),
        if (_showTapHint)
          Positioned(
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Double tap to Play/Pause',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _videoProvider.disposeVideo(widget.index);
    _controller?.removeEventsListener(_onPlayerEvent);
    _controller?.dispose();
    super.dispose();
  }
}
