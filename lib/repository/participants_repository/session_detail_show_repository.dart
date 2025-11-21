import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/response_models/participant_response_model/session_detail_show_response_model.dart';
import '../../utils/api_constants.dart';


class SessionDetailShowRepository {
  Future<SessionDetailShowResponseModel> fetchSessionDetails(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/sessions/detail/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return SessionDetailShowResponseModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load session details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching session details: $e');
    }
  }
}