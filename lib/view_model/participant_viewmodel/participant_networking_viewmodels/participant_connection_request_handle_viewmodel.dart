// lib/view_model/participant_viewmodel/participant_networking_viewmodels/participant_connection_request_handle_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../repository/participants_repository/participant_networking/participant_connection_request_handle_repo.dart';

class ParticipantConnectionRequestHandleViewModel extends GetxController {
  final ParticipantConnectionRequestHandleRepo _repo = ParticipantConnectionRequestHandleRepo();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final RxInt currentRequestId = 0.obs; // Track current request ID
  final RxString currentAction = ''.obs; // Track current action (ACCEPTED/REJECTED)

  Future<bool> handleConnectionRequest({
    required int requestId,
    required String status,
    required BuildContext context,
  }) async {
    try {
      print('=== Handling connection request: $status for ID: $requestId ===');



      // Set loading state for specific request and action
      isLoading.value = true;
      currentRequestId.value = requestId;
      currentAction.value = status;

      errorMessage.value = '';
      successMessage.value = '';

      final result = await _repo.handleConnectionRequest(
        requestId,
        status,
        context,
      );

      successMessage.value = 'Connection request $status successfully';

      Get.snackbar(
        'Success',
        'Connection request $status successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print('=== Successfully handled connection request: ${result.status} ===');
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to handle connection request: $e';
      print('=== Error handling connection request: $e ===');

      Get.snackbar(
        'Error',
        'Failed to handle connection request: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      // Reset loading state
      isLoading.value = false;
      currentRequestId.value = 0;
      currentAction.value = '';
    }
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}