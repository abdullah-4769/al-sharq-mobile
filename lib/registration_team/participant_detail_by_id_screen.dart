import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';

import '../view_model/participant_detail_viewmodel.dart';

class ParticipantDetailByIdScreen extends StatefulWidget {
  final int userId;

  const ParticipantDetailByIdScreen({super.key, required this.userId});

  @override
  State<ParticipantDetailByIdScreen> createState() => _ParticipantDetailByIdScreenState();
}

class _ParticipantDetailByIdScreenState extends State<ParticipantDetailByIdScreen> {
  final ParticipantDetailViewModel _viewModel = Get.put(ParticipantDetailViewModel());
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _isImageLoading = true;
  bool _imageLoadError = false;

  @override
  void initState() {
    super.initState();
    _loadParticipantData();
  }

  void _loadParticipantData() {
    _viewModel.fetchParticipantById(widget.userId);
    if (_viewModel.participant.value.file != null && _viewModel.participant.value.file!.isNotEmpty) {
      _loadImage();
    } else {
      _isImageLoading = false;
    }
  }

  void _loadImage() async {
    try {
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

  Widget _buildProfileImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
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
      imageUrl,
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
            text: value.isNotEmpty ? value : 'Not provided',
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
        // const SizedBox(height: 8),
        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        //   decoration: BoxDecoration(
        //     color: isBlocked ? Colors.red.shade50 : Colors.green.shade50,
        //     borderRadius: BorderRadius.circular(8),
        //     border: Border.all(
        //       color: isBlocked ? Colors.red.shade200 : Colors.green.shade200,
        //     ),
        //   ),
        //   child: Row(
        //     children: [
        //       Container(
        //         width: 8,
        //         height: 8,
        //         decoration: BoxDecoration(
        //           color: isBlocked ? Colors.red : Colors.green,
        //           shape: BoxShape.circle,
        //         ),
        //       ),
        //       const SizedBox(width: 8),
        //       // AppText(
        //       //   text: isBlocked ? 'Blocked' : 'Active',
        //       //   fontSize: 14,
        //       //   color: isBlocked ? Colors.red : Colors.green,
        //       //   fontWeight: FontWeight.w500,
        //       // ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildDateRow(String label, DateTime date) {
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final formattedTime = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: formattedDate,
                fontSize: 14,
                color: Colors.black87,
              ),
              const SizedBox(height: 4),
              AppText(
                text: formattedTime,
                fontSize: 12,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection(String? bio) {
    if (bio == null || bio.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 12),
            AppText(
              text: 'No bio provided',
              fontSize: 14,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.containerGreyColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, size: 20, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              AppText(
                text: 'Bio',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            text: bio,
            fontSize: 14,
            color: Colors.black87,
            //lineHeight: 1.5,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: Obx(() {
          return AppText(
            text: _viewModel.participant.value.name.isNotEmpty
                ? '${_viewModel.participant.value.name}\'s Profile'
                : 'Participant Details',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          );
        }),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryColor),
            onPressed: () {
              _refreshIndicatorKey.currentState?.show();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        color: AppColors.primaryColor,
        onRefresh: () async {
          await _viewModel.refreshParticipant(widget.userId);
        },
        child: Obx(() {
          if (_viewModel.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (_viewModel.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  AppText(
                    text: 'Failed to load participant',
                    fontSize: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    text: _viewModel.errorMessage.value,
                    fontSize: 12,
                    color: Colors.grey,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _loadParticipantData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const AppText(
                      text: 'Retry',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final participant = _viewModel.participant.value;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Image Section
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
                      child: _buildProfileImage(participant.file),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Name and Role
                Column(
                  children: [
                    AppText(
                      text: participant.name,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.lightred,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppText(
                        text: participant.role.toUpperCase(),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Bio Section
                _buildBioSection(participant.bio),

                const SizedBox(height: 24),

                // Personal Information Card
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
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 20, color: AppColors.primaryColor),
                          const SizedBox(width: 8),
                          AppText(
                            text: 'Personal Information',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Email
                      _buildInfoRow('Email Address', participant.email),
                      const SizedBox(height: 16),

                      // Organization
                      _buildInfoRow('Organization', participant.organization ?? ''),
                      const SizedBox(height: 16),

                      // Phone
                      _buildInfoRow('Phone Number', participant.phone ?? ''),
                      const SizedBox(height: 16),

                      // User ID
                      _buildInfoRow('User ID', participant.id.toString()),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Account Information Card
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
                      Row(
                        children: [
                          Icon(Icons.account_circle_outlined, size: 20, color: AppColors.primaryColor),
                          const SizedBox(width: 8),
                          AppText(
                            text: 'Account Information',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      //
                      // // Account Status
                      // _buildStatusRow('Account Status', participant.isBlocked),
                     // const SizedBox(height: 16),
                     //
                     //  // Registration Date
                     //  _buildDateRow('Registration Date', participant.createdAt),
                     //  const SizedBox(height: 16),
                     //
                     //  // Last Updated
                     //  _buildDateRow('Last Updated', participant.updatedAt),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                //
                // // Action Buttons
                // Row(
                //   children: [
                //     // Block/Unblock Button
                //     Expanded(
                //       child: ElevatedButton.icon(
                //         onPressed: () {
                //           _showBlockDialog(participant.isBlocked, participant.name);
                //         },
                //         icon: Icon(
                //           participant.isBlocked ? Icons.lock_open : Icons.block,
                //           color: Colors.white,
                //           size: 20,
                //         ),
                //         label: AppText(
                //           text: participant.isBlocked ? 'Unblock User' : 'Block User',
                //           fontSize: 16,
                //           fontWeight: FontWeight.w600,
                //           color: Colors.white,
                //         ),
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: participant.isBlocked ? Colors.green : Colors.red,
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(12),
                //           ),
                //           elevation: 0,
                //           padding: const EdgeInsets.symmetric(vertical: 16),
                //         ),
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //
                //     // QR Code Button
                //     SizedBox(
                //       width: 60,
                //       child: ElevatedButton(
                //         onPressed: () {
                //           _showQRCode(participant.name);
                //         },
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: AppColors.primaryColor,
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(12),
                //           ),
                //           elevation: 0,
                //           padding: const EdgeInsets.symmetric(vertical: 16),
                //         ),
                //         child: const Icon(Icons.qr_code, color: Colors.white, size: 24),
                //       ),
                //     ),
                //   ],
                // ),
                //
                // const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showBlockDialog(bool isCurrentlyBlocked, String userName) {
    showDialog(
      context: context,
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
                ? 'Are you sure you want to unblock $userName?'
                : 'Are you sure you want to block $userName? They will not be able to access the app.',
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
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement block/unblock functionality
                Get.snackbar(
                  isCurrentlyBlocked ? 'User Unblocked' : 'User Blocked',
                  '$userName has been ${isCurrentlyBlocked ? 'unblocked' : 'blocked'}',
                  backgroundColor: isCurrentlyBlocked ? Colors.green : Colors.red,
                  colorText: Colors.white,
                );
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

  void _showQRCode(String userName) {
    // TODO: Implement QR code generation
    Get.snackbar(
      'QR Code',
      'QR Code for $userName will be generated here',
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
    );
  }

  @override
  void dispose() {
    Get.delete<ParticipantDetailViewModel>();
    super.dispose();
  }
}