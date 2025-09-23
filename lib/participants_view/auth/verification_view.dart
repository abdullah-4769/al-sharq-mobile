import 'package:al_sharq_conference/participants_view/auth/reset_password_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/conference_logo.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/verification_code_field.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String verificationCode = '';
  String userEmail = 'user@example.com';

  void _verifyCode() {
    if (verificationCode.length == 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Code verified!')));
      Get.to(ResetPasswordScreen());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete code')),
      );
    }
  }

  void _resendCode() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code resent!')));
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          const ConferenceLogo(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const AppText(
                      text: 'Enter Verification Code',

                      fontSize: 20,

                      color: AppColors.blackColor,
                    ),
                    const SizedBox(height: 16),
                    AppText(
                      text:
                          'We\'ve sent a 4-digit verification code to your email address. Please enter the code below to continue.',
                      textAlign: TextAlign.center,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        text: 'Code sent to: ',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        children: [
                          TextSpan(
                            text: userEmail,
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppText(text: 'Code expires in ', fontSize: 14),
                        AppText(text: "02:30"),
                      ],
                    ),
                    const SizedBox(height: 32),
                    VerificationCodeField(
                      length: 4,
                      onChanged: (value) {
                        setState(() {
                          verificationCode = value;
                        });
                      },
                      onCompleted: (value) => _verifyCode(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Didn\'t receive the code?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.darkgrey,
                          ),
                        ),
                        TextButton(
                          onPressed: _resendCode,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: AppText(
                            text: 'Resend Code',
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    CustomButton(text: 'Verify Code', onPressed: _verifyCode),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () {
                        // Handle changing email
                      },
                      child: AppText(
                        text: 'Try a different email address',

                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: 'Need help? ',

                          color: AppColors.blackColor,
                          fontSize: 11,
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: AppText(
                            text: 'Contact Support',
                            color: AppColors.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
