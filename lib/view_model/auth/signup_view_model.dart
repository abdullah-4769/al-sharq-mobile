import 'package:get/get.dart';

import '../../data/request_models/sign_up_request_model.dart';
import '../../data/response/api_response.dart';
import '../../repository/signup_repository.dart';
import '../../utils/shared_preference.dart';
import 'package:flutter/material.dart';
class SignupViewModel extends GetxController {
  final _repo = SignupRepository();

  // Use Rx for reactive state management
  var signupResponse = ApiResponse<SignupResponseModel>().obs;
  var isLoading = false.obs;

  Future<void> signup(SignupRequestModel model) async {
    try {
      isLoading.value = true;
      signupResponse.value = ApiResponse.loading();

      final result = await _repo.register(model);
      signupResponse.value = ApiResponse.completed(result);
      await SharedPrefsHelper.saveAuthToken(result.token);

      Get.snackbar(
        'Success',
        'Registration Successful',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      signupResponse.value = ApiResponse.error(e.toString());

      Get.snackbar(
        'Error',
        'Signup Failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}