import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/network/base_api_service.dart';
import '../data/request_models/sign_up_request_model.dart';
import '../utils/api_constants.dart';

// ==================== SIGNUP REPOSITORY ====================

class SignupRepository {
  final _apiService = NetworkApiServices();
  static const String baseUrl = 'http://138.68.104.206:3000';

  // ==================== SECTION: INITIAL SIGNUP ====================
  /// Register user with hardcoded password
  Future<SignupResponseModel> register(SignupRequestModel data) async {
    final response = await _apiService.getPostApiServices(
      ApiConstants.signup,
      data.toJson(),
    );
    return SignupResponseModel.fromJson(response);
  }

  // ==================== SECTION: SEND OTP FOR SIGNUP ====================
  /// Sends OTP to new user's email (reuses password reset OTP endpoint)
  Future<Map<String, dynamic>> sendSignupOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('=== SEND SIGNUP OTP DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      print('Exception in sendSignupOTP: $e');
      throw Exception('Error sending OTP: $e');
    }
  }

  // ==================== SECTION: VERIFY OTP FOR SIGNUP ====================
  /// Verifies OTP for signup
  Future<Map<String, dynamic>> verifySignupOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      print('=== VERIFY SIGNUP OTP DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      print('Exception in verifySignupOTP: $e');
      throw Exception('Error verifying OTP: $e');
    }
  }

  // ==================== SECTION: COMPLETE SIGNUP ====================
  /// Completes signup by setting user's password
  Future<CompleteSignupResponse> completeSignup(int userId, String password) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/complete-signup/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password}),
      );

      print('=== COMPLETE SIGNUP DEBUG ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return CompleteSignupResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to complete signup');
      }
    } catch (e) {
      print('Exception in completeSignup: $e');
      throw Exception('Error completing signup: $e');
    }
  }
}



//
// import 'package:al_sharq_conference/utils/api_constants.dart';
//
// import '../data/network/base_api_service.dart';
// import '../data/request_models/sign_up_request_model.dart';
//
// class SignupRepository {
//   final _apiService = NetworkApiServices();
//
//   Future<SignupResponseModel> register(SignupRequestModel data) async {
//     final response = await _apiService.getPostApiServices(ApiConstants.signup, data.toJson());
//     return SignupResponseModel.fromJson(response);
//   }
// }
