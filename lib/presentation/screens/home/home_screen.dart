import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/gesture_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.fuchsiaAccent,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.tagline,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.statsLine,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceSecondary,
                    ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/game-hub'),
                  child: Text(AppStrings.startNight),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _showHowToPlay(context),
                child: Text(AppStrings.howToPlay),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.howToPlay,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.fuchsiaAccent,
                  ),
            ),
            const SizedBox(height: 16),
            GestureItem(
              icon: Icons.swipe,
              description: AppStrings.swipeGesture,
            ),
            GestureItem(
              icon: Icons.bookmark,
              description: AppStrings.guardarGesture,
            ),
            GestureItem(
              icon: Icons.casino,
              description: AppStrings.comodinGesture,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.modoExplicacion,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
