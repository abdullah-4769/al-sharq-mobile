import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/request_models/sign_up_request_model.dart';
import '../../data/response/api_response.dart';
import '../../repository/signup_repository.dart';
import '../../utils/shared_preference.dart';

// ==================== SIGNUP VIEW MODEL ====================
/// Handles signup with OTP verification flow

class SignupViewModel extends GetxController {
  final _repo = SignupRepository();

  // Observable state
  var signupResponse = ApiResponse<SignupResponseModel>().obs;
  var isLoading = false.obs;

  // ==================== HARDCODED DEFAULT PASSWORD ====================
  // This password is used for initial signup - user will set their own later
  static const String _defaultPassword = 'TempPass@2024';

  // ==================== SECTION: INITIAL SIGNUP ====================
  /// Register user with default password, then send OTP
  Future<void> signupWithOTP(String name, String email) async {
    try {
      isLoading.value = true;
      signupResponse.value = ApiResponse.loading();

      // Create signup model with hardcoded password
      final model = SignupRequestModel(
        name: name,
        email: email,
        password: _defaultPassword,
        role: 'participant',
      );

      // Register user
      final result = await _repo.register(model);
      signupResponse.value = ApiResponse.completed(result);

      // Save user data temporarily for OTP verification
      final userId = result.user['id'];
      await SharedPrefsHelper.savePassResetId(userId);
      await SharedPrefsHelper.savePassResetEmail(email);
      await SharedPrefsHelper.savePassResetRole('participant');

      print('User registered with ID: $userId');
      print('Sending OTP to: $email');

      // Send OTP
      await _repo.sendSignupOTP(email);

      Get.snackbar(
        'Success',
        'Verification code sent to your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      // Navigate to OTP verification
      Get.toNamed('/signup-otp-verification');
    } catch (e) {
      signupResponse.value = ApiResponse.error(e.toString());

      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== SECTION: TRADITIONAL SIGNUP (BACKUP) ====================
  /// Original signup method without OTP (kept for backward compatibility)
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

// ==================== SIGNUP OTP VERIFICATION CONTROLLER ====================
/// Handles OTP verification for signup

class SignupOTPVerificationController extends GetxController {
  final SignupRepository _repository = SignupRepository();

  // Observable variables
  final otpControllers = List.generate(6, (index) => ''.obs);
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final countdown = 60.obs;
  final canResend = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startCountdown();
  }

  // ==================== SECTION: OTP HANDLING ====================
  String get otp => otpControllers.map((e) => e.value).join();

  void updateOTPDigit(int index, String value) {
    if (value.length <= 1) {
      otpControllers[index].value = value;
    }
  }

  void clearOTP() {
    for (var controller in otpControllers) {
      controller.value = '';
    }
    errorMessage.value = '';
  }

  // ==================== SECTION: COUNTDOWN TIMER ====================
  void _startCountdown() {
    countdown.value = 60;
    canResend.value = false;

    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (countdown.value > 0) {
        countdown.value--;
        return true;
      } else {
        canResend.value = true;
        return false;
      }
    });
  }

  // ==================== SECTION: VERIFY OTP ====================
  Future<void> verifyOTP() async {
    if (otp.length != 6) {
      errorMessage.value = 'Please enter complete 6-digit OTP';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final email = await SharedPrefsHelper.getPassResetEmail();
      if (email == null) {
        throw Exception('Email not found. Please restart the process.');
      }

      await _repository.verifySignupOTP(email, otp);

      Get.snackbar(
        'Success',
        'Email verified successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to password setup screen
      Get.toNamed('/signup-set-password');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== SECTION: RESEND OTP ====================
  Future<void> resendOTP() async {
    if (!canResend.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final email = await SharedPrefsHelper.getPassResetEmail();
      if (email == null) {
        throw Exception('Email not found. Please restart the process.');
      }

      await _repository.sendSignupOTP(email);

      Get.snackbar(
        'Success',
        'OTP resent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearOTP();
      _startCountdown();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

// ==================== SIGNUP SET PASSWORD CONTROLLER ====================
/// Handles password setup after OTP verification

class SignupSetPasswordController extends GetxController {
  final SignupRepository _repository = SignupRepository();

  // Observable variables
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final showPassword = false.obs;
  final showConfirmPassword = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ==================== SECTION: PASSWORD VALIDATION ====================
  String? validatePassword(String pass) {
    if (pass.isEmpty) {
      return 'Please enter password';
    }
    if (pass.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(pass)) {
      return 'Include at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(pass)) {
      return 'Include at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(pass)) {
      return 'Include at least one number';
    }
    if (!RegExp(r'[!@#$%^&*()_+\[\]{}|;:,.<>?]').hasMatch(pass)) {
      return 'Include at least one special character';
    }
    return null;
  }

  bool _validatePasswordMatch() {
    if (password.value != confirmPassword.value) {
      errorMessage.value = 'Passwords do not match';
      return false;
    }
    return true;
  }

  // ==================== SECTION: COMPLETE SIGNUP ====================
  Future<void> completeSignup() async {
    // Validate password
    final validationError = validatePassword(password.value);
    if (validationError != null) {
      errorMessage.value = validationError;
      return;
    }

    // Check if passwords match
    if (!_validatePasswordMatch()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userId = await SharedPrefsHelper.getPassResetId();

      if (userId == null) {
        throw Exception('User ID not found. Please restart the process.');
      }

      // Complete signup with user's chosen password
      await _repository.completeSignup(userId, password.value);

      // Clear temporary data
      await SharedPrefsHelper.clearPassResetData();

      Get.snackbar(
        'Success',
        'Registration completed successfully! Please login.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      // Wait to show success message
      await Future.delayed(Duration(seconds: 2));

      // Navigate to login
      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== SECTION: CLEANUP ====================
  @override
  void onClose() {
    password.value = '';
    confirmPassword.value = '';
    errorMessage.value = '';
    super.onClose();
  }
}







// import 'package:get/get.dart';
//
// import '../../data/request_models/sign_up_request_model.dart';
// import '../../data/response/api_response.dart';
// import '../../repository/signup_repository.dart';
// import '../../utils/shared_preference.dart';
// import 'package:flutter/material.dart';
// class SignupViewModel extends GetxController {
//   final _repo = SignupRepository();
//
//   // Use Rx for reactive state management
//   var signupResponse = ApiResponse<SignupResponseModel>().obs;
//   var isLoading = false.obs;
//
//   Future<void> signup(SignupRequestModel model) async {
//     try {
//       isLoading.value = true;
//       signupResponse.value = ApiResponse.loading();
//
//       final result = await _repo.register(model);
//       signupResponse.value = ApiResponse.completed(result);
//       await SharedPrefsHelper.saveAuthToken(result.token);
//
//       Get.snackbar(
//         'Success',
//         'Registration Successful',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       signupResponse.value = ApiResponse.error(e.toString());
//
//       Get.snackbar(
//         'Error',
//         'Signup Failed: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }