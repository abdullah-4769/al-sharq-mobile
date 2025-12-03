import 'package:get/get.dart';
import 'package:al_sharq_conference/data/request_models/sign_up_request_model.dart';
import 'package:al_sharq_conference/data/response/api_response.dart';
import 'package:al_sharq_conference/repository/signup_repository.dart';
import 'package:al_sharq_conference/utils/shared_preference.dart';
import 'package:flutter/material.dart';
class RegistrationTeamAddViewModel extends GetxController {
  final SignupRepository _repo = SignupRepository();

  var isLoading = false.obs;
 var apiResponse = ApiResponse<dynamic>.loading().obs;
  var error = ''.obs;

  Future<bool> addRegistrationTeamMember({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      print('Starting registration for: $email');
      isLoading.value = true;
      error.value = '';

      final requestModel = SignupRequestModel(
        name: name,
        email: email,
        password: password,
        role: 'registrationteam', // Fixed role
      );

      print('Sending request with role: ${requestModel.role}');

      final result = await _repo.register(requestModel);
      apiResponse.value = ApiResponse.completed(result);

      // Save token if needed
      await SharedPrefsHelper.saveAuthToken(result.token);

      print('Registration successful for: $email');
      return true;

    } catch (e) {
      error.value = e.toString();
      apiResponse.value = ApiResponse.error(e.toString());

      print('Registration failed for $email: $e');

      Get.snackbar(
        'Registration Failed',
        'Failed to add team member: ${_parseErrorMessage(e.toString())}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;

    } finally {
      isLoading.value = false;
    }
  }

  String _parseErrorMessage(String error) {
    if (error.contains('email already exists') || error.contains('duplicate')) {
      return 'Email already exists. Please use a different email.';
    } else if (error.contains('network') || error.contains('socket')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}