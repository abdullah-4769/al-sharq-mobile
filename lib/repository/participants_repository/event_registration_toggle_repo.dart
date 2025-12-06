
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/request_models/participant_Request_models/event_registration_toggle_model.dart';

class EventRegistrationToggleRepository {
  final String baseUrl = 'http://138.68.104.206:3000';

  Future<EventRegistrationToggleResponse> toggleRegistration({
    required int eventId,
    required int userId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/event/toggle-registration');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(EventRegistrationToggleRequest(
          eventId: eventId,
          userId: userId,
        ).toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return EventRegistrationToggleResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to toggle registration: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to toggle registration: $e');
    }
  }
}