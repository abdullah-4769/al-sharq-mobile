// lib/participants_view/auth/login_view.dart
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
import '../../data/request_models/login_request_model.dart';
import '../../images/images.dart';
import '../../utils/app_validation.dart';
import '../../view_model/login_view_model.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginViewModel _viewModel = Get.put(LoginViewModel());
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkRememberMe();
  }

  void _checkRememberMe() async {
    final remembered = await _viewModel.checkIfUserLoggedIn();
    if (remembered) {
      final userData = await _viewModel.getStoredUserData();
      _emailController.text = userData['email'] ?? '';
      _viewModel.rememberMe.value = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final model = LoginRequestModel(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    await _viewModel.login(model);

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

                    // Email Field
                    const FormLabel(text: "Email Address", isRequired: true),
                    CustomTextField(
                      suffixIcon: Icons.mail_outline,
                      hintText: 'Enter Your Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: AppValidators.validateEmail,
                      enabled: !_viewModel.isLoading.value,
                    ),
                    SizedBox(height: height * 0.016),

                    // Password Field
                    const FormLabel(text: "Password", isRequired: true),
                    CustomTextField(
                      hintText: 'Enter Your Password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      suffixIconColor: Colors.grey[400],
                      onSuffixIconTap: _viewModel.isLoading.value ? null : () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: AppValidators.validateSimplePassword,
                      enabled: !_viewModel.isLoading.value,
                    ),
                    SizedBox(height: height * 0.016),

                    // Remember Me & Forgot Password
                    Obx(() => Row(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _viewModel.rememberMe.value,
                              onChanged: _viewModel.isLoading.value ? null : (value) {
                                _viewModel.rememberMe.value = value ?? false;
                              },
                              activeColor: AppColors.primaryColor,
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: _viewModel.isLoading.value ? null : () {
                                _viewModel.rememberMe.value = !_viewModel.rememberMe.value;
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
                          onPressed: _viewModel.isLoading.value ? null : () {
                            Get.to(() => const ForgotPasswordScreen());
                          },
                          child: AppText(
                            text: 'Forget Password',
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )),
                    SizedBox(height: height * 0.016),

                    // Login Button
                    Obx(() => CustomButton(
                      text: _viewModel.isLoading.value ? 'Signing In...' : 'Sign In',
                      onPressed: _viewModel.isLoading.value ? null : _login,
                      isLoading: _viewModel.isLoading.value,
                    )),
                    SizedBox(height: height * 0.036),

                    // Divider
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

                    // Social Buttons
                    Obx(() => _buildSocialButton(
                      imagePath: Images.googleimage,
                      label: 'Continue with Google',
                      onPressed: _viewModel.isLoading.value ? null : () {},
                    )),
                    SizedBox(height: height * 0.016),
                    Obx(() => _buildSocialButton(
                      imagePath: Images.facebookimage,
                      label: 'Continue with Facebook',
                      onPressed: _viewModel.isLoading.value ? null : () {},
                    )),
                    SizedBox(height: height * 0.016),
                    Obx(() => _buildSocialButton(
                      imagePath: Images.appleimage,
                      label: 'Continue with Apple',
                      onPressed: _viewModel.isLoading.value ? null : () {},
                    )),
                    SizedBox(height: height * 0.016),

                    // Sign Up Link
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppText(text: "Don't Have an account?", fontSize: 16),
                        InkWell(
                          onTap: _viewModel.isLoading.value ? null : () {
                            Get.to(() => const SignupScreen());
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
                    )),
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
    required VoidCallback? onPressed,
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

