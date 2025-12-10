import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/response_models/organizer_response_models/organizer_all_session_details_show_model.dart';

class OrganizerAllSessionDetailsShowRepo {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<List<OrganizerAllSessionDetailsShowModel>> getAllSessions() async {
    try {
      print('📤 Sending get all sessions request');

      final response = await http.get(
        Uri.parse('$baseUrl/sessions/all'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData
            .map((item) => OrganizerAllSessionDetailsShowModel.fromJson(item))
            .toList();
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to load sessions: ${errorBody['message'] ?? response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } catch (e) {
      throw Exception('Failed to load sessions: $e');
    }
  }
}