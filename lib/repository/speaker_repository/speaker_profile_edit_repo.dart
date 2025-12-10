import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/request_models/speaker_request_models/speaker_profile_edit_model.dart';
import '../../data/response_models/speaker_response_models/speaker_profile_show_on_dashboard_model.dart';
import '../../utils/api_constants.dart';

class SpeakerProfileEditRepo {
  final String baseUrl = ApiConstants.baseUrl;

  Future<SpeakerProfileShowOnDashboardModel> updateSpeakerProfile({
    required int speakerId,
    required SpeakerProfileEditRequestModel data,
    required String authToken, // Add auth token parameter
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/speakers/$speakerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken', // Add authorization header
        },
        body: json.encode(data.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return SpeakerProfileShowOnDashboardModel.fromJson(responseData);
      } else if (response.statusCode == 404) {
        throw Exception('Speaker profile not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error: Failed to update speaker profile');
      } else {
        throw Exception('Failed to update speaker profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating speaker profile: $e');
    }
  }
}