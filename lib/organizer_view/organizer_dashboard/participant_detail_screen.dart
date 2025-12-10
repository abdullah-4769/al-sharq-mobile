import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/data/response_models/organizer_response_models/organizer_dashboard_small_detail_show_model.dart';
import 'package:al_sharq_conference/view_model/organizer_viewmodels/organizer_block_user_viewmodel.dart';

class ParticipantDetailScreen extends StatefulWidget {
  final OrganizerDashboardSmallDetailShowRecentUser user;

  const ParticipantDetailScreen({super.key, required this.user});

  @override
  State<ParticipantDetailScreen> createState() => _ParticipantDetailScreenState();
}

class _ParticipantDetailScreenState extends State<ParticipantDetailScreen> {
  bool _isImageLoading = true;
  bool _imageLoadError = false;
  final OrganizerBlockUserViewModel _blockViewModel = OrganizerBlockUserViewModel();

  // Add this variable to track the current block status
  late bool _currentBlockStatus;

  @override
  void initState() {
    super.initState();
    // Initialize with the current block status from widget
    _currentBlockStatus = widget.user.isBlocked;

    // Simulate image loading delay to show loader
    if (widget.user.file != null && widget.user.file!.isNotEmpty) {
      _loadImage();
    } else {
      _isImageLoading = false;
    }
  }

  void _loadImage() async {
    try {
      // This simulates image loading - you can remove this in production
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isImageLoading = false;
      });
    } catch (e) {
      setState(() {
        _isImageLoading = false;
        _imageLoadError = true;
      });
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
          text: 'Participant Details',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Image with Loader
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
                  child: _buildProfileImage(),
                ),
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
                text: widget.user.role.toUpperCase(),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),

            const SizedBox(height: 32),

            // Participant Information Card
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
                  _buildInfoRow('Full Name', widget.user.name),
                  const SizedBox(height: 20),

                  // Email
                  _buildInfoRow('Email', widget.user.email),
                  const SizedBox(height: 20),

                  // Organization
                  _buildInfoRow('Organization', widget.user.organization ?? 'Not provided'),
                  const SizedBox(height: 20),

                  // Phone
                  _buildInfoRow('Phone', widget.user.phone ?? 'Not provided'),
                  const SizedBox(height: 20),

                  // User ID
                  _buildInfoRow('User ID', widget.user.id.toString()),
                  const SizedBox(height: 20),

                  // Registration Date
                  _buildInfoRow(
                    'Registered On',
                    '${widget.user.createdAt.day}/${widget.user.createdAt.month}/${widget.user.createdAt.year}',
                  ),
                  const SizedBox(height: 20),

                  // Account Status - Use _currentBlockStatus instead of widget.user.isBlocked
                  _buildStatusRow('Account Status', _currentBlockStatus),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                // Expanded(
                //   child: ElevatedButton.icon(
                //     onPressed: () {
                //       _showMessageDialog();
                //     },
                //     icon: const Icon(Icons.message, color: Colors.white, size: 20),
                //     label: const AppText(
                //       text: 'Send Message',
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
                //       padding: const EdgeInsets.symmetric(vertical: 12),
                //     ),
                //   ),
                // ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    return ElevatedButton.icon(
                      onPressed: _blockViewModel.isLoading.value
                          ? null
                          : () {
                        _showBlockDialog(_currentBlockStatus);
                      },
                      icon: Icon(
                        _currentBlockStatus ? Icons.lock_open : Icons.block,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: _blockViewModel.isLoading.value
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : AppText(
                        text: _currentBlockStatus ? 'Unblock' : 'Block',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentBlockStatus ? Colors.green : Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (widget.user.file == null || widget.user.file!.isEmpty) {
      return _buildDefaultAvatar();
    }

    if (_isImageLoading) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      );
    }

    if (_imageLoadError) {
      return _buildDefaultAvatar();
    }

    return Image.network(
      widget.user.file!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade200,
          child: Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildDefaultAvatar();
      },
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

  Widget _buildInfoRow(String label, String value) {
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

  Widget _buildStatusRow(String label, bool isBlocked) {
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
            color: isBlocked ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isBlocked ? Colors.red.shade200 : Colors.green.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isBlocked ? Colors.red : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                text: isBlocked ? 'Suspended' : 'Active',
                fontSize: 14,
                color: isBlocked ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMessageDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const AppText(
            text: 'Send Message',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: 'This feature will allow you to send messages to participants.',
                fontSize: 14,
                color: AppColors.darkgrey,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const AppText(
                text: 'Cancel',
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Get.snackbar(
                //   'Message Sent',
                //   'Message sent to ${widget.user.name}',
                //   backgroundColor: Colors.green,
                //   colorText: Colors.white,
                // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const AppText(
                text: 'Send',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBlockDialog(bool isCurrentlyBlocked) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: AppText(
            text: isCurrentlyBlocked ? 'Unblock User' : 'Block User',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          content: AppText(
            text: isCurrentlyBlocked
                ? 'Are you sure you want to unblock ${widget.user.name}?'
                : 'Are you sure you want to block ${widget.user.name}? They will not be able to access the app.',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const AppText(
                text: 'Cancel',
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await _blockViewModel.blockUser(widget.user.id, !isCurrentlyBlocked);
                if (success) {
                  // Update local state instead of navigating back
                  setState(() {
                    _currentBlockStatus = !isCurrentlyBlocked;
                  });

                  // Get.snackbar(
                  //   isCurrentlyBlocked ? 'User Unblocked' : 'User Blocked',
                  //   '${widget.user.name} has been ${isCurrentlyBlocked ? 'unblocked' : 'blocked'}',
                  //   backgroundColor: isCurrentlyBlocked ? Colors.green : Colors.red,
                  //   colorText: Colors.white,
                  // );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentlyBlocked ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: AppText(
                text: isCurrentlyBlocked ? 'Unblock' : 'Block',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _blockViewModel.dispose();
    super.dispose();
  }
}