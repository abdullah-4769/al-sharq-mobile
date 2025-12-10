import 'package:get/get.dart';
import '../../data/response_models/organizer_response_models/organizer_showlist_exhibitors_model.dart';
import '../../repository/organizer_repo/organizer_showlist_exhibitors_repo.dart';
import 'package:flutter/material.dart';

class OrganizerShowListExhibitorsViewModel extends GetxController {
  final _repo = OrganizerShowListExhibitorsRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var exhibitorsList = <OrganizerShowListExhibitorsModel>[].obs;

  Future<void> getExhibitorsList() async {
    try {
      print('🚀 OrganizerShowListExhibitorsViewModel: Starting getExhibitorsList...');
      isLoading.value = true;
      error.value = '';

      final exhibitors = await _repo.getExhibitorsList();
      exhibitorsList.value = exhibitors;

      print('✅ OrganizerShowListExhibitorsViewModel: Successfully loaded exhibitors list');
      print('📊 Total Exhibitors: ${exhibitors.length}');

      for (var exhibitor in exhibitors) {
        print('🏢 Exhibitor: ${exhibitor.name} (ID: ${exhibitor.id})');
        print('   - Email: ${exhibitor.email}');
        print('   - Photo URL: ${exhibitor.picUrl}');
      }
      //
      // Get.snackbar(
      //   'Success',
      //   'Exhibitors list loaded successfully!',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      //   duration: Duration(seconds: 3),
      // );

    } catch (e) {
      error.value = e.toString();
      print('❌ OrganizerShowListExhibitorsViewModel: Error in getExhibitorsList: $e');

      String errorMessage = _getErrorMessage(e);

      Get.snackbar(
        'Error',
        'Failed to load exhibitors list: $errorMessage',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
      print('🏁 OrganizerShowListExhibitorsViewModel: getExhibitorsList completed');
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString();
    if (errorString.contains('Network error')) {
      return 'Please check your internet connection and try again.';
    } else if (errorString.contains('Request timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('Failed to load exhibitors')) {
      return errorString.replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}