// import 'package:al_sharq_conference/app_colors/app_colors.dart';
// import 'package:flutter/material.dart';
// import '../../images/images.dart';
// import '../../utils/shared_preference.dart';
// import '../../view_model/login_view_model.dart';
// import '../auth/signup_view.dart';
// import 'package:get/get.dart';
//
// class SplashView extends StatefulWidget {
//   const SplashView({super.key});
//
//   @override
//   State<SplashView> createState() => _SplashViewState();
// }
//
// class _SplashViewState extends State<SplashView> {
//   late LoginViewModel _loginViewModel;
//
//   @override
//   void initState() {
//     super.initState();
//     _loginViewModel = Get.put(LoginViewModel());
//     _navigateBasedOnLoginStatus();
//   }
//
//   void _navigateBasedOnLoginStatus() async {
//     await Future.delayed(const Duration(seconds: 3));
//
//     if (!mounted) return;
//
//     try {
//       // Check if user is logged in
//       final isLoggedIn = await SharedPrefsHelper.isUserLoggedIn();
//
//       if (!mounted) return;
//
//       if (isLoggedIn) {
//         // Get user role
//         final userRole = await SharedPrefsHelper.getUserRole();
//
//         if (!mounted) return;
//
//         // Initialize current role in ViewModel
//         _loginViewModel.currentRole.value = userRole ?? 'participant';
//
//         // ✅ Now call public method - NO ERROR!
//         _loginViewModel.navigateBasedOnRole(userRole ?? 'participant');
//       } else {
//         // User is not logged in, go to SignupScreen
//         Get.offAll(() => const SignupScreen());
//       }
//     } catch (e) {
//       print('Error checking login status: $e');
//       if (mounted) {
//         Get.offAll(() => const SignupScreen());
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             const Spacer(),
//             Center(
//               child: Image.asset(
//                 Images.splashLogo,
//                 width: 180,
//                 height: 180,
//                 errorBuilder: (context, error, stackTrace) =>
//                 const Icon(Icons.error, color: Colors.red),
//               ),
//             ),
//             const Spacer(),
//             Image.asset(
//               Images.splashBackground,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) =>
//               const Icon(Icons.error, color: Colors.red),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import '../../images/images.dart';
import '../auth/signup_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToSignup();
  }

  void _navigateToSignup() async {
    await Future.delayed(const Duration(seconds: 3)); // ⏳ 3 seconds splash
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: Image.asset(
                Images.splashLogo,
                width: 180,
                height: 180,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red),
              ),
            ),
            const Spacer(),
            Image.asset(
              Images.splashBackground,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
