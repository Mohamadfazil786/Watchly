
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/main_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/movies/movie_details_screen.dart';
import '../../features/movies/search_screen.dart';
import '../../features/social/social_feed_screen.dart';
import '../../features/social/profile_screen.dart';
import '../../features/social/user_search_screen.dart';

import '../../features/lists/list_detail_screen.dart';
import '../../features/lists/create_list_screen.dart';
import '../../features/lists/watchlist_screen.dart';
import '../../features/reviews/write_review_screen.dart';
import '../../features/reviews/review_details_screen.dart';
import '../../features/movies/popular_tv_screen.dart';
import '../models/review_model.dart';
import '../../features/ai/ai_screen.dart';
import '../../features/settings/settings_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
    _ref.listen(hasShownSplashProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = ref.read(currentUserProvider) != null;
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isAuth = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == '/';
      final hasShownSplash = ref.read(hasShownSplashProvider);

      if (isSplash) {
        if (hasShownSplash) {
          return isLoggedIn ? '/home' : '/onboarding';
        }
        return null;
      }
      if (!isLoggedIn && !isOnboarding && !isAuth) return '/auth/login';
      if (isLoggedIn && (isOnboarding || isAuth)) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/social',
            builder: (context, state) => const SocialFeedScreen(),
          ),
          GoRoute(
            path: '/lists',
            redirect: (context, state) => '/profile',
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Detail routes outside shell
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) => MovieDetailsScreen(
          mediaId: state.pathParameters['id']!,
          isTv: state.uri.queryParameters['tv'] == 'true',
        ),
      ),
      GoRoute(
        path: '/user/:uid',
        builder: (context, state) => ProfileScreen(uid: state.pathParameters['uid']),
      ),
      GoRoute(
        path: '/users/search',
        builder: (context, state) => const UserSearchScreen(),
      ),
      GoRoute(
        path: '/list/create',
        builder: (context, state) => const CreateListScreen(),
      ),
      GoRoute(
        path: '/list/:id',
        builder: (context, state) => ListDetailScreen(listId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/watchlist',
        builder: (context, state) => const WatchlistScreen(),
      ),
      GoRoute(
        path: '/review/write',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WriteReviewScreen(
            mediaId: extra?['mediaId'] ?? '',
            mediaTitle: extra?['mediaTitle'] ?? '',
            mediaPoster: extra?['mediaPoster'] ?? '',
            mediaType: extra?['mediaType'] ?? 'movie',
          );
        },
      ),
      GoRoute(
        path: '/review/detail',
        builder: (context, state) {
          final review = state.extra as ReviewModel;
          return ReviewDetailsScreen(review: review);
        },
      ),
      GoRoute(
        path: '/tv/popular',
        builder: (context, state) => const PopularTvShowsScreen(),
      ),
      GoRoute(
        path: '/ai',
        builder: (context, state) => const AiScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
