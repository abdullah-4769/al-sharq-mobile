import 'dart:io';
import 'package:csv/csv.dart';
import 'package:get/get.dart';

import '../../data/request_models/organizer/csv_participant.dart';
import '../../repository/organizer_repo/import_participants_repository.dart';


class ImportParticipantsViewModel extends GetxController {
  final ImportParticipantsRepository _repository = ImportParticipantsRepository();

  final RxList<CsvParticipant> participants = <CsvParticipant>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxString error = ''.obs;
  final RxString csvFileName = ''.obs;
  final RxInt successCount = 0.obs;
  final RxInt failureCount = 0.obs;

  // Parse CSV file and extract participant data
  Future<void> parseCsvFile(File file) async {
    try {
      isLoading.value = true;
      error.value = '';
      participants.clear();

      // Read file content
      final fileContent = await file.readAsString();

      // Parse CSV
      List<List<dynamic>> csvData = const CsvToListConverter().convert(fileContent);

      // Skip header row and parse data
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i].map((e) => e.toString()).toList();

        if (row.isNotEmpty && row.length >= 2) {
          final participant = CsvParticipant.fromCsvRow(row);

          // Validate email
          if (participant.email.isNotEmpty && _isValidEmail(participant.email)) {
            participants.add(participant);
          }
        }
      }

      if (participants.isEmpty) {
        error.value = 'No valid participants found in CSV file';
      } else {
        csvFileName.value = file.path.split('/').last;
      }
    } catch (e) {
      error.value = 'Error parsing CSV file: $e';
      print('CSV parsing error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Send invitations to all participants
  Future<void> sendInvitations() async {
    try {
      isSending.value = true;
      successCount.value = 0;
      failureCount.value = 0;

      for (int i = 0; i < participants.length; i++) {
        final participant = participants[i];

        final response = await _repository.sendInvitation(
          email: participant.email,
          name: participant.name,
        );

        if (response.success) {
          participant.invitationSent = true;
          participant.statusMessage = 'Invitation sent successfully';
          successCount.value++;
        } else {
          participant.invitationSent = false;
          participant.statusMessage = response.error ?? 'Failed to send invitation';
          failureCount.value++;
        }

        // Update UI for each participant
        participants[i] = participant;
        participants.refresh();

        // Small delay between requests
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Show completion message
      if (successCount.value == participants.length) {
        Get.snackbar(
          'Success',
          'All invitations sent successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Partial Success',
          '${successCount.value} sent, ${failureCount.value} failed',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      error.value = 'Error sending invitations: $e';
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      );
    } finally {
      isSending.value = false;
    }
  }

  // Search/filter participants
  List<CsvParticipant> searchParticipants(String query) {
    if (query.isEmpty) return participants;

    return participants.where((p) {
      return p.name.toLowerCase().contains(query.toLowerCase()) ||
          p.email.toLowerCase().contains(query.toLowerCase()) ||
          p.phone.contains(query);
    }).toList();
  }

  // Clear all data
  void clearData() {
    participants.clear();
    csvFileName.value = '';
    error.value = '';
    successCount.value = 0;
    failureCount.value = 0;
  }
}