import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import '../../data/request_models/sign_up_request_model.dart';
import '../../view_model/auth/signup_view_model.dart';

class OrganizerAddNewSpeakerDialog extends StatefulWidget {
  final Function(int userId) onUserRegistered;

  const OrganizerAddNewSpeakerDialog({super.key, required this.onUserRegistered});

  @override
  State<OrganizerAddNewSpeakerDialog> createState() => _OrganizerAddNewSpeakerDialogState();
}

class _OrganizerAddNewSpeakerDialogState extends State<OrganizerAddNewSpeakerDialog> {
  final SignupViewModel signupViewModel = Get.find<SignupViewModel>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool get _isFormValid {
    return nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;
  }

  Future<void> _registerSpeaker() async {
    if (!_isFormValid) {
      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar(
          'Error',
          'Passwords do not match',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final signupModel = SignupRequestModel(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      role: 'speaker',
    );

    await signupViewModel.signup(signupModel);

    if (signupViewModel.signupResponse.value.data != null) {
      final userId = signupViewModel.signupResponse.value.data!.user['id'];
      widget.onUserRegistered(userId);
    }
  }

  void _cancel() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20), // Add some padding from screen edges
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8, // Maximum 80% of screen height
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            if (signupViewModel.isLoading.value) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  AppText(
                    text: 'Registering speaker...',
                    fontSize: 16,
                    color: AppColors.darkgrey,
                  ),
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min, // Important: use min to avoid overflow
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const AppText(
                  text: 'Register Speaker Account',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                const SizedBox(height: 8),
                const AppText(
                  text: 'First, create a user account for the speaker',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
                const SizedBox(height: 24),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        const AppText(
                          text: 'Full Name*',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: nameController,
                          hintText: 'Enter speaker name',
                        ),

                        const SizedBox(height: 16),

                        // Email
                        const AppText(
                          text: 'Email*',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: emailController,
                          hintText: 'example@company.com',
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        // Password
                        const AppText(
                          text: 'Password*',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: passwordController,
                          hintText: '••••••••',
                          obscureText: true,
                          suffixIcon: Icons.visibility_off,
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password
                        const AppText(
                          text: 'Confirm Password*',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: confirmPasswordController,
                          hintText: '••••••••',
                          obscureText: true,
                          suffixIcon: Icons.visibility_off,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancel,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const AppText(
                          text: 'Cancel',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Register',
                        onPressed: _registerSpeaker,
                        backgroundColor: AppColors.primaryColor,
                        height: 44,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}