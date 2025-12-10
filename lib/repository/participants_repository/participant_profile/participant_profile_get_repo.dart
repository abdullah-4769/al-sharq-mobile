import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:al_sharq_conference/utils/shared_preference.dart';
import '../../../data/response_models/participant_response_model/participant_profile/participant_profile_get_model.dart';

class ParticipantProfileGetRepository {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<ParticipantProfileGetModel> getProfile() async {
    try {
      final userId = await SharedPrefsHelper.getUserId();
      final token = await SharedPrefsHelper.getAuthToken();

      print('DEBUG: User ID: $userId, Token: ${token != null ? "exists" : "null"}');

      if (userId == null || token == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('DEBUG: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('DEBUG: Response data: $responseData');

        // Validate required fields
        _validateResponseData(responseData);

        return ParticipantProfileGetModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DEBUG: Error in getProfile: $e');
      rethrow;
    }
  }
  void _validateResponseData(Map<String, dynamic> data) {
    final requiredFields = ['id', 'email', 'name', 'role', 'organization'];

    for (var field in requiredFields) {
      if (data[field] == null) {
        print('DEBUG: Warning - Required field "$field" is null in API response');
      }
    }
  }
}