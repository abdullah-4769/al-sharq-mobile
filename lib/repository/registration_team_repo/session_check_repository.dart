// lib/repository/registration_team_repository/session_check_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/request_models/registration_team/session_check_model.dart';

import '../../utils/shared_preference.dart';

class SessionCheckRepository {
  Future<SessionCheckResponse> checkSessionRegistration({
    required int sessionId,
    required SessionCheckRequest request,
  }) async {
    try {
      final url = Uri.parse('http://138.68.104.206:3000/participants-session/$sessionId/join');
      final token = await SharedPrefsHelper.keyAuthToken;

      print('=== SESSION CHECK REQUEST ===');
      print('URL: $url');
      print('Body: ${jsonEncode(request.toJson())}');
      print('Token: $token');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      print('=== SESSION CHECK RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? '';

        // "User already joined this session" means registered
        final isRegistered = message.toLowerCase().contains('already joined');

        return SessionCheckResponse(
          success: true,
          message: message,
          isRegistered: isRegistered,
        );
      } else if (response.statusCode == 400) {
        // User not registered yet
        final data = jsonDecode(response.body);
        return SessionCheckResponse(
          success: true, // Request succeeded
          message: data['message'] ?? 'User not registered for this session',
          isRegistered: false,
        );
      } else if (response.statusCode == 404) {
        return SessionCheckResponse(
          success: false,
          message: 'Session or user not found',
          isRegistered: false,
        );
      } else {
        final data = jsonDecode(response.body);
        return SessionCheckResponse(
          success: false,
          message: data['message'] ?? 'Error checking registration. Status: ${response.statusCode}',
          isRegistered: false,
        );
      }
    } catch (e) {
      print('=== SESSION CHECK ERROR ===');
      print('Error: $e');

      return SessionCheckResponse(
        success: false,
        message: 'Network error: $e',
        isRegistered: false,
      );
    }
  }
}