import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/response/api_response.dart';
import '../data/response_models/seeing_opted_user_model.dart';

class SeeingOptedUserRepository {
  static const String _baseUrl = 'http://138.68.104.206:3000';

  Future<ApiResponse<List<SeeingOptedUser>>> getOptedInUsers(int eventId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/participant-directory-opt-in-out/opted-in-in-event/$eventId?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        final List<SeeingOptedUser> users = jsonResponse
            .map((userJson) => SeeingOptedUser.fromJson(userJson))
            .toList();
        return ApiResponse<List<SeeingOptedUser>>.completed(users);
      } else {
        return ApiResponse<List<SeeingOptedUser>>.error(
          'Failed to load users: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<SeeingOptedUser>>.error(
        'Network error: $e',
      );
    }
  }
}