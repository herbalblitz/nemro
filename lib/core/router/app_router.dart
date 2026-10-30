import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nemro/core/constants/app_constants.dart';
import 'package:nemro/core/preferences/preferences_providers.dart';
import 'package:nemro/features/about/about_screen.dart';
import 'package:nemro/features/home/home_screen.dart';
import 'package:nemro/features/insights/insights_screen.dart';
import 'package:nemro/features/lab/lab_screen.dart';
import 'package:nemro/features/learn/learn_screen.dart';
import 'package:nemro/features/live/live_screen.dart';
import 'package:nemro/features/onboarding/onboarding_screen.dart';
import 'package:nemro/features/practice/practice_screen.dart';
import 'package:nemro/features/privacy/privacy_screen.dart';
import 'package:nemro/features/settings/settings_screen.dart';
import 'package:nemro/features/shell/home_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);

  bool onboardingComplete() =>
      prefs.getBool(AppConstants.prefOnboardingComplete) ?? false;

  final router = GoRouter(
    initialLocation: onboardingComplete() ? '/' : '/onboarding',
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == '/onboarding';
      final done = onboardingComplete();

      if (!done && !isOnboarding) return '/onboarding';
      if (done && isOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            HomeShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/insights',
            builder: (context, state) => const InsightsScreen(),
          ),
          GoRoute(
            path: '/learn',
            builder: (context, state) => const LearnScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(path: '/lab', builder: (context, state) => const LabScreen()),
      GoRoute(path: '/live', builder: (context, state) => const LiveScreen()),
      GoRoute(
        path: '/practice',
        builder: (context, state) => const PracticeScreen(),
      ),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
