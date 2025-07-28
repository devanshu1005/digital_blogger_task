import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _navigateToLiveVideo(BuildContext context) {
    Navigator.pushNamed(context, '/video-stream');
  }

  void _navigateToNotificationScreen(BuildContext context) {
    Navigator.pushNamed(context, '/notification-test');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HLS Video Streaming'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _navigateToNotificationScreen(context),
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: themeProvider.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
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
                    Colors.blue.shade50,
                    Colors.white,
                  ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        size: 80,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'HLS Live Streaming',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Experience high-quality video streaming with custom controls, multiple quality options, and seamless playback.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToLiveVideo(context),
                        icon: const Icon(Icons.video_library),
                        label: const Text('Start Streaming'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildFeatureList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final features = [
      '10 Simultaneous Video Streams',
      'Custom Video Controls',
      'Quality Selection (144p - 1080p)',
      'Playback Speed Control',
      'Lazy Loading & Performance',
      'Dark/Light Theme Support',
    ];

    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
