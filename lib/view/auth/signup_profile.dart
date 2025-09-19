import 'dart:io';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/form_label.dart';
import 'package:al_sharq_conference/view/home_page/home_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/conference_logo.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _organizationController = TextEditingController();
  final _emailController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await showModalBottomSheet<XFile?>(
        context: context,
        isScrollControlled: true, // Allows the sheet to expand if needed
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),

      );
      Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeView()));
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _organizationController.dispose();
    _emailController.dispose();
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
              const FormLabel(text: "Organizatio/company", isRequired: true),
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
              SizedBox(height: height * 0.040),
              const FormLabel(text: "Contact email", isRequired: true),
              CustomTextField(
                hintText: 'Email Address',
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
              SizedBox(height: height * 0.032),
              CustomButton(text: 'Save & Continue', onPressed:(){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeView()));

              }
             // _saveProfile
              ),
              SizedBox(height: height * 0.070),
            ],
          ),
        ),
      ),
    );
  }
}
