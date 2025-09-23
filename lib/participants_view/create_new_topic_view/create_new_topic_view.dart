import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

class CreateNewTopicScreen extends StatefulWidget {
  const CreateNewTopicScreen({super.key});

  @override
  State<CreateNewTopicScreen> createState() => _CreateNewTopicScreenState();
}

class _CreateNewTopicScreenState extends State<CreateNewTopicScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  String selectedCategory = 'Select a Discussion';
  String selectedGroup = 'Select a Social Transformation';

  final List<String> categories = [
    'Select a Discussion',
    'Technology & Innovation',
    'Business & Strategy',
    'Social Impact',
    'Environmental Issues',
    'Economic Development',
  ];

  final List<String> groups = [
    'Select a Social Transformation',
    'Group by Digital Transformation',
    'Group by Regional Development',
    'Group by Sustainability',
    'Group by Innovation',
  ];

  final List<String> tags = [];

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
          text: 'Create New Topic',
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
              text: 'Start a new discussion',
              fontSize: 14,
              color: AppColors.darkgrey,
            ),
            const SizedBox(height: 24),

            // Topic Title
            const AppText(
              text: 'Topic Title *',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: titleController,
              hintText: 'Enter topic title',
            ),
            const SizedBox(height: 24),

            // Category Selection
            const AppText(
              text: 'Category *',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: AppText(
                        text: value,
                        fontSize: 14,
                        color: value == 'Select a Discussion' ? AppColors.darkgrey : Colors.black,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Group Selection
            const AppText(
              text: 'Group by Social Transformation',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedGroup,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: groups.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: AppText(
                        text: value,
                        fontSize: 14,
                        color: value == 'Select a Social Transformation' ? AppColors.darkgrey : Colors.black,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGroup = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            const AppText(
              text: 'Description',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: descriptionController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Describe your topic in detail',
                  hintStyle: TextStyle(color: AppColors.darkgrey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tags
            const AppText(
              text: 'Tags',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: tagsController,
                    hintText: 'Add tags',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (tagsController.text.trim().isNotEmpty) {
                      setState(() {
                        tags.add(tagsController.text.trim());
                        tagsController.clear();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const AppText(
                      text: 'Add',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Display Tags
            if (tags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) => _buildTagChip(tag)).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Pre-selected Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPreSelectedTag('Innovation', Colors.blue),
                _buildPreSelectedTag('Sustainability', Colors.pink),
              ],
            ),
            const SizedBox(height: 40),

            // Create Button
            CustomButton(
              text: 'Create',
              onPressed: () {
                // Validate and create topic
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a topic title')),
                  );
                  return;
                }
                if (selectedCategory == 'Select a Discussion') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a category')),
                  );
                  return;
                }
                // Create topic logic here
                Navigator.pop(context);
              },
              backgroundColor: AppColors.primaryColor,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: tag,
            fontSize: 12,
            color: Colors.black,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                tags.remove(tag);
              });
            },
            child: const Icon(Icons.close, size: 14, color: AppColors.darkgrey),
          ),
        ],
      ),
    );
  }

  Widget _buildPreSelectedTag(String tag, Color color) {
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
    tagsController.dispose();
    super.dispose();
  }}