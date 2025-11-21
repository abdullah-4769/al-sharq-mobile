import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../data/response_models/speaker_response_models/speaker_dashboard_show_model.dart';
import '../../utils/api_constants.dart';

class SpeakerDashboardShowRepo {
  final String baseUrl = ApiConstants.baseUrl;

  Future<SpeakerDashboardShowModel> getSpeakerProfile(int speakerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/speakers/$speakerId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return SpeakerDashboardShowModel.fromJson(responseData);
      } else if (response.statusCode == 404) {
        throw Exception('Speaker profile not found');
      } else {
        throw Exception('Failed to load speaker profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching speaker profile: $e');
    }
  }

  // Method to get speaker profile by user ID (if needed)
  Future<SpeakerDashboardShowModel> getSpeakerProfileByUserId(int userId) async {
    try {
      // This endpoint might need to be adjusted based on your API
      final response = await http.get(
        Uri.parse('$baseUrl/speakers/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return SpeakerDashboardShowModel.fromJson(responseData);
      } else {
        throw Exception('Failed to load speaker profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching speaker profile: $e');
    }
  }
}