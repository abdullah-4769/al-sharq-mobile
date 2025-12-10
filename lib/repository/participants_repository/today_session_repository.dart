// lib/repository/participants_repository/today_session_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/response_models/participant_response_model/today_session_model.dart';
import '../../utils/shared_preference.dart';

class TodaySessionRepository {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<List<TodaySessionModel>> getRegisteredSessions(int userId, int eventId) async {
    try {
      final token = await SharedPrefsHelper.getAuthToken();

      print('🔍 Fetching registered sessions for user: $userId, event: $eventId');
      print('🔑 Token: ${token?.substring(0, 20)}...');

      final url = '$baseUrl/participants-session/$userId/registered-sessions?eventId=$eventId';
      print('📡 API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📊 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        print('✅ Successfully parsed ${responseData.length} sessions');

        final sessions = responseData.map((json) {
          try {
            return TodaySessionModel.fromJson(json);
          } catch (e) {
            print('❌ Error parsing session: $e');
            print('Session data: $json');
            rethrow;
          }
        }).toList();

        print('✅ Successfully created ${sessions.length} session models');

        // Debug: Print first session details
        if (sessions.isNotEmpty) {
          final firstSession = sessions[0];
          print('📝 First Session Details:');
          print('   Title: ${firstSession.sessionTitle}');
          print('   Duration: ${firstSession.duration}');
          print('   Location: ${firstSession.location}');
          print('   Category: ${firstSession.category}');
          print('   Speakers: ${firstSession.speakers.length}');
          if (firstSession.speakers.isNotEmpty) {
            print('   First Speaker: ${firstSession.speakers[0].fullName}');
          }
        }

        return sessions;
      } else {
        throw Exception('Failed to load registered sessions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Repository Error: $e');
      throw Exception('Failed to load registered sessions: $e');
    }
  }

  Future<List<TodaySessionModel>> getAllSessions(int eventId) async {
    try {
      final token = await SharedPrefsHelper.getAuthToken();

      print('🔍 Fetching all sessions for event: $eventId');

      final url = '$baseUrl/events/$eventId/sessions';
      print('📡 API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> responseData = json.decode(response.body);
        print('✅ Successfully parsed ${responseData.length} sessions');

        return responseData.map((json) => TodaySessionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load all sessions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Repository Error: $e');
      throw Exception('Failed to load all sessions: $e');
    }
  }
}