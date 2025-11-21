import 'package:get/get.dart';
import '../../repository/organizer_repo/organizer_delete_session_repo.dart';
import 'package:flutter/material.dart';

class OrganizerDeleteSessionViewModel extends GetxController {
  final _repo = OrganizerDeleteSessionRepo();

  var isLoading = false.obs;
  var error = ''.obs;

  Future<bool> deleteSession(int sessionId) async {
    try {
      print('🚀 OrganizerDeleteSessionViewModel: Starting deleteSession for ID: $sessionId');
      isLoading.value = true;
      error.value = '';

      final success = await _repo.deleteSession(sessionId);

      if (success) {
        print('✅ OrganizerDeleteSessionViewModel: Session deleted successfully');

        Get.snackbar(
          'Success ✅',
          'Session deleted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return true;
      } else {
        throw Exception('Failed to delete session');
      }
    } catch (e) {
      error.value = e.toString();
      print('❌ OrganizerDeleteSessionViewModel: Error in deleteSession: $e');

      String errorMessage = _getErrorMessage(e);

      Get.snackbar(
        'Error ❌',
        'Failed to delete session: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      return false;
    } finally {
      isLoading.value = false;
      print('🏁 OrganizerDeleteSessionViewModel: deleteSession completed');
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString();
    if (errorString.contains('Network error')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('Request timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('Failed to delete session')) {
      return errorString.replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}