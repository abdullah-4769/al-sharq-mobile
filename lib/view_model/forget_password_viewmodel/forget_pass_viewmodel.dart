import 'package:get/get.dart';
import '../../repository/forget_pass_/forget_password_repo.dart';
import '../../utils/shared_preference.dart';

// ==================== FORGOT PASSWORD CONTROLLER ====================
/// Handles forgot password screen logic

class ForgotPasswordController extends GetxController {
  final PasswordResetRepository _repository = PasswordResetRepository();

  // Observable variables
  final email = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ==================== SECTION: EMAIL VALIDATION ====================
  /// Validates email format
  bool _validateEmail() {
    if (email.value.isEmpty) {
      errorMessage.value = 'Please enter your email';
      return false;
    }
    if (!GetUtils.isEmail(email.value)) {
      errorMessage.value = 'Please enter a valid email';
      return false;
    }
    return true;
  }

  // ==================== SECTION: SEND OTP ====================
  /// Sends OTP to user's email
  Future<void> sendOTP() async {
    if (!_validateEmail()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.sendOTP(email.value);
      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to OTP verification screen
      Get.toNamed('/otp-verification');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== SECTION: CLEANUP ====================
  @override
  void onClose() {
    email.value = '';
    errorMessage.value = '';
    super.onClose();
  }
}

// ==================== OTP VERIFICATION CONTROLLER ====================
/// Handles OTP verification screen logic

class OTPVerificationController extends GetxController {
  final PasswordResetRepository _repository = PasswordResetRepository();

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
  /// Gets complete OTP string
  String get otp => otpControllers.map((e) => e.value).join();

  /// Updates OTP digit at specific index
  void updateOTPDigit(int index, String value) {
    if (value.length <= 1) {
      otpControllers[index].value = value;
    }
  }

  /// Clears all OTP fields
  void clearOTP() {
    for (var controller in otpControllers) {
      controller.value = '';
    }
    errorMessage.value = '';
  }

  // ==================== SECTION: COUNTDOWN TIMER ====================
  /// Starts countdown timer for resend OTP
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
  /// Verifies the entered OTP
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

      final response = await _repository.verifyOTP(email, otp);

      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to set new password screen
      Get.toNamed('/set-new-password');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== SECTION: RESEND OTP ====================
  /// Resends OTP to user's email
  Future<void> resendOTP() async {
    if (!canResend.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final email = await SharedPrefsHelper.getPassResetEmail();
      if (email == null) {
        throw Exception('Email not found. Please restart the process.');
      }

      final response = await _repository.sendOTP(email);

      Get.snackbar(
        'Success',
        'OTP resent successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      clearOTP();
      _startCountdown();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

// ==================== SET NEW PASSWORD CONTROLLER ====================
/// Handles new password setting screen logic

class SetNewPasswordController extends GetxController {
  final PasswordResetRepository _repository = PasswordResetRepository();

  // Observable variables
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final showPassword = false.obs;
  final showConfirmPassword = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ==================== SECTION: PASSWORD VALIDATION ====================
  /// Validates password requirements
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

  /// Validates if passwords match
  bool _validatePasswordMatch() {
    if (password.value != confirmPassword.value) {
      errorMessage.value = 'Passwords do not match';
      return false;
    }
    return true;
  }

  // ==================== SECTION: RESET PASSWORD ====================
  Future<void> resetPassword() async {
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
      final role = await SharedPrefsHelper.getPassResetRole();

      print('Retrieved from SharedPreferences:');
      print('User ID: $userId');
      print('Role: $role');

      // ✅ Add better null checks
      if (userId == null) {
        throw Exception('User ID not found. Please restart the process.');
      }

      if (role == null) {
        throw Exception('User role not found. Please restart the process.');
      }

      if (password.value.isEmpty) {
        throw Exception('Password cannot be empty.');
      }

      final response = await _repository.resetPassword(
        userId,
        password.value,
        role,
      );

      Get.snackbar(
        'Success',
        response.message,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );

      // ✅ Clear controller data before navigation
      password.value = '';
      confirmPassword.value = '';

      // Add a small delay to show success message
      await Future.delayed(Duration(seconds: 2));

      // Navigate to login screen
      Get.offAllNamed('/login');
      // Ensure controller cleaned
      Get.delete<SetNewPasswordController>();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
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