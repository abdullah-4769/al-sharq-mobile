import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_model/auth/signup_view_model.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../custom_widgets/form_label.dart';

// ==================== SIGNUP SET PASSWORD SCREEN ====================
/// Screen for setting password after email verification during signup

class SignupSetPasswordScreen extends StatefulWidget {
  const SignupSetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<SignupSetPasswordScreen> createState() =>
      _SignupSetPasswordScreenState();
}

class _SignupSetPasswordScreenState extends State<SignupSetPasswordScreen> {
  final SignupSetPasswordController controller =
  Get.put(SignupSetPasswordController());
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppText(
          text: 'Set Your Password',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevent going back
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // ==================== HEADER SECTION ====================
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_open,
                  size: 60,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  AppText(
                    text: 'Almost There!',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(height: 10),
                  AppText(
                    text: 'Create a secure password for your account',
                    fontSize: 14,
                    color: AppColors.darkgrey,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),

            // ==================== PASSWORD INPUT SECTION ====================
            const FormLabel(text: 'Password', isRequired: true),
            Obx(() => CustomTextField(
              hintText: 'Enter your password',
              controller: _passwordController,
              obscureText: !controller.showPassword.value,
              suffixIcon: controller.showPassword.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              suffixIconColor: Colors.grey[400],
              onSuffixIconTap: () {
                controller.showPassword.value =
                !controller.showPassword.value;
              },
              onChanged: (value) => controller.password.value = value,
              enabled: !controller.isLoading.value,
            )),
            SizedBox(height: height * 0.020),

            // ==================== CONFIRM PASSWORD SECTION ====================
            const FormLabel(text: 'Confirm Password', isRequired: true),
            Obx(() => CustomTextField(
              hintText: 'Re-enter your password',
              controller: _confirmPasswordController,
              obscureText: !controller.showConfirmPassword.value,
              suffixIcon: controller.showConfirmPassword.value
                  ? Icons.visibility
                  : Icons.visibility_off,
              suffixIconColor: Colors.grey[400],
              onSuffixIconTap: () {
                controller.showConfirmPassword.value =
                !controller.showConfirmPassword.value;
              },
              onChanged: (value) =>
              controller.confirmPassword.value = value,
              enabled: !controller.isLoading.value,
            )),
            SizedBox(height: 24),

            // ==================== PASSWORD REQUIREMENTS SECTION ====================
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[700], size: 20),
                      SizedBox(width: 8),
                      AppText(
                        text: 'Password Requirements',
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900]!,
                        fontSize: 14,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildRequirement('At least 8 characters'),
                  _buildRequirement('One uppercase letter (A-Z)'),
                  _buildRequirement('One lowercase letter (a-z)'),
                  _buildRequirement('One number (0-9)'),
                  _buildRequirement('One special character (!@#\$%^&*)'),
                ],
              ),
            ),
            SizedBox(height: 20),

            // ==================== ERROR MESSAGE SECTION ====================
            Obx(() => controller.errorMessage.value.isNotEmpty
                ? Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      text: controller.errorMessage.value,
                      color: Colors.red[700]!,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
                : SizedBox()),
            SizedBox(height: 30),

            // ==================== COMPLETE SIGNUP BUTTON SECTION ====================
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.completeSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : AppText(
                  text: 'Complete Registration',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              size: 18, color: Colors.blue[700]),
          SizedBox(width: 8),
          Expanded(
            child: AppText(
              text: text,
              fontSize: 13,
              color: Colors.blue[900]!,
            ),
          ),
        ],
      ),
    );
  }
}