import 'package:al_sharq_conference/speaker_view/speaker_dashboard_view/speaker_edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/utils/shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/response_models/speaker_response_models/speaker_dashboard_show_model.dart';
import '../../view_model/speaker_viewmodels/speaker_dashboard_show_viewmodel.dart';
import '../../view_model/login_view_model.dart'; // Add this import

class SpeakerDashboardScreen extends StatefulWidget {
  const SpeakerDashboardScreen({super.key});

  @override
  State<SpeakerDashboardScreen> createState() => _SpeakerDashboardScreenState();
}

class _SpeakerDashboardScreenState extends State<SpeakerDashboardScreen> {
  final SpeakerDashboardShowViewModel _speakerViewModel = Get.put(SpeakerDashboardShowViewModel());
  final LoginViewModel _loginViewModel = Get.find<LoginViewModel>(); // Add this

  int? _speakerId;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoadProfile();
  }

  Future<void> _checkAuthenticationAndLoadProfile() async {
    final isLoggedIn = await SharedPrefsHelper.isUserLoggedIn();
    if (isLoggedIn) {
      // Get speaker ID from shared preferences
      _speakerId = await SharedPrefsHelper.getSpeakerId();

      if (_speakerId != null) {
        await _speakerViewModel.fetchSpeakerProfile(_speakerId!);
      } else {
        // If no speaker ID, try to get by user ID
        final userId = await SharedPrefsHelper.getUserId();
        if (userId != null) {
          await _speakerViewModel.fetchSpeakerProfileByUserId(userId);
          if (_speakerViewModel.speakerProfile != null) {
            _speakerId = _speakerViewModel.speakerProfile!.id;
            // Save speaker ID to shared preferences for future use
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('speaker_id', _speakerId!);
          }
        }
      }
    } else {
      Get.snackbar(
        'Authentication Error',
        'Please login again',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open the link',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid URL',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const AppText(
          text: 'Speaker Dashboard',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
        actions: [
          // Edit Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                Get.to(() => SpeakerEditProfileScreen(speakerId: _speakerId!));

              },
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          // QR Code Button
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                Get.snackbar('Info', 'QR Code functionality coming soon');
              },
              icon: const Icon(
                Icons.qr_code,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (_speakerViewModel.isLoading) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
              SizedBox(height: 16),
              AppText(
                text: 'Loading speaker profile...',
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ],
          ),
        );
      }

      if (_speakerViewModel.error.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                text: _speakerViewModel.error,
                color: Colors.red,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _checkAuthenticationAndLoadProfile();
                },
                child: const AppText(text: 'Retry'),
              ),
            ],
          ),
        );
      }

      final speaker = _speakerViewModel.speakerProfile;
      if (speaker == null) {
        return const Center(
          child: AppText(
            text: 'No speaker data found',
            color: Colors.grey,
          ),
        );
      }

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Profile Image
              Center(
                child: Container(
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
                    child: _speakerViewModel.hasUserImage
                        ? Image.network(
                      speaker.user.file!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(speaker.user.name);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildDefaultAvatar(speaker.user.name);
                      },
                    )
                        : _buildDefaultAvatar(speaker.user.name),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Speaker Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightred,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const AppText(
                  text: 'Speaker',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
              //
              // // Verified Badge (if verified)
              // if (speaker.verified) ...[
              //   const SizedBox(height: 8),
              //   Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              //     decoration: BoxDecoration(
              //       color: Colors.green[50],
              //       borderRadius: BorderRadius.circular(20),
              //       border: Border.all(color: Colors.green),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Icon(Icons.verified, size: 14, color: Colors.green[700]),
              //         const SizedBox(width: 4),
              //         AppText(
              //           text: 'Verified',
              //           fontSize: 12,
              //           fontWeight: FontWeight.w500,
              //           color: Colors.green[700]!,
              //         ),
              //       ],
              //     ),
              //   ),
              // ],

              const SizedBox(height: 32),

              // Profile Information Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.containerGreyColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    _buildInfoField('Name', speaker.user.name),
                    const SizedBox(height: 20),

                    // Email
                    _buildInfoField('Email', speaker.user.email),
                    const SizedBox(height: 20),

                    // Phone (if available)
                    if (speaker.user.phone != null && speaker.user.phone!.isNotEmpty) ...[
                      _buildInfoField('Phone', speaker.user.phone!),
                      const SizedBox(height: 20),
                    ],

                    // Country
                    _buildInfoField('Country', speaker.country),
                    const SizedBox(height: 20),

                    // Website (Clickable) - only if available
                    if (_speakerViewModel.hasWebsite) ...[
                      _buildClickableInfoField('Website', speaker.website!),
                      const SizedBox(height: 20),
                    ],

                    // Designations - only if available
                    if (_speakerViewModel.hasDesignations) ...[
                      _buildChipField('Designations', speaker.designations, Colors.blue),
                      const SizedBox(height: 20),
                    ],

                    // Expertise - only if available
                    if (_speakerViewModel.hasExpertise) ...[
                      _buildChipField('Expertise', speaker.expertise, Colors.teal),
                      const SizedBox(height: 20),
                    ],

                    // Tags - only if available
                    if (_speakerViewModel.hasTags) ...[
                      _buildChipField('Tags', speaker.tags, Colors.orange),
                      const SizedBox(height: 20),
                    ],

                    // Bio
                    _buildBioField('Bio', speaker.bio),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Social Media Icons - only show if at least one social media exists
              if (_speakerViewModel.hasLinkedIn ||
                  _speakerViewModel.hasTwitter ||
                  _speakerViewModel.hasYouTube ||
                  _speakerViewModel.hasFacebook)
                _buildSocialMediaSection(speaker),

              const SizedBox(height: 32),

              // Switch to Participant Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showSwitchRoleDialog();
                  },
                  icon: const Icon(Icons.switch_account, color: Colors.white, size: 20),
                  label: const AppText(
                    text: 'Switch to Participant',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showLogoutDialog();
                  },
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                  label: const AppText(
                    text: 'Logout',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoField(String label, String value) {
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: AppText(
            text: value,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildClickableInfoField(String label, String value) {
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
        InkWell(
          onTap: () => _launchUrl(value),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    text: value,
                    fontSize: 14,
                    color: Colors.blue[700]!,
                  ),
                ),
                Icon(Icons.open_in_new, size: 16, color: Colors.blue[700]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipField(String label, List<String> items, Color baseColor) {
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: baseColor.withOpacity(0.3)),
                ),
                child: AppText(
                  text: item,
                  fontSize: 12,
                  color: baseColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBioField(String label, String value) {
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: AppText(
            text: value,
            fontSize: 14,
            color: Colors.black87,
            maxLines: null,
          ),
        ),
      ],
    );
  }
  //
  // Widget _buildSocialMediaSection(SpeakerDashboardShowModel speaker) {
  //   final socialMediaIcons = [
  //     if (_speakerViewModel.hasFacebook)
  //       _buildSocialIcon(
  //         icon: Icons.facebook,
  //         color: const Color(0xFF1877F2),
  //         url: speaker.facebook,
  //       ),
  //     if (_speakerViewModel.hasTwitter)
  //       _buildSocialIcon(
  //         icon: Icons.camera_alt,
  //         color: const Color(0xFF1DA1F2),
  //         url: speaker.twitter,
  //       ),
  //     if (_speakerViewModel.hasYouTube)
  //       _buildSocialIcon(
  //         icon: Icons.play_circle_fill,
  //         color: const Color(0xFFFF0000),
  //         url: speaker.youtube,
  //       ),
  //     if (_speakerViewModel.hasLinkedIn)
  //       _buildSocialIcon(
  //         icon: Icons.business_center,
  //         color: const Color(0xFF0A66C2),
  //         url: speaker.linkedin,
  //       ),
  //   ];
  //
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: AppColors.containerGreyColor),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Wrap(
  //       alignment: WrapAlignment.center,
  //       spacing: 12,
  //       runSpacing: 12,
  //       children: socialMediaIcons,
  //     ),
  //   );
  // }

  Widget _buildSocialMediaSection(SpeakerDashboardShowModel speaker) {
    final socialMediaIcons = [
      if (_speakerViewModel.hasFacebook)
        _buildSocialIcon(
          imagePath: 'assets/icons/Facebook.png', // Add your Facebook image
          url: speaker.facebook,
        ),
      if (_speakerViewModel.hasTwitter)
        _buildSocialIcon(
          imagePath: 'assets/icons/twiter.png', // Add your Twitter image
          url: speaker.twitter,
        ),
      if (_speakerViewModel.hasYouTube)
        _buildSocialIcon(
          imagePath: 'assets/icons/youtube.png', // Add your YouTube image
          url: speaker.youtube,
        ),
      if (_speakerViewModel.hasLinkedIn)
        _buildSocialIcon(
          imagePath: 'assets/icons/linkedin2.png', // Add your LinkedIn image
          url: speaker.linkedin,
        ),
      if (_speakerViewModel.hasWebsite)
        _buildSocialIcon(
          imagePath: 'assets/icons/website.png', // Add your Website image
          url: speaker.website,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.containerGreyColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: socialMediaIcons,
      ),
    );
  }

  Widget _buildSocialIcon({
    required String imagePath,
    required String? url,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Image.asset(
        imagePath,
        width: 28, // Same size as your icons
        height: 28,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    // Create initials from name for the avatar
    String initials = '';
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      initials = nameParts[0][0] + nameParts[1][0];
    } else if (name.isNotEmpty) {
      initials = name[0];
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppText(
          text: initials.toUpperCase(),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showSwitchRoleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const AppText(
            text: 'Switch Role',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          content: const AppText(
            text: 'Do you want to switch to Participant view?',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const AppText(
                text: 'Cancel',
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _loginViewModel.switchRole('participant');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const AppText(
                text: 'Switch',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const AppText(
            text: 'Logout',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          content: const AppText(
            text: 'Are you sure you want to logout?',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const AppText(
                text: 'Cancel',
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _loginViewModel.logout(); // Use loginViewModel logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const AppText(
                text: 'Logout',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}