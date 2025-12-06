import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/request_models/forget_pass/password_reset_model.dart';
import '../../utils/shared_preference.dart';


// ==================== PASSWORD RESET REPOSITORY ====================
/// Repository handling all password reset API calls

class PasswordResetRepository {
  static const String baseUrl = 'http://138.68.104.206:3000';

  // ==================== SECTION: SEND OTP ====================
  /// Sends OTP to user's email
  Future<SendOTPResponse> sendOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final otpResponse = SendOTPResponse.fromJson(data);

        // Save temporary reset data to SharedPreferences
        if (otpResponse.user != null) {
          await SharedPrefsHelper.savePassResetId(otpResponse.user!.id!);
          await SharedPrefsHelper.savePassResetRole(otpResponse.user!.role!);
          await SharedPrefsHelper.savePassResetEmail(email);
        }

        return otpResponse;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Error sending OTP: $e');
    }
  }

  // ==================== SECTION: VERIFY OTP ====================
  /// Verifies the OTP code
  Future<VerifyOTPResponse> verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return VerifyOTPResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }

  // ==================== SECTION: RESET PASSWORD ====================
  /// Resets password based on user role
  Future<ResetPasswordResponse> resetPassword(int userId, String password, String role) async {
    try {
      String endpoint;
      Map<String, dynamic> body;

      // Determine endpoint and body based on role
      if (role == 'sponsor') {
        endpoint = '$baseUrl/sponsors/$userId/reset-password';
        body = {'newPassword': password};
      } else if (role == 'exhibitor') {
        endpoint = '$baseUrl/exhibiteros/$userId/password';
        body = {'password': password};
      } else {
        // participant, organizer, speaker, registrationteam
        endpoint = '$baseUrl/auth/set-password/$userId';
        body = {'password': password};
      }

      final response = await http.patch(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Clear temporary reset data after successful password reset
        await SharedPrefsHelper.clearPassResetData();

        return ResetPasswordResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      throw Exception('Error resetting password: $e');
    }
  }
}



// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// import '../../data/request_models/forget_pass/password_reset_model.dart';
// import '../../utils/shared_preference.dart';
//
// // ==================== PASSWORD RESET REPOSITORY ====================
// /// Repository handling all password reset API calls
//
// class PasswordResetRepository {
//   static const String baseUrl = 'http://138.68.104.206:3000';
//
//   // ==================== SECTION: SEND OTP ====================
//   /// Sends OTP to user's email
//   Future<SendOTPResponse> sendOTP(String email) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/send-otp'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email}),
//       );
//
//       print('=== SEND OTP DEBUG ===');
//       print('Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         print('Parsed Data: $data');
//
//         // Check if user data exists
//         if (data['user'] != null) {
//           print('User data found: ${data['user']}');
//           print('User ID: ${data['user']['id']}');
//           print('User Role: ${data['user']['role']}');
//         } else {
//           print('WARNING: No user data in response!');
//         }
//
//         final otpResponse = SendOTPResponse.fromJson(data);
//
//         // Save temporary reset data to SharedPreferences
//         if (otpResponse.user != null) {
//           print('Saving to SharedPreferences...');
//           print('User ID to save: ${otpResponse.user!.id}');
//           print('User Role to save: ${otpResponse.user!.role}');
//
//           await SharedPrefsHelper.savePassResetId(otpResponse.user!.id!);
//           await SharedPrefsHelper.savePassResetRole(otpResponse.user!.role!);
//           await SharedPrefsHelper.savePassResetEmail(email);
//
//           // Verify saved data
//           final savedId = await SharedPrefsHelper.getPassResetId();
//           final savedRole = await SharedPrefsHelper.getPassResetRole();
//           print('Saved ID (verified): $savedId');
//           print('Saved Role (verified): $savedRole');
//         } else {
//           print('ERROR: otpResponse.user is null!');
//         }
//
//         return otpResponse;
//       } else {
//         final error = jsonDecode(response.body);
//         print('Error Response: $error');
//         throw Exception(error['message'] ?? 'Failed to send OTP');
//       }
//     } catch (e) {
//       print('Exception in sendOTP: $e');
//       throw Exception('Error sending OTP: $e');
//     }
//   }
//
//   // ==================== SECTION: VERIFY OTP ====================
//   /// Verifies the OTP code
//   Future<VerifyOTPResponse> verifyOTP(String email, String otp) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/verify-otp'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': email,
//           'otp': otp,
//         }),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         return VerifyOTPResponse.fromJson(data);
//       } else {
//         final error = jsonDecode(response.body);
//         throw Exception(error['message'] ?? 'Invalid OTP');
//       }
//     } catch (e) {
//       throw Exception('Error verifying OTP: $e');
//     }
//   }
//   Future<ResetPasswordResponse> resetPassword(int userId, String password, String role) async {
//     try {
//       String endpoint;
//       Map<String, dynamic> body;
//
//       // Determine endpoint and body based on role
//       if (role == 'sponsor') {
//         endpoint = '$baseUrl/sponsors/$userId/reset-password';
//         body = {'newPassword': password};
//       } else if (role == 'exhibitor') {
//         endpoint = '$baseUrl/exhibiteros/$userId/password';
//         body = {'password': password};
//       } else {
//         // participant, organizer, speaker, registrationteam
//         endpoint = '$baseUrl/auth/set-password/$userId';
//         body = {'password': password};
//       }
//
//       final response = await http.patch(
//         Uri.parse(endpoint),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(body),
//       );
//
//       print('Reset Password Response Status: ${response.statusCode}');
//       print('Reset Password Response Body: ${response.body}');
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//
//         ResetPasswordResponse resetResponse;
//
//         // Handle exhibitor response (no message field)
//         if (role == 'exhibitor') {
//           // Exhibitor returns different structure
//           resetResponse = ResetPasswordResponse(
//             message: 'Password updated successfully',
//             id: data['id'],
//             name: data['name'],
//             email: data['email'],
//           );
//         } else {
//           // Other roles return message field
//           resetResponse = ResetPasswordResponse.fromJson(data);
//         }
//
//         // ✅ **IMPORTANT**: Clear data AFTER processing response
//         await SharedPrefsHelper.clearPassResetData();
//
//         return resetResponse;
//       } else {
//         final error = jsonDecode(response.body);
//         throw Exception(error['message'] ?? 'Failed to reset password');
//       }
//     } catch (e) {
//       print('Exception in resetPassword: $e');
//       throw Exception('Error resetting password: $e');
//     }
//   }
// }