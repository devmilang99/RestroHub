import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:restro_hub/features/cuisines/presentation/views/all_cuisine_list_screen.dart';
import 'package:restro_hub/features/cuisines/presentation/views/cuisine_detail_screen.dart';
import 'package:restro_hub/features/cuisines/presentation/views/search_screen.dart';
import 'package:restro_hub/features/dashboard/presentation/views/contact_us_screen.dart';
import 'package:restro_hub/features/dashboard/presentation/views/info_screens.dart';
import 'package:restro_hub/features/dashboard/presentation/views/location_picker_screen.dart';
import 'package:restro_hub/features/dashboard/presentation/views/main_dashboard_screen.dart';
import 'package:restro_hub/features/dashboard/presentation/views/profile_screen.dart';
import 'package:restro_hub/features/favourites/presentation/views/favourites_screen.dart';
import 'package:restro_hub/features/notifications/presentation/views/notifications_screen.dart';
import 'package:restro_hub/features/restaurants/data/models/menu_models.dart';
import 'package:restro_hub/features/restaurants/presentation/views/explore_restaurants_screen.dart';
import 'package:restro_hub/features/splash/presentation/views/splash_screen.dart';
import 'package:restro_hub/screens/permission_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  Page<dynamic> _buildPageWithTransition({
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
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
    );
  }

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final user = authRepository.currentUser;
      final isLoggingIn =
          state.matchedLocation == '/mainLoginScreen' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/permissions';

      if (user != null && isLoggingIn) {
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
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const PermissionScreen(),
        ),
      ),
      GoRoute(
        path: '/mainLoginScreen',
        name: 'mainLoginScreen',
        pageBuilder: (context, state) => _buildPageWithTransition(
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

          if (state.extra is UserModel) {
            user = state.extra! as UserModel;
          } else if (state.extra is Map<String, dynamic>) {
            final extra = state.extra! as Map<String, dynamic>;
            user = extra['user'] as UserModel?;
            initialIndex = extra['initialIndex'] as int? ?? 0;
          } else {
            user = authRepository.currentUser;
          }

          return _buildPageWithTransition(
            context: context,
            state: state,
            child: MainDashBoard(user: user, initialIndex: initialIndex),
            transitionType: SharedAxisTransitionType.scaled,
          );
        },
      ),
      GoRoute(
        path: '/registerScreen',
        name: 'registerScreen',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const Register(),
        ),
      ),
      GoRoute(
        path: '/forgotPasswordScreen',
        name: 'forgotPasswordScreen',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/exploreRestaurantsScreen',
        name: 'exploreRestaurantsScreen',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ExploreRestaurantsScreen(),
        ),
      ),
      GoRoute(
        path: '/notificationsScreen',
        name: 'notificationsScreen',
        pageBuilder: (context, state) => _buildPageWithTransition(
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
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: ProfileScreen(user: user),
          );
        },
      ),
      GoRoute(
        path: '/locationPicker',
        name: 'locationPicker',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const LocationPickerScreen(),
        ),
      ),
      GoRoute(
        path: '/contactUsScreen',
        name: 'contactUsScreen',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ContactUsScreen(),
        ),
      ),
      GoRoute(
        path: '/googleLoginScreen',
        name: 'googleLoginScreen',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const GoogleLoginDemo(),
        ),
      ),
      GoRoute(
        path: '/allCuisineList',
        name: 'allCuisineList',
        pageBuilder: (context, state) {
          final extras = state.extra! as Map<String, dynamic>;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: AllCousineList(
              title: extras['title'] as String,
              items: extras['items'] as List<MenuItemModel>,
            ),
          );
        },
      ),
      GoRoute(
        path: '/cuisineSingleItem',
        name: 'cuisineSingleItem',
        pageBuilder: (context, state) {
          final item = state.extra! as MenuItemModel;
          return _buildPageWithTransition(
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
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ProcessCheckOut(),
        ),
      ),
      GoRoute(
        path: '/showFavourites',
        name: 'showFavourites',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ShowFavourites(),
        ),
      ),
      GoRoute(
        path: '/authenticatedPasswordScreen',
        name: 'authenticatedPasswordScreen',
        pageBuilder: (context, state) => _buildPageWithTransition(
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
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: ExploreScreen(initialCountry: initialCountry),
          );
        },
      ),
      GoRoute(
        path: '/countryListScreen',
        name: 'countryListScreen',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const CountryListScreen(),
        ),
      ),
      GoRoute(
        path: '/searchScreen',
        name: 'searchScreen',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: SearchScreen(),
        ),
      ),
      GoRoute(
        path: '/helplineScreen',
        name: 'helplineScreen',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: HelplineScreen(),
        ),
      ),
      GoRoute(
        path: '/policyScreen',
        name: 'policyScreen',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: PolicyScreen(),
        ),
      ),
    ],
  );
});
