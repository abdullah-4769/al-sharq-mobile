// lib/view_model/registration_team_viewmodels/session_check_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/request_models/registration_team/session_check_model.dart';
import '../../repository/registration_team_repo/session_check_repository.dart';


class SessionCheckViewModel extends GetxController {
  final SessionCheckRepository _repository = SessionCheckRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  Future<Map<String, dynamic>> checkSessionRegistration({
    required int sessionId,
    required int userId,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final request = SessionCheckRequest(userId: userId.toString());
      final response = await _repository.checkSessionRegistration(
        sessionId: sessionId,
        request: request,
      );

      return {
        'success': response.success,
        'message': response.message,
        'isRegistered': response.isRegistered,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error checking registration: $e',
        'isRegistered': false,
      };
    } finally {
      isLoading.value = false;
    }
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}