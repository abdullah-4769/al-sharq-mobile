import 'dart:io';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/form_label.dart';
import 'package:al_sharq_conference/participants_view/home_page/home_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/conference_logo.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';

class SpeakerSetupProfileScreen extends StatefulWidget {
  const SpeakerSetupProfileScreen({super.key});

  @override
  State<SpeakerSetupProfileScreen> createState() => _SpeakerSetupProfileScreenState();
}

class _SpeakerSetupProfileScreenState extends State<SpeakerSetupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _emailController = TextEditingController();
  final _industryFocusController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _linkedBoothController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await showModalBottomSheet<XFile?>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Pick from Gallery'),
                    onTap: () async {
                      final pickedFile = await _picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        Navigator.pop(context, pickedFile);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Take a Photo'),
                    onTap: () async {
                      final pickedFile = await _picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (pickedFile != null) {
                        Navigator.pop(context, pickedFile);
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeView()));
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _organizationController.dispose();
    _emailController.dispose();
    _industryFocusController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _linkedBoothController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width * 0.06),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ConferenceLogo(),
              SizedBox(height: height * 0.050),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 30),
                  Center(
                    child: AppText(
                      text: 'Set Up Your Profile',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.010),
              AppText(
                text:
                'Complete your profile to personalize your event experience and connect with others.',
                textAlign: TextAlign.center,
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
              SizedBox(height: height * 0.030),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.lightred,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primaryColor,
                      )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              AppText(
                text: "Upload or Take photo",
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(height: height * 0.032),
              const FormLabel(text: "Full Name", isRequired: true),
              CustomTextField(
                hintText: 'Full Name',
                controller: _fullNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.024),
              const FormLabel(text: "Organization/Company", isRequired: true),
              CustomTextField(
                hintText: 'Organization',
                controller: _organizationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your organization';
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.024),
              const FormLabel(text: "Contact Email", isRequired: true),
              CustomTextField(
                hintText: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.024),
              const FormLabel(text: "Industry Focus", isRequired: true),
              CustomTextField(
                hintText: 'Technology',
                controller: _industryFocusController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your industry focus';
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.024),
              const FormLabel(text: "Set New Password", isRequired: true),
              CustomTextField(
                hintText: 'Password',
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.024),
              const FormLabel(text: "Confirm New Password", isRequired: true),
              CustomTextField(
                hintText: 'Confirm Password',
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.024),
              const FormLabel(text: "Linked Booth Exhibitors", isRequired: true),
              CustomTextField(
                hintText: 'Innovation in Sustainable Energy',
                controller: _linkedBoothController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter linked booth exhibitors';
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.024),
              const FormLabel(text: "Website", isRequired: true),
              CustomTextField(
                hintText: 'www.website.com',
                controller: _websiteController,
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your website';
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.024),
              const FormLabel(text: "Description", isRequired: true),
              CustomTextField(
                hintText: 'Describe your topic in detail',
                controller: _descriptionController,
               // maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: height * 0.032),
              CustomButton(
                text: 'Save & Continue',
                onPressed: _saveProfile,
              ),
              SizedBox(height: height * 0.070),
            ],
          ),
        ),
      ),
    );
  }
}