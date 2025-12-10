import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/request_models/organizer/organizerdeletespeaker_model.dart';
import '../../utils/api_constants.dart';


class OrganizerDeleteSpeakerRepository {
  Future<OrganizerDeleteSpeakerResponseModel> deleteSpeaker(int speakerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = '${ApiConstants.baseUrl}/speakers/$speakerId';
      print('=== Deleting speaker from: $url ===');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      print('=== Delete Speaker API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final responseData = OrganizerDeleteSpeakerResponseModel.fromJson(jsonResponse);

        print('=== Successfully deleted speaker with ID: $speakerId ===');
        return responseData;
      } else {
        throw Exception('Failed to delete speaker: ${response.statusCode}');
      }
    } catch (e) {
      print('=== Error deleting speaker: $e ===');
      rethrow;
    }
  }
}