import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_model/forget_password_viewmodel/forget_pass_viewmodel.dart';

// ==================== SET NEW PASSWORD SCREEN ====================
/// Screen for setting a new password after OTP verification

class SetNewPasswordScreen extends StatelessWidget {
  final SetNewPasswordController controller = Get.put(SetNewPasswordController());

  SetNewPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/al_sharq_logo.png',
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.account_balance, color: Colors.white);
              },
            ),

          ],
        ),
        backgroundColor: Color(0xFF9B2033),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // ==================== HEADER SECTION ====================
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF9B2033).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset,
                size: 60,
                color: Color(0xFF9B2033),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Create New Password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9B2033),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your new password must be different from previously used passwords',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40),

            // ==================== PASSWORD INPUT SECTION ====================
            Text(
              'New Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Obx(() => TextField(
              onChanged: (value) => controller.password.value = value,
              obscureText: !controller.showPassword.value,
              decoration: InputDecoration(
                hintText: 'Enter new password',
                prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF9B2033)),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => controller.showPassword.value = !controller.showPassword.value,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF9B2033), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            )),
            SizedBox(height: 20),

            // ==================== CONFIRM PASSWORD SECTION ====================
            Text(
              'Confirm Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Obx(() => TextField(
              onChanged: (value) => controller.confirmPassword.value = value,
              obscureText: !controller.showConfirmPassword.value,
              decoration: InputDecoration(
                hintText: 'Re-enter new password',
                prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF9B2033)),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showConfirmPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => controller.showConfirmPassword.value = !controller.showConfirmPassword.value,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF9B2033), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
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
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Password Requirements',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[900],
                        ),
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
            //
            // // ==================== ERROR MESSAGE SECTION ====================
            // Obx(() {
            //   if (controller.errorMessage.value.isEmpty) return SizedBox();
            //
            //   return Container(
            //     padding: EdgeInsets.all(12),
            //     decoration: BoxDecoration(
            //       color: Colors.red[50],
            //       borderRadius: BorderRadius.circular(8),
            //       border: Border.all(color: Colors.red[200]!),
            //     ),
            //     child: Row(
            //       children: [
            //         Icon(Icons.error_outline, color: Colors.red, size: 20),
            //         SizedBox(width: 8),
            //         Expanded(
            //           child: Text(
            //             controller.errorMessage.value,
            //             style: TextStyle(color: Colors.red[700]),
            //           ),
            //         ),
            //       ],
            //     ),
            //   );
            // }),
            //
            // SizedBox(height: 30),

            // ==================== RESET PASSWORD BUTTON SECTION ====================
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9B2033),
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
                    : Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )),
            SizedBox(height: 20),

            // ==================== BACK BUTTON SECTION ====================
            Center(
              child: TextButton.icon(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
                label: Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
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
          Icon(Icons.check_circle_outline, size: 18, color: Colors.blue[700]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}