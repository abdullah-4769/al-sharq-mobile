import 'package:al_sharq_conference/sponser_view/sponsor_profile_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_drawer.dart';
import '../../view_model/sponsor_viewmodel/sponsor_profile_get_viewmodel.dart';
import '../../view_model/sponsor_viewmodel/sponsor_profile_update_viewmodel.dart';
import '../data/response/api_response.dart';
import '../data/response_models/sponsor_respone_model/sponsor_profile_get_model.dart';

class SponsorProfileScreen extends StatelessWidget {
  const SponsorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Get.find<SponsorProfileGetViewModel>();
    final updateViewModel = Get.find<SponsorProfileUpdateViewModel>();

    return Scaffold(
      drawer: const CustomAppDrawer(),
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppText(
          text: 'Sponsor Profile',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.primaryColor),
            onPressed: () {
              final profile = profileViewModel.sponsorProfile.value?.data;
              if (profile != null) {
                Get.to(() => SponsorProfileEditScreen(profile: profile));
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (profileViewModel.isLoading.value) {
          return _buildLoadingState();
        }

        if (profileViewModel.sponsorProfile.value?.status == Status.ERROR) {
          return _buildErrorState(profileViewModel);
        }

        final profile = profileViewModel.sponsorProfile.value?.data;
        if (profile == null) {
          return _buildEmptyState();
        }

        return _buildProfileContent(profile);
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
            text: 'Loading profile...',
            fontSize: 16,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SponsorProfileGetViewModel viewModel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.errorColor),
            SizedBox(height: 16),
            AppText(
              text: 'Failed to load profile',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            SizedBox(height: 8),
            AppText(
              text: viewModel.errorMessage.value,
              fontSize: 14,
              color: AppColors.darkgrey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Retry',
              onPressed: () => viewModel.refreshProfile(),
              backgroundColor: AppColors.primaryColor,
              height: 40,
              width: 120,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: AppColors.mediumGreyColor),
          SizedBox(height: 16),
          AppText(
            text: 'No profile data',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          SizedBox(height: 8),
          AppText(
            text: 'Unable to load sponsor profile information.',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(SponsorProfileGetModel profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(profile),
          SizedBox(height: 24),

          // Company Information
          _buildInfoSection(profile),
          SizedBox(height: 24),

          // Contact Information
          _buildContactSection(profile),
          SizedBox(height: 24),

          // Social Media
          _buildSocialSection(profile),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(SponsorProfileGetModel profile) {
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
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.mediumGreyColor,
            backgroundImage: profile.picUrl.isNotEmpty
                ? NetworkImage(profile.picUrl)
                : AssetImage('assets/images/default_avatar.png') as ImageProvider,
            child: profile.picUrl.isEmpty
                ? Icon(Icons.business, size: 40, color: Colors.white)
                : null,
          ),
          SizedBox(height: 16),
          AppText(
            text: profile.name,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getCategoryColor(profile.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: AppText(
              text: '${profile.category} Sponsor',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getCategoryColor(profile.category),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(SponsorProfileGetModel profile) {
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
          if (profile.description.isNotEmpty) ...[
            AppText(
              text: profile.description,
              fontSize: 14,
              color: AppColors.darkgrey,
            ),
            SizedBox(height: 16),
          ],
          if (profile.website.isNotEmpty) ...[
            _buildInfoItem(
              icon: Icons.language,
              title: 'Website',
              value: profile.website,
              iconColor: Colors.blue,
            ),
            SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection(SponsorProfileGetModel profile) {
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
          if (profile.email.isNotEmpty) ...[
            _buildInfoItem(
              icon: Icons.email,
              title: 'Email',
              value: profile.email,
              iconColor: Colors.green,
            ),
            SizedBox(height: 12),
          ],
          if (profile.phone.isNotEmpty) ...[
            _buildInfoItem(
              icon: Icons.phone,
              title: 'Phone',
              value: profile.phone,
              iconColor: Colors.blue,
            ),
            SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialSection(SponsorProfileGetModel profile) {
    bool hasSocialMedia = profile.linkedin.isNotEmpty ||
        profile.twitter.isNotEmpty ||
        profile.youtube.isNotEmpty;

    if (!hasSocialMedia) return SizedBox();

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
          if (profile.linkedin.isNotEmpty) ...[
            _buildInfoItem(
              icon: Icons.link,
              title: 'LinkedIn',
              value: profile.linkedin,
              iconColor: Colors.blue[700]!,
            ),
            SizedBox(height: 12),
          ],
          if (profile.twitter.isNotEmpty) ...[
            _buildInfoItem(
              icon: Icons.link,
              title: 'Twitter',
              value: profile.twitter,
              iconColor: Colors.lightBlue,
            ),
            SizedBox(height: 12),
          ],
          if (profile.youtube.isNotEmpty) ...[
            _buildInfoItem(
              icon: Icons.link,
              title: 'YouTube',
              value: profile.youtube,
              iconColor: Colors.red,
            ),
            SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: title,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
              SizedBox(height: 4),
              AppText(
                text: value,
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      case 'bronze':
        return Colors.orange[800]!;
      case 'platinum':
        return Colors.blue;
      default:
        return AppColors.primaryColor;
    }
  }
}