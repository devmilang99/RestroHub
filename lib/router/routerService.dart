import 'package:go_router/go_router.dart';
import 'package:restro_hub/features/auth/presentation/views/google_login_button.dart';
import 'package:restro_hub/features/checkout/presentation/views/checkout_screen.dart';
import 'package:restro_hub/features/cuisines/presentation/views/all_cuisine_list_screen.dart';
import 'package:restro_hub/features/cuisines/presentation/views/cuisine_detail_screen.dart';
import 'package:restro_hub/features/favourites/presentation/views/favourites_screen.dart';
import 'package:restro_hub/features/auth/presentation/views/forgot_password_screen.dart';
import 'package:restro_hub/features/auth/presentation/views/login_screen.dart';
import 'package:restro_hub/features/auth/data/models/user_model.dart';
import 'package:restro_hub/features/auth/presentation/views/register_screen.dart';
import 'package:restro_hub/features/dashboard/presentation/views/main_dashboard_screen.dart';
import 'package:restro_hub/features/cuisines/data/models/cuisine_model.dart';
import 'package:restro_hub/features/splash/presentation/views/splash_screen.dart';
import 'package:restro_hub/screens/permission_screen.dart';
import 'package:restro_hub/features/auth/presentation/views/authenticated_password_screen.dart';
import 'package:restro_hub/features/restaurants/presentation/views/restaurant_explore_screen.dart';
import 'package:restro_hub/features/country/presentation/views/country_list_screen.dart';
import 'package:restro_hub/features/restaurants/presentation/views/explore_restaurants_screen.dart';

class RouterService {
  static final _goRouter = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: "splash",
        builder: (context, state) => const splashScreen(),
      ),
      GoRoute(
        path: '/permissions',
        name: "permissionsScreen",
        builder: (context, state) => const PermissionScreen(),
      ),
      GoRoute(
        path: '/mainLoginScreen',
        name: "mainLoginScreen",
        builder: (context, state) => const MainLoginScreen(),
      ),
      GoRoute(
        path: '/mainDashBoard',
        name: "mainDashBoard",
        builder: (context, state) {
          final user = state.extra as UserModel?;
          return MainDashBoard(user: user);
        },
      ),

      GoRoute(
        path: '/registerScreen',
        name: "registerScreen",
        builder: (context, state) => const Register(),
      ),

      GoRoute(
        path: '/forgotPasswordScreen',
        name: "forgotPasswordScreen",
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/googleLoginScreen',
        name: "googleLoginScreen",
        builder: (context, state) => const GoogleLoginDemo(),
      ),

      GoRoute(
        path: '/allCouisineList',
        name: "allCouisineList",
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return AllCousineList(
            title: extras['title'] as String,
            items: extras['items'] as List<CuisineModel>,
          );
        },
      ),

      GoRoute(
        path: '/cuisineSingleItem',
        name: "cuisineSingleItem",
        builder: (context, state) {
          final item = state.extra as CuisineModel;
          return CuisineSingleItem(item: item);
        },
      ),

      GoRoute(
        path: '/processCheckout',
        name: "processCheckout",
        builder: (context, state) => const ProcessCheckOut(),
      ),

      GoRoute(
        path: '/showFavourites',
        name: "showFavourites",
        builder: (context, state) => const ShowFavourites(),
      ),
      GoRoute(
        path: '/authenticatedPasswordScreen',
        name: "authenticatedPasswordScreen",
        builder: (context, state) => const AuthenticatedPasswordScreen(),
      ),
      GoRoute(
        path: '/exploreScreen',
        name: "exploreScreen",
        builder: (context, state) {
          final initialCountry = state.extra as String?;
          return ExploreScreen(initialCountry: initialCountry);
        },
      ),
      GoRoute(
        path: '/countryListScreen',
        name: "countryListScreen",
        builder: (context, state) => const CountryListScreen(),
      ),
      GoRoute(
        path: '/exploreRestaurantsScreen',
        name: "exploreRestaurantsScreen",
        builder: (context, state) => const ExploreRestaurantsScreen(),
      ),
    ],
  );

  static GoRouter get goRouter => _goRouter;
}
