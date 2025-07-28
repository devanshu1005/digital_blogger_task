import 'package:flutter/material.dart';
import 'package:digital_blogger_task/themes/app_colors.dart';
import 'package:digital_blogger_task/themes/app_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final RemoteMessage? initialMessage;
  const SplashScreen({Key? key, this.initialMessage}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _initAnimations();

    _startAnimations();

    _handleNavigation(); 
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _pulseController.repeat(reverse: true);
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 3)); // Allow splash animation to play

    final data = widget.initialMessage?.data;
    final screen = data?['screen'];

    if (screen == 'notification-test') {
      Navigator.pushReplacementNamed(context, '/notification-test');
    } else if (screen == 'video') {
      Navigator.pushReplacementNamed(context, '/video-stream');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              Color(0xFF2D1B69),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundPattern(),
            _buildContent(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value * 0.1,
            child: CustomPaint(
              painter: PatternPainter(),
              size: Size.infinite,
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_circle_filled,
                        size: 80,
                        color: AppColors.secondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'StreamLive',
                style: AppFonts.headlineLarge.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'HD Video Streaming',
                style: AppFonts.body.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: AppFonts.caption.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              height: 2,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Powered by BetterPlayer',
              style: AppFonts.caption.copyWith(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 60, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 80, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
