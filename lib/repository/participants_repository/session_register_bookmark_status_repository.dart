// lib/data/repository/session_register_bookmark_status_repo.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/response_models/participant_response_model/session_register_bookmark_status_model.dart';

class SessionRegisterBookmarkStatusRepo {
  final String baseUrl = 'http://138.68.104.206:3000';

  Future<SessionRegisterBookmarkStatusModel> getSessionStatus({
    required int sessionId,
    required int userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = '$baseUrl/sessions/$sessionId/user-status/$userId';
      print('=== Fetching session status from: $url ===');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('=== Session Status API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return SessionRegisterBookmarkStatusModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load session status: ${response.statusCode}');
      }
    } catch (e) {
      print('=== Error fetching session status: $e ===');
      rethrow;
    }
  }
}