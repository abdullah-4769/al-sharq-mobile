
import 'package:al_sharq_conference/organizer_view/manage_session/manage_session_view.dart';
import 'package:al_sharq_conference/organizer_view/organizer_dashboard/organizer_dashboard.dart';
import 'package:al_sharq_conference/participants_view/auth/login_view.dart';
import 'package:al_sharq_conference/participants_view/auth/signup_profile.dart';
import 'package:al_sharq_conference/participants_view/home_page/home_view.dart';
import 'package:al_sharq_conference/speaker_view/auth/signup_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/response/api_response.dart';
import '../../repository/login_repository.dart';
import '../../utils/shared_preference.dart';
import '../data/request_models/login_request_model.dart';
import '../data/response_models/login_response_model.dart';
import '../exhibitor_view/exhibitor_dashboard/exhibitor_dashboard.dart';
import '../registration_team/participant_list_screen.dart';
import '../speaker_view/manage_session_speaker/manage_session_speaker.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../sponser_view/manage_session/manage_session.dart';

class LoginViewModel extends GetxController {
  final _repo = LoginRepository();

  var loginResponse = ApiResponse<LoginResponseModel>(
      Status.LOADING,
      null,
      null
  ).obs;
  var isLoading = false.obs;
  var rememberMe = false.obs;
  var currentRole = ''.obs;
  Future<void> login(LoginRequestModel model) async {
    try {
      isLoading.value = true;
      loginResponse.value = ApiResponse(Status.LOADING, null, null);

      final result = await _repo.login(model);
      loginResponse.value = ApiResponse(Status.COMPLETED, null, result);

      await _saveUserData(result);
      currentRole.value = result.user.role;

      Get.snackbar(
        'Success',
        'Login Successful',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      navigateBasedOnRole(result.user.role);

    } catch (e) {
      loginResponse.value = ApiResponse(Status.ERROR, e.toString(), null);

      // Handle Dio errors with status codes
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          Get.snackbar(
            'Account Blocked',
            'Your account has been blocked. Please contact support.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return;
        } else if (e.response?.statusCode == 401) {
          Get.snackbar(
            'Login Failed',
            'Email or password is incorrect. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return;
        }
      }

      // Fallback to parsing error message
      final errorMessage = _parseErrorMessage(e.toString());

      Get.snackbar(
        'Login Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveUserData(LoginResponseModel result) async {
    await SharedPrefsHelper.saveAuthToken(result.token);
    await SharedPrefsHelper.saveUserId(result.user.id);
    await SharedPrefsHelper.saveUserName(result.user.name);
    await SharedPrefsHelper.saveUserEmail(result.user.email);
    await SharedPrefsHelper.saveUserRole(result.user.role);
    await SharedPrefsHelper.saveUserPhone(result.user.phone);
    await SharedPrefsHelper.saveUserOrganization(result.user.organization);
    await SharedPrefsHelper.saveUserPhoto(result.user.photo);
    await SharedPrefsHelper.saveUserBio(result.user.bio); // Add this line
    // Convert int? to String? for saving
    if (result.latestEventId != null) {
      await SharedPrefsHelper.saveLatestEventId(result.latestEventId!.toString());
    } else {
      await SharedPrefsHelper.saveLatestEventId(null);
    }
    await SharedPrefsHelper.saveRememberMe(rememberMe.value);

    if (result.user.speakerId != null) {
      await SharedPrefsHelper.saveSpeakerId(result.user.speakerId!);
    }

    if (result.user.file != null && result.user.file!.isNotEmpty) {
      await SharedPrefsHelper.setUserImage(result.user.file!);
    }
  }

  // ✅ PUBLIC METHOD - Can be called from anywhere
  void navigateBasedOnRole(String role) {
    switch (role) {
      case 'participant':
        Get.offAll(() => HomeView());
        break;
      case 'speaker':
        Get.offAll(() => SpeakerConferenceDashboardScreen());
        break;
      case 'exhibitor':
        Get.offAll(() => ExhibitorDashboardScreen(exhibitorId: 5,));
        break;
      case 'sponsor':
        Get.offAll(() => SponserDashboardScreen());
        break;
      case 'organizer':
        Get.offAll(() => OrganizerDashboard());
        break;

      case 'registrationteam': // Add this case
        Get.offAll(() => const ParticipantListScreen());
        break;
      default:
        Get.offAllNamed('/home');
    }
  }

  Future<void> switchRole(String newRole) async {
    try {
      currentRole.value = newRole;
      await SharedPrefsHelper.saveUserRole(newRole);
      navigateBasedOnRole(newRole);

      Get.snackbar(
        'Success',
        'Switched to $newRole view',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to switch role: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> canSwitchToParticipant() async {
    final userRole = await SharedPrefsHelper.getUserRole();
    return userRole == 'speaker';
  }

  Future<bool> canSwitchToSpeaker() async {
    final userRole = await SharedPrefsHelper.getUserRole();
    final speakerId = await SharedPrefsHelper.getSpeakerId();
    return userRole == 'participant' && speakerId != null;
  }

  String _parseErrorMessage(String error) {
    if (error.contains('HTTP 401') || error.contains('Invalid credentials')) {
      return 'Email or password is incorrect. Please try again.';
    } else if (error.contains('HTTP 404')) {
      return 'Service not available. Please try again later.';
    } else if (error.contains('HTTP 500')) {
      return 'Server error. Please try again later.';
    } else if (error.contains('TimeoutException') || error.contains('timed out')) {
      return 'Request timed out. Please check your internet connection.';
    } else if (error.contains('SocketException') || error.contains('Network is unreachable')) {
      return 'No internet connection. Please check your network settings.';
    } else {
      return 'Login failed. Please check your credentials and try again.';
    }
  }

  Future<bool> checkIfUserLoggedIn() async {
    return await SharedPrefsHelper.isUserLoggedIn();
  }

  Future<Map<String, dynamic>> getStoredUserData() async {
    return await SharedPrefsHelper.getAllUserData();
  }

  Future<String?> getUserRole() async {
    return await SharedPrefsHelper.getUserRole();
  }

  String getCurrentRole() {
    return currentRole.value;
  }

  Future<void> logout() async {
    currentRole.value = '';
    await SharedPrefsHelper.clearAuthToken();
    await SharedPrefsHelper.clearUserData();
    Get.offAll(() => LoginScreen());
  }

  Future<bool> hasRole(String role) async {
    final userRole = await SharedPrefsHelper.getUserRole();
    return userRole == role;
  }

  Future<Map<String, dynamic>> getUserDisplayInfo() async {
    return {
      'name': await SharedPrefsHelper.getUserName() ?? 'User',
      'email': await SharedPrefsHelper.getUserEmail() ?? '',
      'role': await SharedPrefsHelper.getUserRole() ?? 'participant',
      'userId': await SharedPrefsHelper.getUserId() ?? 0,
      'speakerId': await SharedPrefsHelper.getSpeakerId(),
    };
  }

  Future<void> initializeCurrentRole() async {
    final role = await SharedPrefsHelper.getUserRole();
    if (role != null) {
      currentRole.value = role;
    }
  }
}
