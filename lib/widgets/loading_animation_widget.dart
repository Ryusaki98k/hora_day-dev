import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart' as loader;

import '../utils/app_colors.dart';

enum LoadingAnimationType {
  staggeredDotsWave,
  twistingDots,
}

/// A reusable loading animation widget that can be embedded into any layout.
class AppLoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? secondaryColor;
  final LoadingAnimationType animationType;
  final String? message;

  const AppLoadingWidget({
    super.key,
    this.size = 50.0,
    this.color,
    this.secondaryColor,
    this.animationType = LoadingAnimationType.staggeredDotsWave,
    this.message,
  });

  /// Factory constructor for twisting dots animation
  const AppLoadingWidget.twistingDots({
    super.key,
    this.size = 50.0,
    this.color = const Color(0xFF1A1A3F),
    this.secondaryColor = const Color(0xFFEA3799),
    this.message,
  }) : animationType = LoadingAnimationType.twistingDots;

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? AppColors.caramelBronze;

    final Widget animation = switch (animationType) {
      LoadingAnimationType.staggeredDotsWave =>
        loader.LoadingAnimationWidget.staggeredDotsWave(
          color: primaryColor,
          size: size,
        ),
      LoadingAnimationType.twistingDots =>
        loader.LoadingAnimationWidget.twistingDots(
          leftDotColor: primaryColor,
          rightDotColor: secondaryColor ?? AppColors.amberGold,
          size: size,
        ),
    };

    if (message == null || message!.isEmpty) {
      return Center(child: animation);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          animation,
          const SizedBox(height: 16),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-page Scaffold displaying the loading animation.
class AppLoadingScreen extends StatelessWidget {
  final Color? backgroundColor;
  final double size;
  final Color? color;
  final Color? secondaryColor;
  final LoadingAnimationType animationType;
  final String? message;

  const AppLoadingScreen({
    super.key,
    this.backgroundColor = AppColors.ivory,
    this.size = 80.0,
    this.color,
    this.secondaryColor,
    this.animationType = LoadingAnimationType.staggeredDotsWave,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: AppLoadingWidget(
        size: size,
        color: color,
        secondaryColor: secondaryColor,
        animationType: animationType,
        message: message,
      ),
    );
  }
}