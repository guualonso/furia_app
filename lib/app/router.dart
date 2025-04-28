import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:furia_app/features/home/home_screen.dart';
import 'package:furia_app/features/matches/matches_screen.dart';
import 'package:furia_app/features/statistics/statistics_screen.dart';
import 'package:furia_app/features/auth/login_screen.dart';
import 'package:furia_app/features/auth/register_screen.dart';

final router = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final loggingInOrRegistering = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    if (!isLoggedIn && !loggingInOrRegistering) {
      return '/login';
    } else if (isLoggedIn && loggingInOrRegistering) {
      return '/home';
    }
    return null; 
  },
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'statistics',
          name: 'statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
        GoRoute(
          path: 'matches',
          name: 'matches',
          builder: (context, state) => const MatchesScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ],
);
