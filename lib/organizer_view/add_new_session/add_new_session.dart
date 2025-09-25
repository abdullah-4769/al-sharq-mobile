
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';

class AddNewSessionScreen extends StatefulWidget {
  const AddNewSessionScreen({super.key});

  @override
  State<AddNewSessionScreen> createState() => _AddNewSessionScreenState();
}

class _AddNewSessionScreenState extends State<AddNewSessionScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCategory = 'Select a Discussion';
  String selectedSpeaker = 'Select Speaker';
  String selectedLocation = 'Select Location';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText(
          text: 'Add New Session',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              text: 'Session Title',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: titleController,
              hintText: 'Enter session title',
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Category',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            const SizedBox(height: 8),
            _buildDropdown(selectedCategory, [
              'Select a Discussion',
              'Technology',
              'Business',
              'Innovation'
            ]),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        text: 'Start Date',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                      const SizedBox(height: 8),
                      _buildDateField('Feb 15, 2025'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        text: 'End Date',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                      const SizedBox(height: 8),
                      _buildDateField('Feb 15, 2025'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Speaker',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            const SizedBox(height: 8),
            _buildDropdown(selectedSpeaker,
                ['Select Speaker', 'Dr. Sarah Hassan', 'Prof. Omar Khalid']),

            const SizedBox(height: 20),

            const AppText(
              text: 'Location',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            const SizedBox(height: 8),
            _buildDropdown(selectedLocation,
                ['Select Location', 'Hall A', 'Hall B', 'Conference Room 1']),

            const SizedBox(height: 20),

            const AppText(
              text: 'Description',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.lightGreyColor,
                border: Border.all(color: AppColors.containerGreyColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: descriptionController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Describe your session in detail',
                  hintStyle: TextStyle(color: AppColors.darkgrey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const AppText(
              text: 'Tags',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTagChip('Innovation', AppColors.darkBlue),
                _buildTagChip('Sustainability', AppColors.lightred),
              ],
            ),

            const SizedBox(height: 40),

            CustomButton(
              text: 'Create',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Session created successfully!')),
                );
              },
              backgroundColor: AppColors.primaryColor,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        border: Border.all(color: AppColors.containerGreyColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: AppText(
                text: item,
                fontSize: 14,
                color: item.startsWith('Select') ? AppColors.darkgrey : Colors
                    .black,
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            // Handle dropdown change
          },
        ),
      ),
    );
  }

  Widget _buildDateField(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        border: Border.all(color: AppColors.containerGreyColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(
        text: date,
        fontSize: 14,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTagChip(String tag, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppText(
        text: tag,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}