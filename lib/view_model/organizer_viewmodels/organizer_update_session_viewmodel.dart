import 'package:get/get.dart';
import '../../repository/organizer_repo/organizer_update_session_repo.dart';
import 'package:flutter/material.dart';

class OrganizerUpdateSessionViewModel extends GetxController {
  final _repo = OrganizerUpdateSessionRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var success = false.obs;

  Future<bool> updateSession(int sessionId, Map<String, dynamic> data) async {
    try {
      print('🚀 OrganizerUpdateSessionViewModel: Starting updateSession for ID: $sessionId');
      print('📝 Update Data: $data');
      isLoading.value = true;
      error.value = '';
      success.value = false;

      final response = await _repo.updateSession(sessionId, data);
      success.value = true;

      print('✅ OrganizerUpdateSessionViewModel: Session updated successfully');
      print('🎯 Updated Session ID: ${response.id}');
      print('🎯 Updated Session Title: ${response.title}');

      Get.snackbar(
        'Success ✅',
        'Session "${response.title}" updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
      return true;
    } catch (e) {
      error.value = e.toString();
      print('❌ OrganizerUpdateSessionViewModel: Error in updateSession: $e');

      String errorMessage = _getErrorMessage(e);

      Get.snackbar(
        'Error ❌',
        'Failed to update session: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      return false;
    } finally {
      isLoading.value = false;
      print('🏁 OrganizerUpdateSessionViewModel: updateSession completed');
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString();
    if (errorString.contains('Network error')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('Request timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('Failed to update session')) {
      return errorString.replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}