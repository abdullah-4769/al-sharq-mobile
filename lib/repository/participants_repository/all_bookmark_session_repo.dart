// lib/data/repository/all_bookmarked_sessions_repo.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/response_models/participant_response_model/all_bookmark_sessions_responsemodel.dart';
import '../../utils/api_constants.dart';

class AllBookmarkedSessionsRepo {
  // Alternative repo implementation using only allSessions
  Future<List<BookmarkedSession>> getBookmarkedSessions({
    required int userId,
    required int eventId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = '${ApiConstants.baseUrl}/participants/bookmarked-sessions/$userId/$eventId';
      print('=== Fetching bookmarked sessions from: $url ===');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      print('=== Bookmarked Sessions API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final responseData = BookmarkedSessionsResponse.fromJson(jsonResponse);

        // Use only allSessions (you can change this to liveSessions if needed)
        final sessions = responseData.allSessions;

        print('=== Successfully fetched ${sessions.length} bookmarked sessions ===');
        return sessions;
      } else {
        throw Exception('Failed to load bookmarked sessions: ${response.statusCode}');
      }
    } catch (e) {
      print('=== Error fetching bookmarked sessions: $e ===');
      rethrow;
    }
  }
}