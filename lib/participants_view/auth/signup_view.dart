import 'package:al_sharq_conference/images/images.dart';
import 'package:al_sharq_conference/participants_view/auth/login_view.dart';
import 'package:al_sharq_conference/participants_view/auth/signup_profile.dart';
import 'package:al_sharq_conference/participants_view/auth/verification_view.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/conference_logo.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../custom_widgets/form_label.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Creating account...')));
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView( // Moved SingleChildScrollView to the top level
        child: Column(
          children: [
            const ConferenceLogo(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                vertical: height * 0.060,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title Section
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.010),
                          AppText(
                            text: "Sign up to",
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.blackColor,
                          ),
                          AppText(
                            text: "AL SHARQ CONFERENCE",
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.060),

                    /// Full Name
                    const FormLabel(text: "Full Name", isRequired: true),
                    CustomTextField(
                      hintText: "Enter your name",
                      controller: _fullNameController,
                      suffixIcon: Icons.person_3_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.010),

                    /// Email Address
                    const FormLabel(text: "Email Address", isRequired: true),
                    CustomTextField(
                      hintText: "Enter your email",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      suffixIcon: Icons.mail_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.010),
                    const FormLabel(text: "Password", isRequired: true),
                    CustomTextField(
                      hintText: "*******",
                      controller: _passwordController,
                      obscureText: true,
                      suffixIcon: Icons.visibility,
                      suffixIconColor: Colors.grey[400],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    /// Confirm Password
                    const FormLabel(
                      text: "Confirm Password",
                      isRequired: true,
                    ),
                    CustomTextField(
                      hintText: "*******",
                      controller: _confirmPasswordController,
                      obscureText: true,
                      suffixIcon: Icons.visibility,
                      suffixIconColor: Colors.grey[400],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    CustomButton(
                      text: "Create Account",
                      onPressed: () {
                        Get.to(SetupProfileScreen());
                      },
                    ),
                    SizedBox(height: height * 0.0360),

                    /// Divider
                    Row(
                      children: [
                        Expanded(child: _buildDivider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AppText(
                            text: 'Or continue with',
                            color: AppColors.darkgrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(child: _buildDivider()),
                      ],
                    ),
                    SizedBox(height: height * 0.0360),

                    /// Social Buttons
                    _buildSocialButton(
                      imagePath: Images.googleimage,
                      label: 'Continue with Google',
                      onPressed: () {},
                    ),
                    SizedBox(height: height * 0.016),

                    _buildSocialButton(
                      imagePath: Images.facebookimage,
                      label: 'Continue with Google', // Corrected to 'Continue with Facebook' below
                      onPressed: () {},
                    ),
                    SizedBox(height: height * 0.016),
                    _buildSocialButton(
                      imagePath: Images.appleimage,
                      label: 'Continue with Apple',
                      onPressed: () {},
                    ),
                    SizedBox(height: height * 0.056),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: "Already have an account? ",
                          color: AppColors.blackColor,
                          fontSize: 14,
                        ),
                        GestureDetector(
                          onTap: () => Get.to(LoginScreen()),
                          child: AppText(
                            text: "Sign In",
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: Colors.grey[300]);
  }

  Widget _buildSocialButton({
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          imagePath,
          width: 20,
          height: 20,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, color: Colors.red),
        ),
        label: AppText(
          text: label,
          fontSize: 14,
          color: AppColors.blackColor,
          fontWeight: FontWeight.w500,
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.lightGreyColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}