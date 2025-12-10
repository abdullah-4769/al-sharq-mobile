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
import 'package:al_sharq_conference/organizer_view/organizer_dashboard/participant_detail_screen.dart';

import '../../data/response_models/organizer_response_models/organizer_dashboard_small_detail_show_model.dart';

class ViewAllParticipantsScreen extends StatefulWidget {
  const ViewAllParticipantsScreen({super.key});

  @override
  State<ViewAllParticipantsScreen> createState() => _ViewAllParticipantsScreenState();
}

class _ViewAllParticipantsScreenState extends State<ViewAllParticipantsScreen> {
  final TextEditingController searchController = TextEditingController();
  final OrganizeSeeParticipantsShortInfoViewModel _participantsViewModel =
  Get.put(OrganizeSeeParticipantsShortInfoViewModel());

  // Create separate instances for each user to avoid shared loading state
  final Map<int, OrganizerBlockUserViewModel> _blockViewModels = {};
  final Map<int, OrganizerDeleteUserViewModel> _deleteViewModels = {};

  // Filter states
  final RxString _selectedFilter = 'All'.obs;
  final List<String> _filters = ['All', 'Active', 'Blocked'];

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

  // Get filtered and searched participants
  List<OrganizeSeeParticipantsShortInfoUser> get _filteredParticipants {
    var participants = _participantsViewModel.users;

    // Apply status filter
    if (_selectedFilter.value == 'Active') {
      participants = participants.where((user) => !user.isBlocked).toList();
    } else if (_selectedFilter.value == 'Blocked') {
      participants = participants.where((user) => user.isBlocked).toList();
    }

    // Apply search filter
    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      participants = participants.where((user) =>
      user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.organization?.toLowerCase().contains(query) ?? false) ||
          (user.phone?.toLowerCase().contains(query) ?? false)).toList();
    }

    return participants;
  }

  @override
  void initState() {
    super.initState();
    // Ensure we have fresh data
    _participantsViewModel.fetchParticipantsData();

    // Add listener for search
    searchController.addListener(() {
      setState(() {}); // Rebuild when search text changes
    });
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
          text: 'All Participants',
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
            // Search Bar
            Container(
              color: AppColors.whiteColor,
              padding: EdgeInsets.all(16.w),
              child: CustomTextField(
                hintText: 'Search by name, email, organization...',
                controller: searchController,
                suffixIcon: Icons.search,
              ),
            ),

            // Filter Chips
            Container(
              color: AppColors.whiteColor,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  AppText(
                    text: 'Filter:',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkgrey,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => Row(
                      children: _filters.map((filter) {
                        final isSelected = _selectedFilter.value == filter;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _selectedFilter.value = filter;
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 8.w),
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryColor : AppColors.mediumGreyColor,
                                ),
                              ),
                              child: Center(
                                child: AppText(
                                  text: filter,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.darkgrey,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )),
                  ),
                ],
              ),
            ),

            // Participants Count
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: '${_filteredParticipants.length} Participants',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkgrey,
                  ),
                  if (searchController.text.isNotEmpty || _selectedFilter.value != 'All')
                    GestureDetector(
                      onTap: () {
                        searchController.clear();
                        _selectedFilter.value = 'All';
                      },
                      child: AppText(
                        text: 'Clear Filters',
                        fontSize: 14.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                ],
              ),
            ),

            // Participants List
            Expanded(
              child: _filteredParticipants.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: _filteredParticipants.length,
                itemBuilder: (context, index) {
                  final user = _filteredParticipants[index];
                  return _buildParticipantCard(user);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64.w,
            color: AppColors.mediumGreyColor,
          ),
          SizedBox(height: 16.h),
          AppText(
            text: searchController.text.isNotEmpty
                ? 'No participants found for "${searchController.text}"'
                : 'No participants available',
            fontSize: 16.sp,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
          if (searchController.text.isNotEmpty || _selectedFilter.value != 'All')
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ElevatedButton(
                onPressed: () {
                  searchController.clear();
                  _selectedFilter.value = 'All';
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: AppText(
                  text: 'Clear Filters',
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
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
      margin: EdgeInsets.only(bottom: 12.h),
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
          // Header Row with Profile and Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              GestureDetector(
                onTap: () => _navigateToParticipantDetails(user),
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
                      onTap: () => _navigateToParticipantDetails(user),
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
                    if (user.phone != null && user.phone!.isNotEmpty)
                      AppText(
                        text: user.phone!,
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

          // User Description
          if (user.organization != null && user.organization!.isNotEmpty)
            AppText(
              text: '${user.name} from ${user.organization}',
              fontSize: 12.sp,
              color: AppColors.darkgrey,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          SizedBox(height: 16.h),

          // Action Buttons
          Row(
            children: [
              // View Details Button
              Expanded(
                child: SizedBox(
                  height: 36.h,
                  child: OutlinedButton(
                    onPressed: () => _navigateToParticipantDetails(user),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: AppText(
                      text: 'View Details',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),

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
                      ),
                      child: deleteViewModel.isLoading.value
                          ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(strokeWidth: 2.w),
                      )
                          : AppText(
                        text: 'Delete',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
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
                      ),
                      child: blockViewModel.isLoading.value
                          ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(strokeWidth: 2.w),
                      )
                          : AppText(
                        text: user.isBlocked ? 'Unblock' : 'Block',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: user.isBlocked ? Colors.green : Colors.red,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.brown,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppText(
          text: name.isNotEmpty ? name[0].toUpperCase() : 'U',
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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