import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/request_models/profile_visibility_model.dart';
import '../data/response/api_response.dart';

class ProfileVisibilityRepository {
  static const String _baseUrl = 'http://138.68.104.206:3000';

  Future<ApiResponse<ProfileVisibilityResponse>> updateProfileVisibility(
      ProfileVisibilityRequest request,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/participant-directory-opt-in-out'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final data = ProfileVisibilityResponse.fromJson(jsonResponse);
        return ApiResponse<ProfileVisibilityResponse>.completed(data);
      } else {
        return ApiResponse<ProfileVisibilityResponse>.error(
          'Failed to update profile visibility: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<ProfileVisibilityResponse>.error(
        'Network error: $e',
      );
    }
  }

  Future<ApiResponse<ProfileVisibilityResponse>> getProfileVisibilityStatus(
      int userId,
      int eventId,
      ) async {
    try {
      // Note: You might need to adjust this endpoint based on your API
      final response = await http.get(
        Uri.parse('$_baseUrl/participant-directory-opt-in-out?userId=$userId&eventId=$eventId'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final data = ProfileVisibilityResponse.fromJson(jsonResponse);
        return ApiResponse<ProfileVisibilityResponse>.completed(data);
      } else if (response.statusCode == 404) {
        // No preference set yet, return default optedIn as false
        final data = ProfileVisibilityResponse(
          id: 0,
          eventId: eventId,
          sessionId: null,
          userId: userId,
          optedIn: false,
        );
        return ApiResponse<ProfileVisibilityResponse>.completed(data);
      } else {
        return ApiResponse<ProfileVisibilityResponse>.error(
          'Failed to fetch profile visibility status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<ProfileVisibilityResponse>.error(
        'Network error: $e',
      );
    }
  }
}