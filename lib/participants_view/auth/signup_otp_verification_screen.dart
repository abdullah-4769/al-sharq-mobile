import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../view_model/auth/signup_view_model.dart';
import '../../utils/shared_preference.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';

// ==================== SIGNUP OTP VERIFICATION SCREEN ====================
/// Screen for verifying OTP during signup process

class SignupOTPVerificationScreen extends StatefulWidget {
  const SignupOTPVerificationScreen({Key? key}) : super(key: key);

  @override
  State<SignupOTPVerificationScreen> createState() =>
      _SignupOTPVerificationScreenState();
}

class _SignupOTPVerificationScreenState
    extends State<SignupOTPVerificationScreen> {
  final SignupOTPVerificationController controller =
  Get.put(SignupOTPVerificationController());
  final List<TextEditingController> otpControllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes =
  List.generate(6, (index) => FocusNode());
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final email = await SharedPrefsHelper.getPassResetEmail();
    setState(() {
      userEmail = email ?? 'your email';
    });
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AppText(
          text: 'Verify Email',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            // ==================== HEADER SECTION ====================
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 60,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 30),
            AppText(
              text: 'Check Your Email',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 12),
            AppText(
              text: 'We\'ve sent a 6-digit verification code to',
              fontSize: 14,
              color: AppColors.darkgrey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            AppText(
              text: userEmail,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            // ==================== OTP INPUT SECTION ====================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: focusNodes[index],
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
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
                        borderSide:
                        BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) {
                      controller.updateOTPDigit(index, value);

                      if (value.isNotEmpty && index < 5) {
                        focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: 30),

            // ==================== COUNTDOWN TIMER SECTION ====================
            Obx(() => controller.countdown.value > 0
                ? AppText(
              text: 'Resend code in ${controller.countdown.value}s',
              color: AppColors.darkgrey,
              fontSize: 14,
            )
                : SizedBox()),
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

            // ==================== VERIFY BUTTON SECTION ====================
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.verifyOTP,
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
                  text: 'Verify Email',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )),
            SizedBox(height: 20),

            // ==================== RESEND CODE SECTION ====================
            Obx(() => TextButton(
              onPressed: controller.canResend.value &&
                  !controller.isLoading.value
                  ? controller.resendOTP
                  : null,
              child: AppText(
                text: 'Resend Verification Code',
                color: controller.canResend.value
                    ? AppColors.primaryColor
                    : AppColors.darkgrey,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            )),
            SizedBox(height: 10),

            // ==================== BACK BUTTON SECTION ====================
            TextButton.icon(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back, color: AppColors.darkgrey),
              label: AppText(
                text: 'Back to Signup',
                color: AppColors.darkgrey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}