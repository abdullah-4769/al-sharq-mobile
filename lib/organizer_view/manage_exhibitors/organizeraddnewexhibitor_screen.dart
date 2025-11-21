import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

import '../../view_model/organizer_viewmodels/organizeraddnewexhibitor_viewmodel.dart';

class OrganizerAddNewExhibitorScreen extends StatefulWidget {
  const OrganizerAddNewExhibitorScreen({super.key});

  @override
  State<OrganizerAddNewExhibitorScreen> createState() => _OrganizerAddNewExhibitorScreenState();
}

class _OrganizerAddNewExhibitorScreenState extends State<OrganizerAddNewExhibitorScreen> {
  final OrganizerAddNewExhibitorViewModel viewModel = Get.put(OrganizerAddNewExhibitorViewModel());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController picUrlController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController twitterController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  bool get _isFormValid {
    return nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        websiteController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;
  }

  void _resetForm() {
    nameController.clear();
    emailController.clear();
    descriptionController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    picUrlController.clear();
    linkedinController.clear();
    twitterController.clear();
    youtubeController.clear();
    phoneController.clear();
    locationController.clear();
    websiteController.clear();
    viewModel.clearMessages();
  }

  Future<void> _showCancelConfirmation() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const AppText(
            text: 'Cancel Adding Exhibitor',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          content: const AppText(
            text: 'Are you sure you want to cancel? All entered data will be lost.',
            fontSize: 14,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const AppText(
                text: 'No',
                color: AppColors.primaryColor,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const AppText(
                text: 'Yes',
                color: Colors.red,
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _resetForm();
      Navigator.pop(context);
    }
  }

  Future<void> _addExhibitor() async {
    if (!_isFormValid) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields!')),
      );
      return;
    }

    final success = await viewModel.addNewExhibitor(
      name: nameController.text,
      picUrl: picUrlController.text.isEmpty ? 'https://example.com/pic.jpg' : picUrlController.text,
      description: descriptionController.text,
      location: locationController.text,
      website: websiteController.text,
      email: emailController.text,
      phone: phoneController.text,
      linkedin: linkedinController.text.isEmpty ? 'https://linkedin.com/company/example' : linkedinController.text,
      twitter: twitterController.text.isEmpty ? 'https://twitter.com/example' : twitterController.text,
      youtube: youtubeController.text.isEmpty ? 'https://youtube.com/example' : youtubeController.text,
      password: passwordController.text,
    );

    if (success) {
      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exhibitor added successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage.value)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _showCancelConfirmation,
        ),
        title: const AppText(
          text: 'Add New Exhibitor',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exhibitor Name
              const AppText(
                text: 'Exhibitor Name*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: nameController,
                hintText: 'Enter Exhibitor Name',
              ),

              const SizedBox(height: 20),

              // Contact Email
              const AppText(
                text: 'Contact Email*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: emailController,
                hintText: 'example@company.com',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // Location
              const AppText(
                text: 'Location*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: locationController,
                hintText: 'Enter location (e.g., New York)',
              ),

              const SizedBox(height: 20),

              // Website
              const AppText(
                text: 'Website*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: websiteController,
                hintText: 'https://company.com',
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 20),

              // Phone
              const AppText(
                text: 'Phone*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: phoneController,
                hintText: '+1234567890',
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              // Password
              const AppText(
                text: 'Set Password*',
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

              // Confirm Password
              const AppText(
                text: 'Confirm Password*',
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

              // Description
              const AppText(
                text: 'Description*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: descriptionController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Enter exhibitor description',
                    hintStyle: TextStyle(color: AppColors.darkgrey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Profile Picture URL
              const AppText(
                text: 'Profile Picture URL (Optional)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: picUrlController,
                hintText: 'https://example.com/pic.jpg',
              ),

              const SizedBox(height: 20),

              // LinkedIn URL
              const AppText(
                text: 'LinkedIn URL (Optional)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: linkedinController,
                hintText: 'https://linkedin.com/company/example',
              ),

              const SizedBox(height: 20),

              // Twitter URL
              const AppText(
                text: 'Twitter URL (Optional)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: twitterController,
                hintText: 'https://twitter.com/example',
              ),

              const SizedBox(height: 20),

              // YouTube URL
              const AppText(
                text: 'YouTube URL (Optional)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: youtubeController,
                hintText: 'https://youtube.com/example',
              ),

              const SizedBox(height: 40),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showCancelConfirmation,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const AppText(
                        text: 'Cancel',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Add Exhibitor',
                      onPressed: _addExhibitor,
                      backgroundColor: AppColors.primaryColor,
                      height: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    picUrlController.dispose();
    linkedinController.dispose();
    twitterController.dispose();
    youtubeController.dispose();
    phoneController.dispose();
    locationController.dispose();
    websiteController.dispose();
    super.dispose();
  }
}