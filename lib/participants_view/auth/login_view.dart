import 'package:al_sharq_conference/participants_view/auth/forget_password_view.dart';
import 'package:al_sharq_conference/participants_view/auth/signup_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/conference_logo.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../custom_widgets/form_label.dart';
import '../../images/images.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logging in...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ConferenceLogo(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.060),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    AppText(
                      text: "Sign in to",
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                    AppText(
                      text: 'AL SHARQ CONFERENCE',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(height: 48),
                    const FormLabel(text: "Email Address", isRequired: true),
                    CustomTextField(
                      suffixIcon: Icons.mail_outline,
                      hintText: 'Enter Your Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.016),
                    const FormLabel(text: "Password", isRequired: true),
                    CustomTextField(
                      hintText: 'Enter Your Password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      suffixIconColor: Colors.grey[400],
                      onSuffixIconTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
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
                    SizedBox(height: height * 0.016),
                    Row(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: AppColors.primaryColor,
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: AppText(
                                text: 'Remember me',
                                color: AppColors.blackColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: AppText(
                            text: 'Forget Password',
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.016),
                    CustomButton(text: 'Sign In', onPressed: _login),
                    SizedBox(height: height * 0.036),
                    Row(
                      children: [
                        Expanded(child: _buildDivider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AppText(
                            text: 'Or continue with',
                            color: AppColors.darkgrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(child: _buildDivider()),
                      ],
                    ),
                    SizedBox(height: height * 0.036),
                    _buildSocialButton(
                      imagePath: Images.googleimage,
                      label: 'Continue with Google',
                      onPressed: () {},
                    ),
                    SizedBox(height: height * 0.016),
                    _buildSocialButton(
                      imagePath: Images.facebookimage,
                      label: 'Continue with Facebook',
                      onPressed: () {},
                    ),
                    SizedBox(height: height * 0.016),
                    _buildSocialButton(
                      imagePath: Images.appleimage,
                      label: 'Continue with Apple',
                      onPressed: () {},
                    ),
                    SizedBox(height: height * 0.016),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppText(text: "Don't Have an account?", fontSize: 16),
                        InkWell(
                          onTap: () {
                            Get.to(const SignupScreen());
                          },
                          child: AppText(
                            text: "Sign Up",
                            fontSize: 16,
                            color: AppColors.primaryColor,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.016),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: AppColors.mediumGreyColor);
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