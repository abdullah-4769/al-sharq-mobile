import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/data/response_models/organizer_response_models/organize_see_participants_short_info_model.dart';
import 'package:al_sharq_conference/view_model/organizer_viewmodels/organize_see_participants_short_info_viewmodel.dart';
import 'package:al_sharq_conference/view_model/organizer_viewmodels/organizer_block_user_viewmodel.dart';
import 'package:al_sharq_conference/view_model/organizer_viewmodels/organizer_delete_user_viewmodel.dart';

import '../../data/response_models/organizer_response_models/organizer_dashboard_small_detail_show_model.dart';
import '../organizer_dashboard/participant_detail_screen.dart';
import '../organizer_dashboard/view_all_participants.dart';

class ManageParticipantsScreen extends StatefulWidget {
  const ManageParticipantsScreen({super.key});

  @override
  State<ManageParticipantsScreen> createState() => _ManageParticipantsScreenState();
}

class _ManageParticipantsScreenState extends State<ManageParticipantsScreen> {
  final TextEditingController searchController = TextEditingController();
  final OrganizeSeeParticipantsShortInfoViewModel _participantsViewModel =
  Get.put(OrganizeSeeParticipantsShortInfoViewModel());

  // Create separate instances for each user to avoid shared loading state
  final Map<int, OrganizerBlockUserViewModel> _blockViewModels = {};
  final Map<int, OrganizerDeleteUserViewModel> _deleteViewModels = {};

  OrganizerBlockUserViewModel _getBlockViewModel(int userId) {
    if (!_blockViewModels.containsKey(userId)) {
      _blockViewModels[userId] = OrganizerBlockUserViewModel();
    }
    return _blockViewModels[userId]!;
  }

