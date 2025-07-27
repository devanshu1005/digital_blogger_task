import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _navigateToLiveVideo(BuildContext context) {
    Navigator.pushNamed(context, '/video-stream');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _navigateToLiveVideo(context),
          child: const Text('Go to Live Video'),
        ),
      ),
    );
  }
}
