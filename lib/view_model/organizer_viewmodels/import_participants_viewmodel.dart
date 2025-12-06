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

  @override
  void onInit() {
    super.onInit();
    print('DEBUG: ImportParticipantsViewModel initialized');
  }

  // Parse CSV file and extract participant data
  Future<void> parseCsvFile(File file) async {
    try {
      isLoading.value = true;
      error.value = '';
      participants.clear();

      print('DEBUG: Starting CSV parsing');

      // Read file content
      final fileContent = await file.readAsString();

      // Parse CSV
      List<List<dynamic>> csvData = const CsvToListConverter().convert(fileContent);

      print('DEBUG: CSV rows: ${csvData.length}');

      // Skip header row and parse data
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i].map((e) => e.toString()).toList();

        if (row.isNotEmpty && row.length >= 2) {
          final participant = CsvParticipant.fromCsvRow(row);

          // Validate email
          if (participant.email.isNotEmpty && _isValidEmail(participant.email)) {
            participants.add(participant);
            print('DEBUG: Added participant: ${participant.name}');
          }
        }
      }

      if (participants.isEmpty) {
        error.value = 'No valid participants found in CSV file';
      } else {
        csvFileName.value = file.path.split('/').last;
        print('DEBUG: Total participants loaded: ${participants.length}');
      }
    } catch (e) {
      error.value = 'Error parsing CSV: ${e.toString()}';
      print('DEBUG: CSV parsing error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);
  }

  // Send invitations to all participants
  Future<void> sendInvitations() async {
    if (participants.isEmpty) {
      Get.snackbar(
        'No Participants',
        'Please upload a CSV file first',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSending.value = true;
      successCount.value = 0;
      failureCount.value = 0;

      print('DEBUG: Starting to send ${participants.length} invitations');

      for (int i = 0; i < participants.length; i++) {
        final participant = participants[i];

        print('DEBUG: Sending invitation ${i + 1}/${participants.length} to ${participant.email}');

        final response = await _repository.sendInvitation(
          email: participant.email,
          name: participant.name,
        );

        if (response.success) {
          participant.invitationSent = true;
          participant.statusMessage = 'Invitation sent successfully';
          successCount.value++;
          print('DEBUG: Success for ${participant.email}');
        } else {
          participant.invitationSent = false;
          participant.statusMessage = response.error ?? 'Failed to send';
          failureCount.value++;
          print('DEBUG: Failed for ${participant.email}: ${response.error}');
        }

        // Update UI
        participants[i] = participant;
        participants.refresh();

        // Small delay between requests
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Show completion message
      if (successCount.value == participants.length) {
        Get.snackbar(
          'Success',
          'All ${successCount.value} invitations sent successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Completed',
          '${successCount.value} sent, ${failureCount.value} failed',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }

      print('DEBUG: Sending complete - Success: ${successCount.value}, Failed: ${failureCount.value}');
    } catch (e) {
      error.value = 'Error: ${e.toString()}';
      print('DEBUG: Error in sendInvitations: $e');
      Get.snackbar(
        'Error',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  // Search/filter participants
  List<CsvParticipant> searchParticipants(String query) {
    if (query.isEmpty) return participants;

    final lowerQuery = query.toLowerCase();
    return participants.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.email.toLowerCase().contains(lowerQuery) ||
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

  @override
  void onClose() {
    print('DEBUG: ImportParticipantsViewModel disposed');
    super.onClose();
  }
}