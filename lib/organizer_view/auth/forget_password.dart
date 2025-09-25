import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/participants_view/auth/verification_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../custom_widgets/conference_logo.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../custom_widgets/form_label.dart';

class OrganizerForgotPasswordScreen extends StatefulWidget {
  const OrganizerForgotPasswordScreen({super.key});

  @override
  State<OrganizerForgotPasswordScreen> createState() => _OrganizerForgotPasswordScreenState();
}

class _OrganizerForgotPasswordScreenState extends State<OrganizerForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _sendResetCode() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VerificationScreen()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ConferenceLogo(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal:
                MediaQuery.of(context).size.width *
                    0.06,
                vertical:
                MediaQuery.of(context).size.height *
                    0.02,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ), // 4% of screen height
                    AppText(
                      text: "Forget Password",
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                    ), // 6% of screen height
                    AppText(
                      text:
                      'Enter your email address and we\'ll send you a 4-digit code to reset your password',
                      textAlign: TextAlign.center,
                      fontSize: 14,
                      color: AppColors.darkgrey,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ), // 4% of screen height
                    const FormLabel(text: "Enter email", isRequired: true),
                    CustomTextField(
                      hintText: 'Enter Your Email Address',
                      suffixIcon: Icons.mail_outline,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ), // 4% of screen height
                    CustomButton(
                      text: 'Send Code',
                      onPressed: () {
                        Get.to(VerificationScreen());
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            text: "Need Help?",
                            fontSize: 14,
                            color: AppColors.blackColor,
                          ),
                          AppText(
                            text: 'Contact Support',
                            color: AppColors.primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ), // 3% of screen height
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: Colors.grey[300]);
  }
}
