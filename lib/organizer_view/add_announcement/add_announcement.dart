import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';



class AddAnnouncementScreen extends StatefulWidget {
  final AnnouncementModel? announcement;

  const AddAnnouncementScreen({super.key, this.announcement});

  @override
  _AddAnnouncementScreenState createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  String selectedAudience = 'All Participants';

  final List<String> audienceOptions = [
    'All Participants',
    'Speakers',
    'Sponsors',
    'Organizers',
    'VIP Guests',
    'Students',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.announcement != null) {
      titleController.text = widget.announcement!.title;
      messageController.text = widget.announcement!.message;
      selectedAudience = widget.announcement!.audience;
    }
  }

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
          text: widget.announcement != null ? 'Edit Announcement' : 'Announcements',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkgrey,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            AppText(
              text: 'Title*',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
            SizedBox(height: 8),
            CustomTextField(
              controller: titleController,
              hintText: 'Keynote Reminder',
            ),

            SizedBox(height: 24),

            // Message Field
            AppText(
              text: 'Message',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: messageController,
                maxLines: 4,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkgrey,
                ),
                decoration: InputDecoration(
                  hintText: "Don't miss today's keynote with Dr. Ahmed at 10:00 AM in Hall A. Ahmed Hassan will present the latest insights on digital transformation.",
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: AppColors.lightGrey,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 24),

            // Audience Selection
            AppText(
              text: 'Audience Selection*',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedAudience,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.darkgrey),
                  items: audienceOptions.map((String audience) {
                    return DropdownMenuItem<String>(
                      value: audience,
                      child: AppText(
                        text: audience,
                        fontSize: 16,
                        color: AppColors.darkgrey,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedAudience = newValue!;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 40),

            // Add/Update Button
            CustomButton(
              text: widget.announcement != null ? 'Update' : 'Add',
              onPressed: _saveAnnouncement,
              backgroundColor: AppColors.primaryColor,
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _saveAnnouncement() {
    if (titleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a title',
          backgroundColor: AppColors.errorColor.withOpacity(0.1),
          colorText: AppColors.errorColor);
      return;
    }

    if (messageController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a message',
          backgroundColor: AppColors.errorColor.withOpacity(0.1),
          colorText: AppColors.errorColor);
      return;
    }

    // Show success message
    String successMessage = widget.announcement != null
        ? 'Announcement updated successfully!'
        : 'Announcement added successfully!';

    Get.snackbar('Success', successMessage,
        backgroundColor: AppColors.successColor.withOpacity(0.1),
        colorText: AppColors.successColor);

    // Navigate back
    Get.back();
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }
}

// AnnouncementModel class (if not already defined)
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