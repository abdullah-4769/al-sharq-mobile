// lib/data/repository/make_session_bookmarked_repo.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/request_models/participant_Request_models/make_session_bookmark_request_model.dart';
import '../../data/response_models/participant_response_model/make_session_bookmark_responsemodel.dart';

import '../../utils/api_constants.dart';

class MakeSessionBookmarkedRepo {
  Future<MakeSessionBookmarkedResponseModel> bookmarkSession({
    required int userId,
    required int sessionId,
    required int eventId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = '${ApiConstants.baseUrl}${ApiConstants.bookmarkSession}';
      print('=== Bookmarking session: $url ===');

      final request = MakeSessionBookmarkedRequestModel(
        userId: userId,
        sessionId: sessionId,
        eventId: eventId,
      );

      print('=== Bookmark request data: ${request.toJson()} ===');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 10));

      print('=== Bookmark API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return MakeSessionBookmarkedResponseModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to bookmark session: ${response.statusCode}');
      }
    } catch (e) {
      print('=== Error bookmarking session: $e ===');
      rethrow;
    }
  }
}