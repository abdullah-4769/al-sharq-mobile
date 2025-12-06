import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../data/request_models/announcement_model/announcement_model.dart';
import '../../view_model/organizer_viewmodels/announcement_viewmodel.dart';
import '../add_announcement/add_announcement.dart';

class ManageAnnouncementsScreen extends StatelessWidget {
  final AnnouncementViewModel viewModel = Get.put(AnnouncementViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkgrey),
          onPressed: () => Get.back(),
        ),
        title: AppText(
          text: 'Manage Announcements',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkgrey,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (viewModel.isLoading.value && viewModel.allAnnouncements.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: viewModel.fetchAnnouncements,
          child: Column(
            children: [
              // Search Bar
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  onChanged: viewModel.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search announcements...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: AppColors.lightGrey),
                  ),
                ),
              ),

              // Stats Row
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Sent',
                        '${viewModel.totalSent}',
                        Icons.check_circle,
                        AppColors.successColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Scheduled',
                        '${viewModel.totalScheduled}',
                        Icons.schedule,
                        AppColors.warningColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Draft',
                        '${viewModel.totalDrafts}',
                        Icons.drafts,
                        AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Filter Tabs
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      SizedBox(width: 8),
                      _buildFilterChip('Sent', 'sent'),
                      SizedBox(width: 8),
                      _buildFilterChip('Scheduled', 'scheduled'),
                      SizedBox(width: 8),
                      _buildFilterChip('Draft', 'draft'),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Add New Button
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  text: 'Add New Announcement',
                  onPressed: () {
                    Get.to(() => AddAnnouncementScreen());
                  },
                  backgroundColor: AppColors.primaryColor,
                ),
              ),

              SizedBox(height: 16),

              // Announcements List
              Expanded(
                child: viewModel.filteredAnnouncements.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.announcement_outlined, size: 64, color: AppColors.lightGrey),
                      SizedBox(height: 16),
                      AppText(
                        text: 'No announcements found',
                        fontSize: 16,
                        color: AppColors.lightGrey,
                      ),
                    ],
                  ),
                )
                    : Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    itemCount: viewModel.filteredAnnouncements.length,
                    itemBuilder: (context, index) {
                      return _buildAnnouncementCard(
                        viewModel.filteredAnnouncements[index],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Obx(() {
      final isSelected = viewModel.selectedFilter.value == value;
      return GestureDetector(
        onTap: () => viewModel.setFilter(value),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            ),
          ),
          child: AppText(
            text: label,
            fontSize: 14,
            color: isSelected ? AppColors.white : AppColors.darkgrey,
          ),
        ),
      );
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(height: 8),
          AppText(
            text: value,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkgrey,
          ),
          AppText(
            text: title,
            fontSize: 10,
            color: AppColors.lightGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    final statusColor = announcement.isSent
        ? AppColors.successColor
        : announcement.scheduledAt != null
        ? AppColors.warningColor
        : AppColors.primaryColor;

    final statusText = announcement.isSent
        ? 'Sent'
        : announcement.scheduledAt != null
        ? 'Scheduled'
        : 'Draft';

    final statusIcon = announcement.isSent
        ? Icons.check_circle
        : announcement.scheduledAt != null
        ? Icons.schedule
        : Icons.drafts;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and status
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: announcement.title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkgrey,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    SizedBox(width: 4),
                    AppText(
                      text: statusText,
                      fontSize: 10,
                      color: statusColor,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Message
          AppText(
            text: announcement.message,
            fontSize: 14,
            color: AppColors.lightGrey,
            textAlign: TextAlign.left,
            maxLines: 3,
          ),

          SizedBox(height: 12),

          // Date and Audience
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppColors.lightGrey),
              SizedBox(width: 4),
              Expanded(
                child: AppText(
                  text: announcement.formattedDate,
                  fontSize: 12,
                  color: AppColors.lightGrey,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.people, size: 14, color: AppColors.lightGrey),
              SizedBox(width: 4),
              Expanded(
                child: AppText(
                  text: announcement.audienceDisplay,
                  fontSize: 12,
                  color: AppColors.lightGrey,
                ),
              ),
            ],
          ),

          // Show scheduled time if scheduled
          if (announcement.scheduledAt != null && !announcement.isSent) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warningColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_alarm, size: 14, color: AppColors.warningColor),
                  SizedBox(width: 6),
                  Expanded(
                    child: AppText(
                      text: 'Sends ${_formatScheduledTime(announcement.scheduledAt!)}',
                      fontSize: 12,
                      color: AppColors.warningColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: announcement.isSent
                      ? null
                      : () {
                    Get.to(() => AddAnnouncementScreen(
                      announcement: announcement,
                    ));
                  },
                  text: "Edit",
                  backgroundColor: announcement.isSent
                      ? AppColors.lightGrey
                      : AppColors.primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  backgroundColor: AppColors.lightGreyColor,
                  borderColor: AppColors.errorColor,
                  textColor: AppColors.errorColor,
                  text: "Delete",
                  onPressed: () => _deleteAnnouncement(announcement),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatScheduledTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    // If in the past
    if (difference.isNegative) {
      return 'overdue';
    }

    // If less than 1 hour
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'in $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    }

    // If less than 24 hours
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      if (minutes > 0) {
        return 'in $hours ${hours == 1 ? 'hour' : 'hours'} and $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      }
      return 'in $hours ${hours == 1 ? 'hour' : 'hours'}';
    }

    // If less than 7 days
    if (difference.inDays < 7) {
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      if (hours > 0) {
        return 'in $days ${days == 1 ? 'day' : 'days'} and $hours ${hours == 1 ? 'hour' : 'hours'}';
      }
      return 'in $days ${days == 1 ? 'day' : 'days'}';
    }

    // For dates far in the future, show the actual date
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    // Check if it's today
    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      return 'today at $hour:$minute';
    }

    // Check if it's tomorrow
    final tomorrow = now.add(Duration(days: 1));
    if (dateTime.year == tomorrow.year && dateTime.month == tomorrow.month && dateTime.day == tomorrow.day) {
      return 'tomorrow at $hour:$minute';
    }

    // Show full date
    return 'on $month $day at $hour:$minute';
  }

  void _deleteAnnouncement(AnnouncementModel announcement) {
    Get.dialog(
      AlertDialog(
        title: AppText(
          text: 'Delete Announcement',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        content: AppText(
          text: 'Are you sure you want to delete this announcement?',
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: AppText(text: 'Cancel', color: AppColors.lightGrey),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              if (announcement.id != null) {
                viewModel.deleteAnnouncement(announcement.id!);
              }
            },
            child: AppText(text: 'Delete', color: AppColors.errorColor),
          ),
        ],
      ),
    );
  }
}