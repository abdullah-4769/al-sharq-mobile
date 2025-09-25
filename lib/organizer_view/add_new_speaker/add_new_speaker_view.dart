
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';

class AddNewSpeakerScreen extends StatefulWidget {
  const AddNewSpeakerScreen({super.key});

  @override
  State<AddNewSpeakerScreen> createState() => _AddNewSpeakerScreenState();
}

class _AddNewSpeakerScreenState extends State<AddNewSpeakerScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  final List<String> specialties = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText(
          text: 'Add New Speakers',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              text: 'Full Name',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: nameController,
              hintText: 'Enter a speaker Name',
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Speaker Email',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: emailController,
              hintText: 'example@techcorp.com',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Set Password',
              fontSize: 16,
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

            const SizedBox(height: 20),

            const AppText(
              text: 'Confirm Password',
              fontSize: 16,
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

            const SizedBox(height: 20),

            const AppText(
              text: 'Organization / Institution',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: organizationController,
              hintText: 'Enter organization name',
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Bio/Description',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Speaker experience brief details...',
                  hintStyle: TextStyle(color: AppColors.darkgrey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Latest Session',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const AppText(
                text: 'Innovation in Sustainable Energy',
                fontSize: 14,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Website',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: websiteController,
              hintText: 'www.techcorp.com',
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Specialty',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: 'e.g. AI, Machine Learning',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const AppText(
                    text: 'Add',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Display specialty tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSpecialtyTag('Innovation', Colors.blue),
                _buildSpecialtyTag('Sustainability', Colors.pink),
              ],
            ),

            const SizedBox(height: 40),

            CustomButton(
              text: 'Create',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Speaker created successfully!')),
                );
              },
              backgroundColor: AppColors.primaryColor,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialtyTag(String tag, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: tag,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              // Remove tag
            },
            child: Icon(Icons.close, size: 14, color: color),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    organizationController.dispose();
    websiteController.dispose();
    super.dispose();
  }
}