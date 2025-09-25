import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';



class AddNewVenueScreen extends StatefulWidget {
  @override
  _AddNewVenueScreenState createState() => _AddNewVenueScreenState();
}

class _AddNewVenueScreenState extends State<AddNewVenueScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedEvent = 'Select an event';
  bool isVisibleToParticipants = false;
  List<File> selectedImages = [];

  final List<String> events = [
    'Select an event',
    'Tech Conference 2024',
    'Business Summit',
    'Innovation Workshop',
    'Startup Meetup',
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
          text: 'Add New Venue',
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
              hintText: 'Enter a clear title',
            ),

            SizedBox(height: 24),

            // Assign Event Dropdown
            AppText(
              text: 'Assign Event*',
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
                  value: selectedEvent,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.darkgrey),
                  items: events.map((String event) {
                    return DropdownMenuItem<String>(
                      value: event,
                      child: AppText(
                        text: event,
                        fontSize: 16,
                        color: event == 'Select an event' ? AppColors.lightGrey : AppColors.darkgrey,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedEvent = newValue!;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 24),

            // Location Field
            AppText(
              text: 'Location*',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
            SizedBox(height: 8),
            CustomTextField(
              controller: locationController,
              hintText: 'New York, USA',
            ),

            SizedBox(height: 24),

            // Description Field
            AppText(
              text: 'Description',
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
                controller: descriptionController,
                maxLines: 4,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkgrey,
                ),
                decoration: InputDecoration(
                  hintText: 'Describe your topic in detail',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: AppColors.lightGrey,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 24),

            // Upload Media Section
            AppText(
              text: 'Upload Media',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: selectedImages.isEmpty
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.lightGrey),
                    SizedBox(height: 8),
                    AppText(
                      text: 'Upload Media',
                      fontSize: 14,
                      color: AppColors.lightGrey,
                    ),
                    AppText(
                      text: 'Drag and drop your files here or click to browse',
                      fontSize: 12,
                      color: AppColors.lightGrey,
                    ),
                  ],
                )
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(8),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          selectedImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 24),

            // Visibility Toggle
            AppText(
              text: 'Visibility*',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: 'Map Visible to Participants',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
                Switch(
                  value: isVisibleToParticipants,
                  onChanged: (value) {
                    setState(() {
                      isVisibleToParticipants = value;
                    });
                  },
                  activeColor: AppColors.primaryColor,
                ),
              ],
            ),

            SizedBox(height: 40),

            // Add Button
            CustomButton(
              text: 'Add',
              onPressed: _addVenue,
              backgroundColor: AppColors.primaryColor,
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null) {
      setState(() {
        selectedImages = images.map((image) => File(image.path)).toList();
      });
    }
  }

  void _addVenue() {
    if (titleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a title',
          backgroundColor: AppColors.errorColor.withOpacity(0.1),
          colorText: AppColors.errorColor);
      return;
    }

    if (selectedEvent == 'Select an event') {
      Get.snackbar('Error', 'Please select an event',
          backgroundColor: AppColors.errorColor.withOpacity(0.1),
          colorText: AppColors.errorColor);
      return;
    }

    if (locationController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a location',
          backgroundColor: AppColors.errorColor.withOpacity(0.1),
          colorText: AppColors.errorColor);
      return;
    }

    // Show success message
    Get.snackbar('Success', 'Venue added successfully!',
        backgroundColor: AppColors.successColor.withOpacity(0.1),
        colorText: AppColors.successColor);

    // Navigate back
    Get.back();
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}