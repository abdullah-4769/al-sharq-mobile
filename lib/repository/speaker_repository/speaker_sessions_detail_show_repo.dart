import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/response_models/speaker_response_models/speaker_sessions_detail_show_model.dart';
import '../../utils/api_constants.dart';


class SpeakerSessionsDetailShowRepo {
  final String baseUrl = ApiConstants.baseUrl;

  Future<SpeakerSessionsDetailShowResponse> getSpeakerSessions(int speakerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessions/speaker/$speakerId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return SpeakerSessionsDetailShowResponse.fromJson(responseData);
      } else if (response.statusCode == 404) {
        throw Exception('Speaker sessions not found');
      } else {
        throw Exception('Failed to load speaker sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching speaker sessions: $e');
    }
  }
}