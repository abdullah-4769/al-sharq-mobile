import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../data/response_models/speaker_response_models/speaker_profile_show_on_dashboard_model.dart';
import '../../utils/api_constants.dart';


class SpeakerProfileShowOnDashboardRepo {
  final String baseUrl = ApiConstants.baseUrl;

  Future<SpeakerProfileShowOnDashboardModel> getSpeakerProfile(int speakerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/speakers/$speakerId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return SpeakerProfileShowOnDashboardModel.fromJson(responseData);
      } else if (response.statusCode == 404) {
        throw Exception('Speaker profile not found');
      } else {
        throw Exception('Failed to load speaker profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching speaker profile: $e');
    }
  }
}