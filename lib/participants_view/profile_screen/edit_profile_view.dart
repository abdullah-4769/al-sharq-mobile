import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import '../../view_model/participant_viewmodel/participant_profile/participant_profile_get_viewmodel.dart';
import '../../view_model/participant_viewmodel/participant_profile/participant_profile_update_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentOrganization;
  final String? currentImageUrl;
  final String? currentBio; // ADD THIS

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.currentOrganization,
    this.currentImageUrl,
    this.currentBio, // ADD THIS
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  //late TextEditingController _organizationController;
  late TextEditingController _bioController; // ADD THIS
  final ParticipantProfileUpdateViewModel _updateViewModel = Get.put(ParticipantProfileUpdateViewModel());
  final ParticipantProfileGetViewModel _profileViewModel = Get.find<ParticipantProfileGetViewModel>();

  File? _selectedImage;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    //_organizationController = TextEditingController(text: widget.currentOrganization);
    _bioController = TextEditingController(text: widget.currentBio ?? ''); // ADD THIS
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
   // _organizationController.dispose();
    _bioController.dispose(); // ADD THIS
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const AppText(text: 'Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const AppText(text: 'Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const AppText(text: 'Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final success = await _updateViewModel.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
       // organization: _organizationController.text.trim(),
        filePath: _imagePath,
        bio: _bioController.text.trim(), // ADD THIS
      );

      if (success) {
        // Refresh the profile data
        await _profileViewModel.fetchProfile();

        Get.back();
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          _updateViewModel.error,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const AppText(
          text: 'Edit Profile',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          Obx(() {
            if (_updateViewModel.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryColor,
                  ),
                ),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Image with Edit Option
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: _selectedImage != null
                          ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      )
                          : (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty
                          ? Image.network(
                        widget.currentImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar();
                        },
                      )
                          : _buildDefaultAvatar()),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.whiteColor,
                          width: 3,
                        ),
                      ),
                      child: IconButton(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Name Field
              _buildFormField(
                label: 'Full Name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

             // const SizedBox(height: 20),

              // // Organization Field
              // _buildFormField(
              //   label: 'Organization',
              //   controller: _organizationController,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your organization';
              //     }
              //     return null;
              //   },
              // ),

              const SizedBox(height: 20),

              // Email Field
              _buildFormField(
                label: 'Email',
                controller: _emailController,
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

              const SizedBox(height: 40),
              // Bio Field - ADD THIS NEW SECTION
              _buildFormField(
                label: 'Bio',
                controller: _bioController,
                //maxLines: 4, // ADD THIS for multi-line bio
                validator: (value) {
                  // Bio can be optional, so no validation needed
                  return null;
                },
              ),
              const SizedBox(height: 40),
              // Save Button
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _updateViewModel.isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _updateViewModel.isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const AppText(
                      text: 'Save Changes',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    int maxLines = 1, // ADD THIS parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontSize: 12,
          color: AppColors.darkgrey,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines, // ADD THIS
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.brown,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }
}