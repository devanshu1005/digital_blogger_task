import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class CustomVideoControls extends StatefulWidget {
  final BetterPlayerController controller;
  final Function(bool) onVisibilityChanged;

  const CustomVideoControls({
    super.key,
    required this.controller,
    required this.onVisibilityChanged,
  });

  @override
  State<CustomVideoControls> createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<CustomVideoControls> {
  bool _isVisible = true;
  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _currentSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addEventsListener(_onPlayerEvent);
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    if (!mounted) return;

    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.play:
        setState(() => _isPlaying = true);
        break;
      case BetterPlayerEventType.pause:
        setState(() => _isPlaying = false);
        break;
      case BetterPlayerEventType.bufferingStart:
        setState(() => _isBuffering = true);
        break;
      case BetterPlayerEventType.bufferingEnd:
        setState(() => _isBuffering = false);
        break;
      case BetterPlayerEventType.progress:
        if (event.parameters != null) {
          final position = event.parameters!['progress'] as Duration?;
          final duration = event.parameters!['duration'] as Duration?;
          if (position != null && duration != null) {
            setState(() {
              _position = position;
              _duration = duration;
            });
          }
        }
        break;
      default:
        break;
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
  }

  void _onSeek(double value) {
    final newPosition = Duration(
      milliseconds: (value * _duration.inMilliseconds).round(),
    );
    widget.controller.seekTo(newPosition);
  }

  void _toggleControlsVisibility() {
    setState(() => _isVisible = !_isVisible);
    widget.onVisibilityChanged(_isVisible);
  }

  void _changeSpeed(double speed) {
    setState(() => _currentSpeed = speed);
    widget.controller.setSpeed(speed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Speed set to ${speed}x'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.black87,
      ),
    );
  }

  void _changeQuality(String quality) {
    final tracks = widget.controller.betterPlayerAsmsTracks;

    if (quality == "Auto") {
      widget.controller.setTrack(BetterPlayerAsmsTrack.defaultTrack());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Switched to Auto quality'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.black87,
        ),
      );
      return;
    }

    final resolution = int.tryParse(quality.replaceAll(RegExp(r'[^0-9]'), ''));

    if (resolution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid quality format: $quality'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final selectedTrack = tracks?.firstWhere(
      (track) => track.height == resolution,
      orElse: () => BetterPlayerAsmsTrack.defaultTrack(),
    );

    if (selectedTrack != null) {
      widget.controller.setTrack(selectedTrack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to $quality (${selectedTrack.height}p)'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.black87,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quality $quality not available'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool _isHlsStream() {
    final dataSource = widget.controller.betterPlayerDataSource;
    if (dataSource?.url != null) {
      return dataSource!.url!.contains('.m3u8');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControlsVisibility,
      onDoubleTap: _togglePlayPause,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            if (_isBuffering)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),

            if (_isVisible)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: PopupMenuButton<double>(
                              icon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.speed,
                                        color: Colors.white, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_currentSpeed}x',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              tooltip: 'Playback Speed',
                              onSelected: _changeSpeed,
                              color: Colors.grey.shade800,
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 0.5,
                                  child: Text('0.5x',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                const PopupMenuItem(
                                  value: 0.75,
                                  child: Text('0.75x',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                const PopupMenuItem(
                                  value: 1.0,
                                  child: Text('1.0x (Normal)',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                const PopupMenuItem(
                                  value: 1.25,
                                  child: Text('1.25x',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                const PopupMenuItem(
                                  value: 1.5,
                                  child: Text('1.5x',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                const PopupMenuItem(
                                  value: 2.0,
                                  child: Text('2.0x',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),

                          if (_isHlsStream())
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: PopupMenuButton<String>(
                                icon: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.high_quality,
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        'HD',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                tooltip: 'Video Quality',
                                onSelected: _changeQuality,
                                color: Colors.grey.shade800,
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'Auto',
                                    child: Text('Auto',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  const PopupMenuItem(
                                    value: '1080p',
                                    child: Text('1080p',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  const PopupMenuItem(
                                    value: '720p',
                                    child: Text('720p',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  const PopupMenuItem(
                                    value: '480p',
                                    child: Text('480p',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  const PopupMenuItem(
                                    value: '360p',
                                    child: Text('360p',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  const PopupMenuItem(
                                    value: '240p',
                                    child: Text('240p',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (widget.controller.isFullScreen)
                      Flexible(
                        child: Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),

                    Container(
                      padding: const EdgeInsets.only(top: 30),
                      child: Column(
                        children: [
                           if (widget.controller.isFullScreen == false)
                           SizedBox(height: 30,),
                          Row(
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: _duration.inMilliseconds > 0
                                      ? _position.inMilliseconds /
                                          _duration.inMilliseconds
                                      : 0.0,
                                  onChanged: _onSeek,
                                  activeColor: Colors.red,
                                  inactiveColor: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                           if (widget.controller.isFullScreen)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () {
                                  final newPosition =
                                      _position - const Duration(seconds: 10);
                                  widget.controller.seekTo(
                                    newPosition.isNegative
                                        ? Duration.zero
                                        : newPosition,
                                  );
                                },
                                icon: const Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  final newPosition =
                                      _position + const Duration(seconds: 10);
                                  widget.controller.seekTo(
                                    newPosition > _duration
                                        ? _duration
                                        : newPosition,
                                  );
                                },
                                icon: const Icon(
                                  Icons.forward_10,
                                  color: Colors.white,
                                ),
                              ),

                              IconButton(
                                onPressed: () =>
                                    widget.controller.toggleFullScreen(),
                                icon: const Icon(
                                  Icons.fullscreen_exit,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeEventsListener(_onPlayerEvent);
    super.dispose();
  }
}