  OrganizerDeleteUserViewModel _getDeleteViewModel(int userId) {
    if (!_deleteViewModels.containsKey(userId)) {
      _deleteViewModels[userId] = OrganizerDeleteUserViewModel();
    }
    return _deleteViewModels[userId]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText(
          text: 'Manage Participants',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Obx(() {
        if (_participantsViewModel.isLoading.value && _participantsViewModel.participantsData.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 16),
                AppText(
                  text: 'Loading participants...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        if (_participantsViewModel.error.isNotEmpty && _participantsViewModel.participantsData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: _participantsViewModel.error.value,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _participantsViewModel.fetchParticipantsData,
                  child: const AppText(text: 'Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Search and Filter
            Container(
              color: AppColors.whiteColor,
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      hintText: 'Search',
                      controller: searchController,
                      suffixIcon: Icons.search,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Icon(Icons.tune, color: AppColors.primaryColor, size: 24.w),
                ],
              ),
            ),

            // Stats Bar - Using API data
            Container(
              color: AppColors.whiteColor,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildStatChip('Total', _participantsViewModel.formattedTotalParticipants, Colors.blue, false),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildStatChip('Bookmarks', _participantsViewModel.formattedTotalBookmarks, Colors.green, false),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildStatChip('Sessions', _participantsViewModel.formattedTotalSessionRegistrations, Colors.red, false),
                  ),
                ],
              ),
            ),
            //
            // // Networking Requests Section
            // Container(
            //   margin: EdgeInsets.symmetric(horizontal: 16.w),
            //   padding: EdgeInsets.all(16.w),
            //   decoration: BoxDecoration(
            //     color: AppColors.primaryColor,
            //     borderRadius: BorderRadius.circular(12.r),
            //   ),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             AppText(
            //               text: 'Networking Requests',
            //               fontSize: 16.sp,
            //               fontWeight: FontWeight.w600,
            //               color: Colors.white,
            //             ),
            //             AppText(
            //               text: 'Manage All Connection Requests',
            //               fontSize: 12.sp,
            //               color: Colors.white,
            //             ),
            //           ],
            //         ),
            //       ),
            //       Icon(Icons.arrow_forward, color: Colors.white, size: 20.w),
            //     ],
            //   ),
            // ),

            SizedBox(height: 16.h),

            // Participants Count
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: '${_participantsViewModel.users.length} Participants Showing',
                    fontSize: 14.sp,
                    color: AppColors.darkgrey,
                  ),
                  // In ManageParticipantsScreen, update the View All button
                  GestureDetector(
                    onTap: () {
                      Get.to(() => ViewAllParticipantsScreen());
                      print("Button tap to view all");
                    },
                    child: AppText(
                      text: 'View All',
                      fontSize: 14.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Participants List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _participantsViewModel.users.length,
                itemBuilder: (context, index) {
                  final user = _participantsViewModel.users[index];
                  return _buildParticipantCard(user);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatChip(String label, String count, Color color, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? color : AppColors.mediumGreyColor,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: label,
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? color : AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: AppText(
              text: count,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(OrganizeSeeParticipantsShortInfoUser user) {
    final blockViewModel = _getBlockViewModel(user.id);
    final deleteViewModel = _getDeleteViewModel(user.id);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image - Now clickable
              GestureDetector(
                onTap: () {
                  _navigateToParticipantDetails(user);
                },
                child: Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryColor, width: 2.w),
                  ),
                  child: ClipOval(
                    child: user.file != null && user.file!.isNotEmpty
                        ? Image.network(
                      user.file!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(user.name);
                      },
                    )
                        : _buildDefaultAvatar(user.name),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _navigateToParticipantDetails(user);
                      },
                      child: AppText(
                        text: user.name,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    if (user.organization != null && user.organization!.isNotEmpty)
                      AppText(
                        text: user.organization!,
                        fontSize: 13.sp,
                        color: AppColors.darkgrey,
                      ),
                    AppText(
                      text: user.email,
                      fontSize: 13.sp,
                      color: AppColors.darkgrey,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: user.isBlocked ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: AppText(
                  text: user.isBlocked ? 'Blocked' : 'Active',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: user.isBlocked ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (user.organization != null && user.organization!.isNotEmpty)
            AppText(
              text: '${user.name} is a ${user.organization} with email ${user.email}.',
              fontSize: 12.sp,
              color: AppColors.darkgrey,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          SizedBox(height: 16.h),

          // Fixed Button Row - No Text Wrapping
          Row(
            children: [
              // View Details Button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 36.h,
                  child: OutlinedButton(
                    onPressed: () {
                      _navigateToParticipantDetails(user);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AppText(
                        text: 'View Details',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Delete and Block Buttons
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // Delete Button
                    Expanded(
                      child: SizedBox(
                        height: 36.h,
                        child: Obx(() {
                          return OutlinedButton(
                            onPressed: deleteViewModel.isLoading.value
                                ? null
                                : () => _showDeleteConfirmation(user.id, user.name, deleteViewModel),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                            ),
                            child: deleteViewModel.isLoading.value
                                ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: CircularProgressIndicator(strokeWidth: 2.w),
                            )
                                : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: AppText(
                                text: 'Delete',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Block/Unblock Button
                    Expanded(
                      child: SizedBox(
                        height: 36.h,
                        child: Obx(() {
                          return OutlinedButton(
                            onPressed: blockViewModel.isLoading.value
                                ? null
                                : () => _showBlockConfirmation(user.id, user.name, user.isBlocked, blockViewModel),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: user.isBlocked ? Colors.green : Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                            ),
                            child: blockViewModel.isLoading.value
                                ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: CircularProgressIndicator(strokeWidth: 2.w),
                            )
                                : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: AppText(
                                text: user.isBlocked ? 'Unblock' : 'Block',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: user.isBlocked ? Colors.green : Colors.red,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  void _navigateToParticipantDetails(OrganizeSeeParticipantsShortInfoUser user) {
    // Convert OrganizeSeeParticipantsShortInfoUser to OrganizerDashboardSmallDetailShowRecentUser
    final detailUser = OrganizerDashboardSmallDetailShowRecentUser(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      file: user.file,
      role: user.role,
      organization: user.organization,
      photo: user.photo,
      isBlocked: user.isBlocked,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );

    Get.to(() => ParticipantDetailScreen(user: detailUser));
  }
  Widget _buildDefaultAvatar(String name) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.brown,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppText(
          text: name.isNotEmpty ? name[0] : 'U',
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int userId, String userName, OrganizerDeleteUserViewModel deleteViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: AppText(
            text: 'Delete Participant',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          content: AppText(
            text: 'Are you sure you want to delete $userName? This action cannot be undone.',
            fontSize: 14.sp,
            color: AppColors.darkgrey,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: AppText(
                text: 'Cancel',
                fontSize: 14.sp,
                color: AppColors.darkgrey,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await deleteViewModel.deleteUser(userId);
                if (success) {
                  _participantsViewModel.fetchParticipantsData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: AppText(
                text: 'Delete',
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBlockConfirmation(int userId, String userName, bool isCurrentlyBlocked, OrganizerBlockUserViewModel blockViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: AppText(
            text: isCurrentlyBlocked ? 'Unblock Participant' : 'Block Participant',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          content: AppText(
            text: isCurrentlyBlocked
                ? 'Are you sure you want to unblock $userName?'
                : 'Are you sure you want to block $userName? They will not be able to access the app.',
            fontSize: 14.sp,
            color: AppColors.darkgrey,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: AppText(
                text: 'Cancel',
                fontSize: 14.sp,
                color: AppColors.darkgrey,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await blockViewModel.blockUser(userId, !isCurrentlyBlocked);
                if (success) {
                  _participantsViewModel.fetchParticipantsData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentlyBlocked ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              child: AppText(
                text: isCurrentlyBlocked ? 'Unblock' : 'Block',
                fontSize: 14.sp,
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
    searchController.dispose();
    // Dispose all viewmodels
    _blockViewModels.forEach((key, value) => value.dispose());
    _deleteViewModels.forEach((key, value) => value.dispose());
    super.dispose();
  }
}