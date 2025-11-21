// lib/data/repository/participants_repository/session_by_speaker_repo.dart

import 'dart:convert';
import 'package:al_sharq_conference/data/response_models/participant_response_model/speaker_part_in_participant/session_byspeaker_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/api_constants.dart';

class SessionBySpeakerRepo {
  Future<List<SessionBySpeaker>> getSessionsBySpeaker(int speakerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = '${ApiConstants.baseUrl}/sessions/speaker/$speakerId';
      print('=== Fetching sessions for speaker ID: $speakerId ===');
      print('=== URL: $url ===');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      print('=== Sessions by Speaker API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final responseData = SessionBySpeakerResponse.fromJson(jsonResponse);

        print('=== Successfully fetched ${responseData.sessions.length} sessions for speaker ===');
        return responseData.sessions;
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (e) {
      print('=== Error fetching sessions by speaker: $e ===');
      rethrow;
    }
  }
}