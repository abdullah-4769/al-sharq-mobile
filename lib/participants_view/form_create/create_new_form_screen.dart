import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

import '../../view_model/participant_viewmodel/forms/participant_form_create_viewmodel.dart';

class CreateNewForumScreen extends StatefulWidget {
  final int sessionId;
  final int userId;
  final String selectedTag;

  const CreateNewForumScreen({
    super.key,
    required this.sessionId,
    required this.userId,
    required this.selectedTag,
  });

  @override
  State<CreateNewForumScreen> createState() => _CreateNewForumScreenState();
}

class _CreateNewForumScreenState extends State<CreateNewForumScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final ParticipantFormCreateViewModel viewModel = Get.put(ParticipantFormCreateViewModel());

  @override
  void initState() {
    super.initState();
    print('=== CreateNewForumScreen initialized with sessionId: ${widget.sessionId}, userId: ${widget.userId}, tag: ${widget.selectedTag} ===');
  }

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
          text: 'Create New Discussion',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Creating your discussion...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
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

              // Selected Tag
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightPurpleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightPurpleColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      text: 'Selected Topic',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkPurpleColor,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      text: widget.selectedTag,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Topic Title
              const AppText(
                text: 'Discussion Title *',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: titleController,
                hintText: 'Enter discussion title',
              ),
              const SizedBox(height: 24),

              // Description
              const AppText(
                text: 'Discussion Content *',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Describe your discussion in detail...',
                    hintStyle: TextStyle(color: AppColors.darkgrey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (viewModel.errorMessage.value.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: AppText(
                    text: viewModel.errorMessage.value,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),

              const SizedBox(height: 40),

              // Create Button
              CustomButton(
                text: 'Create Discussion',
                onPressed: _createForum,
                backgroundColor: AppColors.primaryColor,
                height: 48,
              ),
            ],
          ),
        );
      }),
    );
  }

  void _createForum() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a discussion title',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (contentController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter discussion content',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    print('=== Creating forum with sessionId: ${widget.sessionId}, userId: ${widget.userId} ===');

    final success = await viewModel.createForum(
      sessionId: widget.sessionId,
      userId: widget.userId,
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      tag: widget.selectedTag,
    );

    if (success) {
      // Show success message
      Get.snackbar(
        'Success',
        'Discussion created successfully! Waiting for organizer approval.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate back after a short delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Get.back();
        }
      });
    } else {
      // Error is already shown by the viewModel
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}