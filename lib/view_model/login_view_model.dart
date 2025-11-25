
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
import '../speaker_view/manage_session_speaker/manage_session_speaker.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

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

      navigateBasedOnRole(result.user.role); // ✅ Changed to public

    } catch (e) {
      loginResponse.value = ApiResponse(Status.ERROR, e.toString(), null);
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
    await SharedPrefsHelper.saveLatestEventId(result.latestEventId);
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
        Get.offAll(() => OrganizerManageSessionsScreen());
        break;
      case 'organizer':
        Get.offAll(() => OrganizerDashboard());
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
// class LoginViewModel extends GetxController {
//   final _repo = LoginRepository();
//
//   var loginResponse = ApiResponse<LoginResponseModel>(
//       Status.LOADING,
//       null,
//       null
//   ).obs;
//   var isLoading = false.obs;
//   var rememberMe = false.obs;
//   var currentRole = ''.obs; // Track current role for switching
//
//   Future<void> login(LoginRequestModel model) async {
//     try {
//       isLoading.value = true;
//       loginResponse.value = ApiResponse(Status.LOADING, null, null);
//
//       final result = await _repo.login(model);
//       loginResponse.value = ApiResponse(Status.COMPLETED, null, result);
//
//       // Save all user data including role and speaker ID
//       await _saveUserData(result);
//
//       // Set current role
//       currentRole.value = result.user.role;
//
//       Get.snackbar(
//         'Success',
//         'Login Successful',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );
//
//       // Navigate based on role
//       _navigateBasedOnRole(result.user.role);
//
//     } catch (e) {
//       loginResponse.value = ApiResponse(Status.ERROR, e.toString(), null);
//
//       final errorMessage = _parseErrorMessage(e.toString());
//
//       Get.snackbar(
//         'Login Failed',
//         errorMessage,
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 4),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> _saveUserData(LoginResponseModel result) async {
//     // Save token
//     await SharedPrefsHelper.saveAuthToken(result.token);
//
//     // Save user details
//     await SharedPrefsHelper.saveUserId(result.user.id);
//     await SharedPrefsHelper.saveUserName(result.user.name);
//     await SharedPrefsHelper.saveUserEmail(result.user.email);
//     await SharedPrefsHelper.saveUserRole(result.user.role);
//     await SharedPrefsHelper.saveUserPhone(result.user.phone);
//     await SharedPrefsHelper.saveUserOrganization(result.user.organization);
//     await SharedPrefsHelper.saveUserPhoto(result.user.photo);
//     await SharedPrefsHelper.saveLatestEventId(result.latestEventId);
//     await SharedPrefsHelper.saveRememberMe(rememberMe.value);
//
//     // Save speaker ID if available (for speaker role)
//     if (result.user.speakerId != null) {
//       await SharedPrefsHelper.saveSpeakerId(result.user.speakerId!);
//     }
//
//     // Save user image if available
//     if (result.user.file != null && result.user.file!.isNotEmpty) {
//       await SharedPrefsHelper.setUserImage(result.user.file!);
//     }
//   }
//
//   void _navigateBasedOnRole(String role) {
//     switch (role) {
//       case 'participant':
//         Get.offAll(HomeView());
//         break;
//       case 'speaker':
//         Get.offAll(SpeakerConferenceDashboardScreen());
//         break;
//       case 'exhibitor':
//         Get.offAll(OrganizerManageSessionsScreen());
//         break;
//       case 'sponsor':
//         Get.offAll(OrganizerManageSessionsScreen());
//         break;
//       case 'organizer':
//         Get.offAll(OrganizerDashboard());
//         break;
//       default:
//         Get.offAllNamed('/home');
//     }
//   }
//
//   // New method to switch roles
//   Future<void> switchRole(String newRole) async {
//     try {
//       // Update current role
//       currentRole.value = newRole;
//
//       // Update role in shared preferences
//       await SharedPrefsHelper.saveUserRole(newRole);
//
//       // Navigate to appropriate screen based on new role
//       switch (newRole) {
//         case 'participant':
//           Get.offAll(HomeView());
//           break;
//         case 'speaker':
//           Get.offAll(SpeakerConferenceDashboardScreen());
//           break;
//         case 'exhibitor':
//           Get.offAll(OrganizerManageSessionsScreen());
//           break;
//         case 'sponsor':
//           Get.offAll(OrganizerManageSessionsScreen());
//           break;
//         case 'organizer':
//           Get.offAll(OrganizerDashboard());
//           break;
//         default:
//           Get.offAllNamed('/home');
//       }
//
//       Get.snackbar(
//         'Success',
//         'Switched to $newRole view',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to switch role: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // Check if user can switch to participant role
//   Future<bool> canSwitchToParticipant() async {
//     final userRole = await SharedPrefsHelper.getUserRole();
//     // Speakers can switch to participant role
//     return userRole == 'speaker';
//   }
//
//   // Check if user can switch to speaker role
//   Future<bool> canSwitchToSpeaker() async {
//     final userRole = await SharedPrefsHelper.getUserRole();
//     final speakerId = await SharedPrefsHelper.getSpeakerId();
//     // Only users with speaker ID can switch to speaker role
//     return userRole == 'participant' && speakerId != null;
//   }
//
//   String _parseErrorMessage(String error) {
//     if (error.contains('HTTP 401') || error.contains('Invalid credentials')) {
//       return 'Email or password is incorrect. Please try again.';
//     } else if (error.contains('HTTP 404')) {
//       return 'Service not available. Please try again later.';
//     } else if (error.contains('HTTP 500')) {
//       return 'Server error. Please try again later.';
//     } else if (error.contains('TimeoutException') || error.contains('timed out')) {
//       return 'Request timed out. Please check your internet connection.';
//     } else if (error.contains('SocketException') || error.contains('Network is unreachable')) {
//       return 'No internet connection. Please check your network settings.';
//     } else {
//       return 'Login failed. Please check your credentials and try again.';
//     }
//   }
//
//   // Check if user is already logged in
//   Future<bool> checkIfUserLoggedIn() async {
//     return await SharedPrefsHelper.isUserLoggedIn();
//   }
//
//   // Get stored user data
//   Future<Map<String, dynamic>> getStoredUserData() async {
//     return await SharedPrefsHelper.getAllUserData();
//   }
//
//   // Get user role
//   Future<String?> getUserRole() async {
//     return await SharedPrefsHelper.getUserRole();
//   }
//
//   // Get current role (for UI)
//   String getCurrentRole() {
//     return currentRole.value;
//   }
//
//   // Logout
//   Future<void> logout() async {
//     currentRole.value = '';
//     await SharedPrefsHelper.clearAuthToken();
//     await SharedPrefsHelper.clearUserData();
//     Get.offAll(LoginScreen());
//     //Get.offAllNamed(LoginScreen());
//   }
//
//   // Check if user has specific role
//   Future<bool> hasRole(String role) async {
//     final userRole = await SharedPrefsHelper.getUserRole();
//     return userRole == role;
//   }
//
//   // Get user display info
//   Future<Map<String, dynamic>> getUserDisplayInfo() async {
//     return {
//       'name': await SharedPrefsHelper.getUserName() ?? 'User',
//       'email': await SharedPrefsHelper.getUserEmail() ?? '',
//       'role': await SharedPrefsHelper.getUserRole() ?? 'participant',
//       'userId': await SharedPrefsHelper.getUserId() ?? 0,
//       'speakerId': await SharedPrefsHelper.getSpeakerId(),
//     };
//   }
//
//   // Initialize current role from shared preferences
//   Future<void> initializeCurrentRole() async {
//     final role = await SharedPrefsHelper.getUserRole();
//     if (role != null) {
//       currentRole.value = role;
//     }
//   }
// }