import 'dart:convert';
import 'package:http/http.dart' as http;


import '../../data/response_models/registration_team_model/event_registration_check_model.dart';
import '../../utils/api_constants.dart';

class EventRegistrationRepository {
  final String baseUrl = ApiConstants.baseUrl;

  // Check first registration requirement
  Future<EventRegistrationCheckModel> checkFirstRegistration(
      String eventId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/event/check-first-registration/$eventId/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return EventRegistrationCheckModel.fromJson(data);
      } else if (response.statusCode == 404) {
        // Handle event not found
        return EventRegistrationCheckModel(
          required: false,
          isRegistered: false,
          message: 'Event not found',
        );
      } else {
        throw Exception('Failed to check registration: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in checkFirstRegistration: $e');
      rethrow;
    }
  }

  // Check if user is registered for a specific session
  Future<Map<String, dynamic>> checkSessionRegistration(
      int sessionId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/registration/check/$sessionId/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to check session registration: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in checkSessionRegistration: $e');
      rethrow;
    }
  }

  // Register user for an event
  Future<Map<String, dynamic>> registerForEvent(
      String eventId, String userId, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/event/register/$eventId/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register for event: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in registerForEvent: $e');
      rethrow;
    }
  }
}