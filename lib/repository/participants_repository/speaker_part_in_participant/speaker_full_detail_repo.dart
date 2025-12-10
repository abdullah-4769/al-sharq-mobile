// lib/data/repository/participants_repository/speaker_full_detail_repo.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/response_models/participant_response_model/speaker_part_in_participant/speaker_full_detail_response_model.dart';
import '../../../utils/api_constants.dart';

class SpeakerFullDetailRepo {
  Future<SpeakerFullDetail> getSpeakerFullDetails(int speakerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = '${ApiConstants.baseUrl}/speakers/$speakerId';
      print('=== Fetching speaker full details from: $url ===');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      print('=== Speaker Full Details API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final responseData = SpeakerFullDetailResponse.fromJson(jsonResponse);

        print('=== Successfully fetched speaker: ${responseData.speaker.user.name} ===');
        return responseData.speaker;
      } else {
        throw Exception('Failed to load speaker details: ${response.statusCode}');
      }
    } catch (e) {
      print('=== Error fetching speaker full details: $e ===');
      rethrow;
    }
  }
}