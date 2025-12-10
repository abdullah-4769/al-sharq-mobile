import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/utils/shared_preference.dart';
import '../../participants_view/qr_code_scanner/qr_code_scanner_view.dart';
import '../../view_model/login_view_model.dart';
import '../../view_model/participant_viewmodel/participant_profile/participant_profile_get_viewmodel.dart';
import 'organizer_edit_profile_scvreen.dart';


class OrganizerProfileScreen extends StatefulWidget {
  const OrganizerProfileScreen({super.key});

  @override
  State<OrganizerProfileScreen> createState() => _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends State<OrganizerProfileScreen> {
  final ParticipantProfileGetViewModel _profileViewModel = Get.put(ParticipantProfileGetViewModel());
  final LoginViewModel _loginViewModel = Get.find<LoginViewModel>();

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoadProfile();
  }

  Future<void> _checkAuthenticationAndLoadProfile() async {
    final isLoggedIn = await SharedPrefsHelper.isUserLoggedIn();
    if (isLoggedIn) {
      _profileViewModel.fetchProfile();
    } else {
      Get.snackbar(
        'Authentication Error',
        'Please login again',
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
          text: 'Profile',
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
                if (_profileViewModel.profile != null) {
                  Get.to(() => OrganizerEditProfileScreen(
                    currentName: _profileViewModel.profile!.name,
                    currentEmail: _profileViewModel.profile!.email,
                    currentOrganization: _profileViewModel.profile!.organization,
                    currentImageUrl: _profileViewModel.profile!.file,
                  ));
                }
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
                Get.to(() => QRPassScreen());
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
      body: Obx(() => _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_profileViewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      );
    }

    if (_profileViewModel.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              text: _profileViewModel.error,
              color: Colors.red,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (_profileViewModel.error.contains('authenticated') ||
                _profileViewModel.error.contains('Authentication failed'))
              ElevatedButton(
                onPressed: () {
                  Get.offAllNamed('/login');
                },
                child: const AppText(text: 'Go to Login'),
              )
            else
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

    if (_profileViewModel.profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppText(text: 'No profile data found'),
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

    final profile = _profileViewModel.profile!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Profile Image
            Center(
              child: Stack(
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
                      child: profile.file != null && profile.file!.isNotEmpty
                          ? Image.network(
                        profile.file!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultAvatar();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildDefaultAvatar();
                        },
                      )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // User Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lightred,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AppText(
                text: profile.role,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),

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
                  // Full Name
                  const AppText(
                    text: 'Full Name',
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
                      text: profile.name,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Organization
                  const AppText(
                    text: 'Organization',
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
                      text: profile.organization,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Email
                  const AppText(
                    text: 'Email',
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
                      text: profile.email,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            //
            // // Logout Button
            // SizedBox(
            //   width: double.infinity,
            //   height: 50,
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       _showLogoutDialog();
            //     },
            //     icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            //     label: const AppText(
            //       text: 'Logout',
            //       fontSize: 16,
            //       fontWeight: FontWeight.w600,
            //       color: Colors.white,
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primaryColor,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       elevation: 0,
            //     ),
            //   ),
            // ),

            const SizedBox(height: 32),
          ],
        ),
      ),
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
                await _loginViewModel.logout();
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