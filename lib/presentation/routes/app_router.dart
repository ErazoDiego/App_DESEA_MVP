import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../domain/entities/carta_personalizada.dart';
import '../../domain/entities/mazo.dart';
import '../providers/perfil_providers.dart';
import '../screens/game/libre_play_screen.dart';
import '../screens/game/libre_screen.dart';
import '../screens/game/mis_cartas_screen.dart';
import '../screens/game/saved_cards_screen.dart';
import '../screens/game/sesion_screen.dart';
import '../screens/home/game_hub_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/age_screen.dart';
import '../screens/onboarding/preferences_screen.dart';
import '../screens/onboarding/ready_screen.dart';
import '../screens/onboarding/tutorial_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../widgets/card_form_widget.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final perfilRepo = ref.watch(perfilRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      try {
        final isOnOnboarding = state.matchedLocation.startsWith('/onboarding');
        final completado = await perfilRepo.hasCompletadoOnboarding();

        if (completado && isOnOnboarding) return '/home';
        if (!completado &&
            !isOnOnboarding &&
            state.matchedLocation != '/') {
          return '/onboarding/welcome';
        }
      } catch (_) {
        // Providers not ready yet — skip redirect
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/onboarding/welcome',
      ),
      GoRoute(
        path: '/onboarding/welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/age',
        builder: (_, __) => const AgeScreen(),
      ),
      GoRoute(
        path: '/onboarding/preferences',
        builder: (_, __) => const PreferencesScreen(),
      ),
      GoRoute(
        path: '/onboarding/tutorial',
        builder: (_, __) => const TutorialScreen(),
      ),
      GoRoute(
        path: '/onboarding/ready',
        builder: (_, __) => const ReadyScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/game-hub',
        builder: (_, __) => const GameHubScreen(),
      ),
      GoRoute(
        path: '/game/sesion/:mazoId',
        builder: (_, state) => SesionScreen(
          mazoId: state.pathParameters['mazoId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/game/guardadas',
        builder: (_, __) => const SavedCardsScreen(),
      ),
      GoRoute(
        path: '/game/mis-cartas',
        builder: (_, __) => const MisCartasScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: Text(AppStrings.misCartasFormEditTitle)),
              body: CardFormWidget(
                existingCard: state.extra as CartaPersonalizada?,
                onSaved: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/game/libre',
        builder: (_, __) => const LibreScreen(),
        routes: [
          GoRoute(
            path: 'play',
            builder: (_, state) => LibrePlayScreen(
              mazo: state.extra as Mazo,
            ),
          ),
        ],
      ),
    ],
  );
});
