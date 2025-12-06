import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';

import '../../view_model/organizer_viewmodels/import_participants_viewmodel.dart';

class ImportParticipantsScreen extends StatefulWidget {
  const ImportParticipantsScreen({Key? key}) : super(key: key);

  @override
  State<ImportParticipantsScreen> createState() => _ImportParticipantsScreenState();
}

class _ImportParticipantsScreenState extends State<ImportParticipantsScreen> {
  late ImportParticipantsViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = Get.put(ImportParticipantsViewModel());
    print('DEBUG: ImportParticipantsScreen initialized');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickCsvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        print('DEBUG: File selected: ${file.path}');
        await _viewModel.parseCsvFile(file);
      } else {
        print('DEBUG: No file selected');
      }
    } catch (e) {
      print('DEBUG: File picker error: $e');
      Get.snackbar(
        'Error',
        'Failed to pick file: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          text: 'Import Participants',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (_viewModel.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: 16),
                AppText(
                  text: 'Processing CSV file...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        if (_viewModel.participants.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Header with file info and send button
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // File info row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.insert_drive_file,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: _viewModel.csvFileName.value.isNotEmpty
                                  ? _viewModel.csvFileName.value
                                  : 'dashboard_report.csv',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            AppText(
                              text: '${_viewModel.participants.length} participants found',
                              fontSize: 12,
                              color: AppColors.darkgrey,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _pickCsvFile,
                        child: const AppText(
                          text: 'Change',
                          fontSize: 12,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Send Invitations Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _viewModel.isSending.value
                          ? null
                          : () => _viewModel.sendInvitations(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _viewModel.isSending.value
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          AppText(
                            text: 'Sending...',
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      )
                          : const AppText(
                        text: 'Send Invitations',
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // Participants list
            Expanded(
              child: _buildParticipantsList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.upload_file,
                size: 50,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const AppText(
              text: 'No CSV File Uploaded',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            const AppText(
              text: 'Upload a CSV file to import and send invitations to participants',
              fontSize: 14,
              color: AppColors.darkgrey,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _pickCsvFile,
              icon: const Icon(Icons.upload),
              label: const AppText(
                text: 'Upload CSV File',
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'CSV Format:',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  SizedBox(height: 8),
                  AppText(
                    text: 'Name, Email, Phone, Role',
                    fontSize: 11,
                    color: AppColors.darkgrey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsList() {
    final searchQuery = _searchController.text;
    final filteredParticipants = searchQuery.isEmpty
        ? _viewModel.participants
        : _viewModel.searchParticipants(searchQuery);

    if (filteredParticipants.isEmpty) {
      return const Center(
        child: AppText(
          text: 'No participants found',
          fontSize: 14,
          color: AppColors.darkgrey,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      itemCount: filteredParticipants.length,
      itemBuilder: (context, index) {
        final participant = filteredParticipants[index];
        return _buildParticipantCard(participant);
      },
    );
  }

  Widget _buildParticipantCard(participant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            child: AppText(
              text: participant.name.isNotEmpty
                  ? participant.name[0].toUpperCase()
                  : 'P',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),

          const SizedBox(width: 12),

          // Participant info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: participant.name,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                const SizedBox(height: 4),
                AppText(
                  text: participant.email,
                  fontSize: 13,
                  color: AppColors.darkgrey,
                ),
                const SizedBox(height: 2),
                AppText(
                  text: participant.phone,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),

          // Status indicator
          if (participant.invitationSent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  AppText(
                    text: 'Sent',
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            )
          else if (_viewModel.isSending.value)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}