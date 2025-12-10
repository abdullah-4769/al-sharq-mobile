import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

import '../../view_model/organizer_viewmodels/organizeraddnewsponsor_viewmodel.dart';


class OrganizerAddNewSponsorScreen extends StatefulWidget {
  const OrganizerAddNewSponsorScreen({super.key});

  @override
  State<OrganizerAddNewSponsorScreen> createState() => _OrganizerAddNewSponsorScreenState();
}

class _OrganizerAddNewSponsorScreenState extends State<OrganizerAddNewSponsorScreen> {
  final OrganizerAddNewSponsorViewModel viewModel = Get.put(OrganizerAddNewSponsorViewModel());

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

  String selectedCategory = 'silver';
  final List<String> categories = ['silver', 'gold'];

  bool get _isFormValid {
    return nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
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
    selectedCategory = 'silver';
    viewModel.clearMessages();
  }

  Future<void> _showCancelConfirmation() async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const AppText(
            text: 'Cancel Adding Sponsor',
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

  Future<void> _addSponsor() async {
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

    final success = await viewModel.addNewSponsor(
      name: nameController.text,
      description: descriptionController.text,
      category: selectedCategory,
      picUrl: picUrlController.text.isEmpty ? 'https://example.com/image.png' : picUrlController.text,
      linkedin: linkedinController.text.isEmpty ? 'https://linkedin.com/company/example' : linkedinController.text,
      twitter: twitterController.text.isEmpty ? 'https://twitter.com/example' : twitterController.text,
      youtube: youtubeController.text.isEmpty ? 'https://youtube.com/example' : youtubeController.text,
      email: emailController.text,
      phone: phoneController.text,
      password: passwordController.text,
    );

    if (success) {
      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sponsor added successfully!')),
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
          text: 'Add New Sponsor',
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
              // Sponsor Name
              const AppText(
                text: 'Sponsor Name*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: nameController,
                hintText: 'Enter Sponsor Name',
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

              // Category
              const AppText(
                text: 'Category*',
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
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: AppText(
                          text: value.toUpperCase(),
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
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

              // Description/Bio
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
                    hintText: 'Enter sponsor description',
                    hintStyle: TextStyle(color: AppColors.darkgrey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Optional Fields
              const AppText(
                text: 'Profile Picture URL (Optional)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: picUrlController,
                hintText: 'https://example.com/image.png',
              ),

              const SizedBox(height: 20),

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
                      text: 'Add Sponsor',
                      onPressed: _addSponsor,
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
    super.dispose();
  }
}