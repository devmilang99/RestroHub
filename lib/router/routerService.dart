import 'package:go_router/go_router.dart';
import 'package:restro_hub/login/googleLogin.dart';
import 'package:restro_hub/login/screens/CheckOut/processCheckOut.dart';
import 'package:restro_hub/login/screens/Cuisine/all_Cuisine_List.dart';
import 'package:restro_hub/login/screens/Cuisine/cuisine_Single_item.dart';
import 'package:restro_hub/login/screens/favourites/favourites.dart';
import 'package:restro_hub/login/screens/forgotPassword.dart';
import 'package:restro_hub/login/screens/mainLoginScreen.dart';
import 'package:restro_hub/login/model/User.dart';
import 'package:restro_hub/login/screens/register.dart';
import 'package:restro_hub/login/screens/mainDashBoard/mainDashboard.dart';
import 'package:restro_hub/core/models/cuisines_item.dart';
import 'package:restro_hub/splashScreen.dart';
import 'package:restro_hub/screens/permission_screen.dart';
import 'package:restro_hub/login/screens/authenticated_password.dart';
import 'package:restro_hub/login/screens/explore_screen.dart';
import 'package:restro_hub/login/screens/country_list_screen.dart';
import 'package:restro_hub/login/screens/explore_restaurants_screen.dart';

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
          final user = state.extra as User?;
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
            items: extras['items'] as List<CuisinesItem>,
          );
        },
      ),

      GoRoute(
        path: '/cuisineSingleItem',
        name: "cuisineSingleItem",
        builder: (context, state) {
          final item = state.extra as CuisinesItem;
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
