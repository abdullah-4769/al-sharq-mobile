import 'package:al_sharq_conference/images/images.dart';
import 'package:al_sharq_conference/organizer_view/auth/login_view.dart';
import 'package:al_sharq_conference/participants_view/auth/login_view.dart';
import 'package:al_sharq_conference/participants_view/auth/signup_profile.dart';
import 'package:al_sharq_conference/speaker_view/auth/login_view.dart';
import 'package:al_sharq_conference/sponser_view/auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:get/get.dart';

import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/conference_logo.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../custom_widgets/form_label.dart';

import '../../data/request_models/sign_up_request_model.dart';
import '../../data/response/api_response.dart';
import '../../utils/app_validation.dart';
import '../../view_model/auth/signup_view_model.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final SignupViewModel _viewModel = Get.put(SignupViewModel());
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    // First validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final model = SignupRequestModel(
      name: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: "participant",
    );

    await _viewModel.signup(model);

    // Check if signup was successful using GetX reactive state
    if (_viewModel.signupResponse.value.status == Status.COMPLETED) {
      Get.off(() => const LoginScreen());
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
                          // const SizedBox(height: 16),

                          /// Role Buttons
                          // Wrap(
                          //   spacing: 10,
                          //   runSpacing: 10,
                          //   alignment: WrapAlignment.center,
                          //   children: [
                          //     _roleButton(
                          //       label: "Organizer View",
                          //       onTap: () => Get.to(const OrganizerLoginScreen()),
                          //     ),
                          //     _roleButton(
                          //       label: "Speaker View",
                          //       onTap: () => Get.to(const SpeakerLoginScreen()),
                          //     ),
                          //     _roleButton(
                          //       label: "Sponsor View",
                          //       onTap: () => Get.to(const SponserLoginScreen()),
                          //     ),
                          //   ],
                          // ),
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
                      validator: (value) => AppValidators.validateName(value),
                      enabled: !_viewModel.isLoading.value,
                    ),
                    SizedBox(height: height * 0.010),

                    /// Email Address
                    const FormLabel(text: "Email Address", isRequired: true),
                    CustomTextField(
                      hintText: "Enter your email",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      suffixIcon: Icons.mail_outline,
                      validator: (value) => AppValidators.validateEmail(value),
                      enabled: !_viewModel.isLoading.value,
                    ),
                    SizedBox(height: height * 0.010),

                    /// Password
                    const FormLabel(text: "Password", isRequired: true),
                    CustomTextField(
                      hintText: "*******",
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      suffixIconColor: Colors.grey[400],
                      onSuffixIconTap: _viewModel.isLoading.value ? null : () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      validator: (value) => AppValidators.validatePassword(value),
                      enabled: !_viewModel.isLoading.value,
                    ),
                    const SizedBox(height: 10),

                    /// Confirm Password
                    const FormLabel(text: "Confirm Password", isRequired: true),
                    CustomTextField(
                      hintText: "*******",
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      suffixIconColor: Colors.grey[400],
                      onSuffixIconTap: _viewModel.isLoading.value ? null : () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                      validator: (value) => AppValidators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      enabled: !_viewModel.isLoading.value,
                    ),
                    const SizedBox(height: 32),

                    /// Create Account Button with Obx for reactive state
                    Obx(() => CustomButton(
                      text: _viewModel.isLoading.value ? "Creating Account..." : "Create Account",
                      isLoading: _viewModel.isLoading.value,
                      onPressed: _viewModel.isLoading.value ? null : _signup,
                    )),

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
                    SizedBox(height: height * 0.056),

                    /// Already have account
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: "Already have an account? ",
                          color: AppColors.blackColor,
                          fontSize: 14,
                        ),
                        GestureDetector(
                          onTap: _viewModel.isLoading.value ? null : () => Get.to(const LoginScreen()),
                          child: AppText(
                            text: "Sign In",
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )),
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

  Widget _roleButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryColor, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}