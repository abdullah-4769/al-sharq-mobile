import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/request_models/participant_Request_models/participant_session_registration_and_join_requestmodels/participant_session_registration_request_model.dart';

class ParticipantSessionRegistrationRepository {
  final String baseUrl = 'http://138.68.104.206:3000';

  Future<ParticipantSessionRegistrationResponse> registerForSession({
    required int userId,
    required int eventId,
    required int sessionId,
    required String whyJoin,
    required String relevantExperience,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = '$baseUrl/participants-session/registration';
      print('=== Registering for session - URL: $url ===');
      print('=== Request Body - userId: $userId, eventId: $eventId, sessionId: $sessionId ===');

      final request = ParticipantSessionRegistrationRequest(
        userId: userId,
        eventId: eventId,
        sessionId: sessionId,
        whyJoin: whyJoin,
        relevantExperience: relevantExperience,
      );

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('=== Registration API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final registrationResponse = ParticipantSessionRegistrationResponse.fromJson(jsonResponse);

        // Debug the response
        print('=== Registration parsed - success: ${registrationResponse.success}, token: ${registrationResponse.token}, joinCode: ${registrationResponse.joinCode} ===');

        return registrationResponse;
      } else {
        throw Exception('Failed to register for session: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('=== Error registering for session: $e ===');
      rethrow;
    }
  }
}