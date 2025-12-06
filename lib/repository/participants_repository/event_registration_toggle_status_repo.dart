import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/request_models/participant_Request_models/event_registration_toggle_status_model.dart';

class EventRegistrationToggleStatusRepository {
  final String baseUrl = 'http://138.68.104.206:3000';

  Future<EventRegistrationToggleStatusResponse> getRegistrationStatus({
    required int eventId,
    required int userId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/event/registration-status/$eventId/$userId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return EventRegistrationToggleStatusResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to get registration status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get registration status: $e');
    }
  }
}