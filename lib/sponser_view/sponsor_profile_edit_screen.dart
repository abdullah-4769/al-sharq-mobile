import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';

import '../../view_model/sponsor_viewmodel/sponsor_profile_get_viewmodel.dart';
import '../../view_model/sponsor_viewmodel/sponsor_profile_update_viewmodel.dart';
import '../custom_widgets/custom_text_field.dart';
import '../data/response_models/sponsor_respone_model/sponsor_profile_get_model.dart';
import '../data/response_models/sponsor_respone_model/sponsor_profile_update_model.dart';

class SponsorProfileEditScreen extends StatefulWidget {
  final SponsorProfileGetModel profile;

  const SponsorProfileEditScreen({super.key, required this.profile});

  @override
  State<SponsorProfileEditScreen> createState() => _SponsorProfileEditScreenState();
}

class _SponsorProfileEditScreenState extends State<SponsorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedCategory = '';
  String _profileImageUrl = '';
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _nameController.text = widget.profile.name;
    _descriptionController.text = widget.profile.description;
    _websiteController.text = widget.profile.website;
    _emailController.text = widget.profile.email;
    _phoneController.text = widget.profile.phone;
    _linkedinController.text = widget.profile.linkedin;
    _twitterController.text = widget.profile.twitter;
    _youtubeController.text = widget.profile.youtube;
    _selectedCategory = widget.profile.category;
    _profileImageUrl = widget.profile.picUrl;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        // Here you would typically upload the image to your server
        // For now, we'll just use the local path
        setState(() {
          _profileImageUrl = image.path;
        });

        // Call your image upload function here
        // await _uploadImage(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final updateViewModel = Get.find<SponsorProfileUpdateViewModel>();
    final profileViewModel = Get.find<SponsorProfileGetViewModel>();

    final updateData = SponsorProfileUpdateModel(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      picUrl: _profileImageUrl,
      linkedin: _linkedinController.text.trim(),
      twitter: _twitterController.text.trim(),
      youtube: _youtubeController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final success = await updateViewModel.updateSponsorProfile(updateData);

    if (success) {
      // Refresh the profile data
       profileViewModel.refreshProfile();

      Get.back(); // ← Removed 'await'
      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        backgroundColor: AppColors.successColor,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        updateViewModel.errorMessage.value,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateViewModel = Get.find<SponsorProfileUpdateViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppText(
          text: 'Edit Profile',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (updateViewModel.isLoading.value) {
          return _buildLoadingState();
        }

        return _buildEditForm();
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          SizedBox(height: 16),
          AppText(
            text: 'Updating profile...',
            fontSize: 16,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Profile Image
            _buildProfileImageSection(),
            SizedBox(height: 24),

            // Basic Information
            _buildBasicInfoSection(),
            SizedBox(height: 24),

            // Company Information
            _buildCompanyInfoSection(),
            SizedBox(height: 24),

            // Contact Information
            _buildContactInfoSection(),
            SizedBox(height: 24),

            // Social Media
            _buildSocialMediaSection(),
            SizedBox(height: 24),

            // Security
            _buildSecuritySection(),
            SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          AppText(
            text: 'Profile Image',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          SizedBox(height: 16),
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.mediumGreyColor,
                backgroundImage: _profileImageUrl.isNotEmpty
                    ? (_profileImageUrl.startsWith('http')
                    ? NetworkImage(_profileImageUrl)
                    : AssetImage(_profileImageUrl) as ImageProvider)
                    : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                child: _profileImageUrl.isEmpty
                    ? Icon(Icons.business, size: 50, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: _pickImage,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Basic Information',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _nameController,
       //     labelText: 'Company Name',
            hintText: 'Enter company name',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter company name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: 'Sponsor Category',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.mediumGreyColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.mediumGreyColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: [
                  'Gold',
                  'Silver',
                  'Bronze',
                  'Platinum',
                  'Other',
                ].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Company Information',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _descriptionController,

           // labelText: 'Description',
            hintText: 'Enter company description',
            maxLines: 4,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _websiteController,
           // labelText: 'Website',
            hintText: 'https://example.com',
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Contact Information',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
          //  labelText: 'Email',
            hintText: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter email address';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
           // labelText: 'Phone',
            hintText: 'Enter phone number',
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Social Media',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _linkedinController,
            //labelText: 'LinkedIn',
            hintText: 'LinkedIn profile URL',
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _twitterController,
            //labelText: 'Twitter',
            hintText: 'Twitter profile URL',
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _youtubeController,
           // labelText: 'YouTube',
            hintText: 'YouTube channel URL',
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Security',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          SizedBox(height: 16),
          AppText(
            text: 'Leave password empty to keep current password',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
           // labelText: 'New Password',
            hintText: 'Enter new password',
            obscureText: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Cancel',
            onPressed: () => Get.back(),
            backgroundColor: AppColors.mediumGreyColor,
            textColor: AppColors.blackColor,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'Save Changes',
            onPressed: _updateProfile,
            backgroundColor: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _youtubeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}