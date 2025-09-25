import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../add_announcement/add_announcement.dart';



class ManageAnnouncementsScreen extends StatefulWidget {
  @override
  _ManageAnnouncementsScreenState createState() => _ManageAnnouncementsScreenState();
}

class _ManageAnnouncementsScreenState extends State<ManageAnnouncementsScreen> {
  final List<AnnouncementModel> announcements = [
    AnnouncementModel(
      id: '1',
      title: 'Keynote Session Reminder',
      message: "Don't miss today's keynote at 10:00 AM in Hall A. Ahmed Hassan will present the latest insights on digital transformation.",
      date: 'Feb 15, 9:30 AM',
      audience: 'All Participants',
      isScheduled: false,
    ),
    AnnouncementModel(
      id: '2',
      title: 'Keynote Session Reminder',
      message: "Don't miss today's keynote at 10:00 AM in Hall A. Dr. Ahmed Hassan will present the latest insights on digital transformation.",
      date: 'Feb 15, 9:30 AM',
      audience: 'All Participants',
      isScheduled: true,
    ),
    AnnouncementModel(
      id: '3',
      title: 'Keynote Session Reminder',
      message: "Don't miss today's keynote at 10:00 AM in Hall A. Dr. Ahmed Hassan will present the latest insights on digital transformation.",
      date: 'Feb 15, 9:30 AM',
      audience: 'All Participants',
      isScheduled: true,
    ),
    AnnouncementModel(
      id: '4',
      title: 'Keynote Session Reminder',
      message: "Don't miss today's keynote at 10:00 AM in Hall A. Dr. Ahmed Hassan will present the latest insights on digital transformation.",
      date: 'Feb 15, 9:30 AM',
      audience: 'All Participants',
      isScheduled: true,
    ),
  ];

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
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.tune, color: AppColors.primaryColor, size: 20),
          ),
        ],
      ),
      body: Column(
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
                  child: _buildStatCard('Total Sent', '24', Icons.send, AppColors.chartColor3),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Scheduled', '5', Icons.schedule, AppColors.warningColor),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Drafts', '12', Icons.drafts, AppColors.lightGrey),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
              text: 'Add New Announcement',
              onPressed: () => _showAddAnnouncementDialog(),
              backgroundColor: AppColors.primaryColor,
            ),
          ),

          SizedBox(height: 16),

          // Announcements List
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  return _buildAnnouncementCard(announcements[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
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
                  color: announcement.isScheduled
                      ? AppColors.warningColor.withOpacity(0.1)
                      : AppColors.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      announcement.isScheduled ? Icons.schedule : Icons.check_circle,
                      size: 12,
                      color: announcement.isScheduled ? AppColors.warningColor : AppColors.successColor,
                    ),
                    SizedBox(width: 4),
                    AppText(
                      text: announcement.isScheduled ? 'Scheduled' : 'Sent',
                      fontSize: 10,
                      color: announcement.isScheduled ? AppColors.warningColor : AppColors.successColor,
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
          ),

          SizedBox(height: 12),

          // Date and Audience
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppColors.lightGrey),
              SizedBox(width: 4),
              AppText(
                text: announcement.date,
                fontSize: 12,
                color: AppColors.lightGrey,
              ),
              SizedBox(width: 16),
              Icon(Icons.people, size: 14, color: AppColors.lightGrey),
              SizedBox(width: 4),
              AppText(
                text: announcement.audience,
                fontSize: 12,
                color: AppColors.lightGrey,
              ),
            ],
          ),

          SizedBox(height: 16),
         /* OutlinedButton(
            onPressed: () => _viewDetails(announcement),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: AppText(
              text: 'View Details',
              fontSize: 14,
              color: AppColors.primaryColor,
            ),
          ),*/
          CustomButton(
            borderColor: AppColors.containerGreyColor, // optional

            backgroundColor: AppColors.lightGreyColor,
            textColor: AppColors.blackColor,
            text: "View Details", onPressed: () => _viewDetails(announcement)


            ,),
          SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: CustomButton(
                  onPressed: () => _editAnnouncement(announcement),
                  text: "Edit",
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 5,
                child: CustomButton(
                  backgroundColor: AppColors.lightGreyColor,
                  borderColor: AppColors.primaryColor,
                  textColor: AppColors.blackColor,
                  text: "Delete", onPressed: () => _deleteAnnouncement(announcement),
                ),
              )

            ],
          ),
        ],
      ),
    );
  }

  void _showAddAnnouncementDialog() {
    Get.to(() => AddAnnouncementScreen());
  }

  void _viewDetails(AnnouncementModel announcement) {
    Get.dialog(
      AlertDialog(
        title: AppText(
          text: 'Announcement Details',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'Title: ${announcement.title}',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 8),
            AppText(
              text: 'Message: ${announcement.message}',
              fontSize: 14,
            ),
            SizedBox(height: 8),
            AppText(
              text: 'Date: ${announcement.date}',
              fontSize: 14,
            ),
            SizedBox(height: 8),
            AppText(
              text: 'Audience: ${announcement.audience}',
              fontSize: 14,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: AppText(text: 'Close', color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  void _editAnnouncement(AnnouncementModel announcement) {
    Get.to(() => AddAnnouncementScreen());
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
              setState(() {
                announcements.remove(announcement);
              });
              Get.back();
              Get.snackbar('Success', 'Announcement deleted successfully!',
                  backgroundColor: AppColors.successColor.withOpacity(0.1),
                  colorText: AppColors.successColor);
            },
            child: AppText(text: 'Delete', color: AppColors.errorColor),
          ),
        ],
      ),
    );
  }
}

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String date;
  final String audience;
  final bool isScheduled;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.audience,
    required this.isScheduled,
  });
}

