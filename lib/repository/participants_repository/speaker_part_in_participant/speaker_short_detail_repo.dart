// lib/data/repository/participants_repository/speaker_short_detail_repo.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/response_models/participant_response_model/speaker_part_in_participant/speaker_short_detail_responsemodel.dart';

import '../../../utils/api_constants.dart';

class SpeakerShortDetailRepo {
  Future<List<SpeakerShortDetail>> getSpeakerShortDetails(int eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = '${ApiConstants.baseUrl}/speakers/event/$eventId/short-info';
      print('=== Fetching speaker short details from: $url ===');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      print('=== Speaker Short Details API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        final responseData = SpeakerShortDetailResponse.fromJson(jsonResponse);

        print('=== Successfully fetched ${responseData.speakers.length} speakers ===');
        return responseData.speakers;
      } else {
        throw Exception('Failed to load speaker details: ${response.statusCode}');
      }
    } catch (e) {
      print('=== Error fetching speaker details: $e ===');
      rethrow;
    }
  }
}