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
