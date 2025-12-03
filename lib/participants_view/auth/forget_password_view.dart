import 'package:al_sharq_conference/participants_view/auth/verification_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_model/forget_password_viewmodel/forget_pass_viewmodel.dart';

// ==================== FORGOT PASSWORD SCREEN ====================
/// Screen for initiating password reset by entering email

class ForgotPasswordScreen extends StatelessWidget {
  final ForgotPasswordController controller = Get.put(ForgotPasswordController());

  ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/al_sharq_logo.png', // Add your logo asset
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
            Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9B2033),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Enter your email address and we\'ll send you a code to reset your password',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40),

            // ==================== EMAIL INPUT SECTION ====================
            Text(
              'Email Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              onChanged: (value) => controller.email.value = value,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF9B2033)),
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
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12),

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
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            )
                : SizedBox()),
            SizedBox(height: 30),

            // ==================== SEND CODE BUTTON SECTION ====================
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.sendOTP,
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
                  'Send Verification Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )),
            SizedBox(height: 20),

            // ==================== ALREADY HAVE CODE SECTION ====================
            Center(
              child: TextButton(
                onPressed: () {
                  if (controller.email.value.isNotEmpty) {
                 Get.toNamed('/otp-verification');
                  } else {
                    Get.snackbar(
                      'Error',
                      'Please enter your email first',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: Text(
                  'Already have a code? Verify now',
                  style: TextStyle(
                    color: Color(0xFF9B2033),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // ==================== BACK TO LOGIN SECTION ====================
            Center(
              child: TextButton.icon(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
                label: Text(
                  'Back to Login',
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
}