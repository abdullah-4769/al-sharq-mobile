import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/form_label.dart';
import 'package:flutter/material.dart';

import '../../custom_widgets/conference_logo.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';

class SpeakerResetPasswordScreen extends StatefulWidget {
  const SpeakerResetPasswordScreen({super.key});

  @override
  State<SpeakerResetPasswordScreen> createState() => _SpeakerResetPasswordScreenState();
}

class _SpeakerResetPasswordScreenState extends State<SpeakerResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successful!')),
      );
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          const ConferenceLogo(),

          const SizedBox(height: 40),

      
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                vertical: 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      text:
                          "Choose a strong password to secure your account. Make sure it's something you'll remember.",
                      textAlign: TextAlign.center,
                      fontSize: 14,
                      color: AppColors.darkgrey,
                    ),
                    const SizedBox(height: 48),

                    const FormLabel(text: "New Password", isRequired: true),
                    CustomTextField(
                      hintText: "*******",
                      controller: _newPasswordController,
                      obscureText: true,
                      suffixIcon: Icons.visibility,
                      suffixIconColor: Colors.grey[400],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter new password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    const FormLabel(
                      text: "Confirm New Password",
                      isRequired: true,
                    ),
                    CustomTextField(
                      hintText: "*******",
                      controller: _confirmPasswordController,
                      obscureText: true,
                      suffixIcon: Icons.visibility,
                      suffixIconColor: Colors.grey[400],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.help_outline, color: AppColors.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText(
                            text:
                                "Password must be at least 8 characters long and include at least one uppercase letter, one lowercase letter, one number, and one special character.",
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Save Change',
                      onPressed: _resetPassword,
                    ),
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
