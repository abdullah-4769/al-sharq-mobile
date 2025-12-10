import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/request_models/organizer/organizer_session_details_get_model.dart';

class OrganizerSessionDetailsGetRepo {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<OrganizerSessionDetailsGetModel> getSessionDetails(int sessionId) async {
    try {
      print('📤 Sending get session details request for ID: $sessionId');

      final response = await http.get(
        Uri.parse('$baseUrl/sessions/detail/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return OrganizerSessionDetailsGetModel.fromJson(responseData);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to load session details: ${errorBody['message'] ?? response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException catch (e) {
      throw Exception('Request timeout: $e');
    } catch (e) {
      throw Exception('Failed to load session details: $e');
    }
  }
}