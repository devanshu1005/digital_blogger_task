import 'package:flutter/material.dart';
import 'package:digital_blogger_task/themes/app_colors.dart';
import 'package:digital_blogger_task/themes/app_fonts.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          "Notification",
          style: AppFonts.title.copyWith(color: AppColors.textOnPrimary),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Notification Icon Container
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(60),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Success Message
                        Text(
                          "Navigation Successful!",
                          style: AppFonts.headlineMedium,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          "You have been successfully navigated from a notification tap. This demonstrates the notification handling functionality.",
                          style: AppFonts.body,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  color: AppColors.info,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Notification Test",
                                      style: AppFonts.title.copyWith(
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Deep link navigation is working correctly",
                                      style: AppFonts.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Actions
              Column(
                children: [
                  // Primary Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/home', (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        "Go Back",
                        style: AppFonts.button,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
