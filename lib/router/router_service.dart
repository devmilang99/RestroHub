import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restro_hub/core/models/enums.dart';
import 'package:restro_hub/features/ai/presentation/views/ai_search_screen.dart';
import 'package:restro_hub/features/auth/data/models/user_model.dart';
import 'package:restro_hub/features/auth/presentation/providers/auth_provider.dart';
import 'package:restro_hub/features/auth/presentation/views/authenticated_password_screen.dart';
import 'package:restro_hub/features/auth/presentation/views/forgot_password_screen.dart';
import 'package:restro_hub/features/auth/presentation/views/google_login_button.dart';
import 'package:restro_hub/features/auth/presentation/views/login_screen.dart';
import 'package:restro_hub/features/auth/presentation/views/register_screen.dart';
import 'package:restro_hub/features/checkout/presentation/views/checkout_screen.dart';
import 'package:restro_hub/features/country/presentation/views/country_list_screen.dart';
import 'package:restro_hub/features/country/presentation/views/explore_country.dart';
import 'package:restro_hub/features/cuisines/presentation/views/cuisine_detail_screen.dart';
import 'package:restro_hub/features/cuisines/presentation/views/search_screen.dart';
import 'package:restro_hub/features/dashboard/presentation/views/contact_us_screen.dart';
import 'package:restro_hub/features/dashboard/presentation/views/info_screens.dart';
import 'package:restro_hub/features/dashboard/presentation/views/location_picker_screen.dart';
import 'package:restro_hub/features/dashboard/presentation/views/main_dashboard_screen.dart';
import 'package:restro_hub/features/dashboard/presentation/views/profile_screen.dart';
import 'package:restro_hub/features/explore/presentation/views/discovery_screen.dart';
import 'package:restro_hub/features/favourites/presentation/views/favourites_screen.dart';
import 'package:restro_hub/features/notifications/presentation/views/notifications_screen.dart';
import 'package:restro_hub/features/orders/presentation/views/orders_screen.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/data/models/restaurant_model.dart';
import 'package:restro_hub/features/restaurants/presentation/views/restaurant_menu_screen.dart';
import 'package:restro_hub/features/splash/presentation/views/splash_screen.dart';
import 'package:restro_hub/screens/permission_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  Page<dynamic> buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    SharedAxisTransitionType transitionType =
        SharedAxisTransitionType.horizontal,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return Semantics(
          container: true,
          child: SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: transitionType,
            child: child,
          ),
        );
      },
    );
  }

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: ref.watch(authListenableProvider),
    redirect: (context, state) {
      final user = authRepository.currentUser;

      // Define paths that should redirect to dashboard if user is already logged in
      final authPaths = [
        '/',
        '/splash',
        '/mainLoginScreen',
        '/registerScreen',
        '/forgotPasswordScreen',
        '/permissions',
      ];

      final isAuthPath = authPaths.contains(state.matchedLocation);

      if (user != null && isAuthPath) {
        debugPrint('Router: User already logged in, redirecting to dashboard');
        return '/mainDashBoard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/permissions',
        name: 'permissionsScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const PermissionScreen(),
        ),
      ),
      GoRoute(
        path: '/mainLoginScreen',
        name: 'mainLoginScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const MainLoginScreen(),
        ),
      ),
      GoRoute(
        path: '/mainDashBoard',
        name: 'mainDashBoard',
        pageBuilder: (context, state) {
          UserModel? user;
          var initialIndex = 0;

          // Check query parameters first (more reliable for tab switching)
          final tabParam = state.uri.queryParameters['tab'];
          if (tabParam != null) {
            initialIndex = int.tryParse(tabParam) ?? 0;
          }

          if (state.extra is UserModel) {
            user = state.extra! as UserModel;
          } else if (state.extra is Map<String, dynamic>) {
            final extra = state.extra! as Map<String, dynamic>;
            user = extra['user'] as UserModel? ?? authRepository.currentUser;
            // If tab wasn't in query, check extra
            if (tabParam == null) {
              initialIndex = extra['initialIndex'] as int? ?? 0;
            }
          } else {
            user = authRepository.currentUser;
          }

          return buildPageWithTransition(
            context: context,
            state: state,
            child: MainDashBoard(
              user: user,
              initialIndex: initialIndex,
            ),
            transitionType: SharedAxisTransitionType.scaled,
          );
        },
      ),
      GoRoute(
        path: '/registerScreen',
        name: 'registerScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const Register(),
        ),
      ),
      GoRoute(
        path: '/forgotPasswordScreen',
        name: 'forgotPasswordScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/restaurantMenu',
        name: 'restaurantMenu',
        pageBuilder: (context, state) {
          final restaurant = state.extra! as RestaurantModel;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: RestaurantMenuScreen(restaurant: restaurant),
          );
        },
      ),
      GoRoute(
        path: '/unifiedExplore',
        name: 'unifiedExplore',
        pageBuilder: (context, state) {
          final type = state.extra as ExploreType? ?? ExploreType.restaurant;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: DiscoveryScreen(type: type),
          );
        },
      ),
      GoRoute(
        path: '/notificationsScreen',
        name: 'notificationsScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/profileScreen',
        name: 'profileScreen',
        pageBuilder: (context, state) {
          final user = state.extra as UserModel?;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: ProfileScreen(user: user),
          );
        },
      ),
      GoRoute(
        path: '/locationPicker',
        name: 'locationPicker',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const LocationPickerScreen(),
        ),
      ),
      GoRoute(
        path: '/contactUsScreen',
        name: 'contactUsScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ContactUsScreen(),
        ),
      ),
      GoRoute(
        path: '/googleLoginScreen',
        name: 'googleLoginScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const GoogleLoginDemo(),
        ),
      ),
      GoRoute(
        path: '/cuisineSingleItem',
        name: 'cuisineSingleItem',
        pageBuilder: (context, state) {
          final item = state.extra! as MenuItemModel;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: CuisineSingleItem(item: item),
            transitionType: SharedAxisTransitionType.scaled,
          );
        },
      ),
      GoRoute(
        path: '/processCheckout',
        name: 'processCheckout',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ProcessCheckOut(),
        ),
      ),
      GoRoute(
        path: '/ordersScreen',
        name: 'ordersScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const OrdersScreen(),
        ),
      ),
      GoRoute(
        path: '/showFavourites',
        name: 'showFavourites',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ShowFavourites(),
        ),
      ),
      GoRoute(
        path: '/authenticatedPasswordScreen',
        name: 'authenticatedPasswordScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const AuthenticatedPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/exploreScreen',
        name: 'exploreScreen',
        pageBuilder: (context, state) {
          final initialCountry = state.extra as String?;
          return buildPageWithTransition(
            context: context,
            state: state,
            child: ExploreScreen(initialCountry: initialCountry),
          );
        },
      ),
      GoRoute(
        path: '/countryListScreen',
        name: 'countryListScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const CountryListScreen(),
        ),
      ),
      GoRoute(
        path: '/searchScreen',
        name: 'searchScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: '/helplineScreen',
        name: 'helplineScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const HelplineScreen(),
        ),
      ),
      GoRoute(
        path: '/policyScreen',
        name: 'policyScreen',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const PolicyScreen(),
        ),
      ),
      GoRoute(
        path: '/aiSearch',
        name: 'aiSearch',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const AiSearchScreen(),
        ),
      ),
    ],
  );
});
