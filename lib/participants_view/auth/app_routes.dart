import 'package:al_sharq_conference/participants_view/auth/login_view.dart';
import 'package:al_sharq_conference/participants_view/auth/verification_view.dart';
import 'package:get/get.dart';
import 'forget_password_view.dart';

import 'set_new_password_screen.dart';

// ==================== APP ROUTES CONFIGURATION ====================
/// Central route configuration for password reset flow

class AppRoutes {
  // Route names
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String setNewPassword = '/set-new-password';
  static const String login = '/login'; // Your existing login route

  // GetX routes list
  static List<GetPage> routes = [
    GetPage(
      name: forgotPassword,
      page: () => ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: otpVerification,
      page: () => OTPVerificationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: setNewPassword,
      page: () => SetNewPasswordScreen(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: login,
      page: () => LoginScreen(),
      transition: Transition.rightToLeft,
    ),
    // Add your other routes here
  ];
}

// ==================== USAGE IN main.dart ====================
/*
import 'package:get/get.dart';
import 'app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Al Sharq Conference',
      theme: ThemeData(
        primaryColor: Color(0xFF9B2033),
      ),
      initialRoute: '/login', // Your initial route
      getPages: AppRoutes.routes,
    );
  }
}
*/