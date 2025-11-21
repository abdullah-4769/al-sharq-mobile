import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../repository/organizer_repo/organizer_delete_user_repo.dart';
class OrganizerDeleteUserViewModel extends GetxController {
  final _repo = OrganizerDeleteUserRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var success = false.obs;

  Future<bool> deleteUser(int userId) async {
    try {
      isLoading.value = true;
      error.value = '';
      success.value = false;

      final result = await _repo.deleteUser(userId);
      success.value = result;

      if (result) {
        Get.snackbar(
          'Success',
          'User deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        error.value = 'Failed to delete user';
        Get.snackbar(
          'Error',
          'Failed to delete user',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete user: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }


}