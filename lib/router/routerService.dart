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
import 'package:restro_hub/splashScreen.dart';

class RouterService {
  static final _goRouter = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: "splash",
        builder: (context, state) => const MainDashBoard(),
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
        builder: (context, state) => const AllCousineList(),
      ),

      GoRoute(
        path: '/cuisineSingleItem/:id',
        name: "cuisineSingleItem",
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return CuisineSingleItem(id: id!);
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
    ],
  );

  static GoRouter get goRouter => _goRouter;
}
