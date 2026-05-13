import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/gesture_item.dart';

class TutorialScreen extends ConsumerWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.comoSeJuega,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.fuchsiaAccent,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              GestureItem(
                icon: Icons.swipe,
                description: AppStrings.swipeGesture,
              ),
              const SizedBox(height: 16),
              GestureItem(
                icon: Icons.bookmark,
                description: AppStrings.guardarGesture,
              ),
              const SizedBox(height: 16),
              GestureItem(
                icon: Icons.casino,
                description: AppStrings.comodinGesture,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go('/onboarding/ready'),
                child: Text(AppStrings.entendido),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
