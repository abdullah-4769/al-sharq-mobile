import 'package:get/get.dart';
import '../../repository/organizer_repo/organizer_create_session_repo.dart';
import 'package:flutter/material.dart';

class OrganizerCreateSessionViewModel extends GetxController {
  final _repo = OrganizerCreateSessionRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var success = false.obs;

  Future<bool> createSession(Map<String, dynamic> data) async {
    try {
      print('🚀 OrganizerCreateSessionViewModel: Starting createSession...');
      print('📝 Session Data: $data');
      isLoading.value = true;
      error.value = '';
      success.value = false;

      final response = await _repo.createSession(data);
      success.value = true;

      print('✅ OrganizerCreateSessionViewModel: Session created successfully');
      print('🎯 Session ID: ${response.id}');
      print('🎯 Session Title: ${response.title}');

      Get.snackbar(
        'Success 🎉',
        'Session "${response.title}" created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
      return true;
    } catch (e) {
      error.value = e.toString();
      print('❌ OrganizerCreateSessionViewModel: Error in createSession: $e');

      String errorMessage = _getErrorMessage(e);

      Get.snackbar(
        'Error ❌',
        'Failed to create session: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      return false;
    } finally {
      isLoading.value = false;
      print('🏁 OrganizerCreateSessionViewModel: createSession completed');
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString();
    if (errorString.contains('Network error')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('Request timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('Failed to create session')) {
      return errorString.replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}