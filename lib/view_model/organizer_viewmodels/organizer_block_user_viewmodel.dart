import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/request_models/organizer/organizer_block_user_model.dart';
import '../../repository/organizer_repo/organizer_block_user_repo.dart';

class OrganizerBlockUserViewModel extends GetxController {
  final _repo = OrganizerBlockUserRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var success = false.obs;

  Future<bool> blockUser(int userId, bool blockStatus) async {
    try {
      isLoading.value = true;
      error.value = '';
      success.value = false;

      print('Block User ViewModel: userId=$userId, blockStatus=$blockStatus');

      final request = OrganizerBlockUserRequestModel(
        id: userId,
        isBlocked: blockStatus,
      );

      final response = await _repo.blockUser(request);
      success.value = response.success;

      if (response.success) {
        Get.snackbar(
          'Success',
          response.message.isNotEmpty ? response.message : 'User status updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return true;
      } else {
        error.value = response.message;
        Get.snackbar(
          'Error',
          response.message.isNotEmpty ? response.message : 'Failed to update user status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      print('Error in blockUser viewmodel: $e');
      Get.snackbar(
        'Error',
        'Failed to update user status: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}