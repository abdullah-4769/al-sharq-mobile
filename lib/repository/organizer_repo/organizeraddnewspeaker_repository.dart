import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/request_models/organizer/organizeraddnewspeaker_model.dart';
import '../../utils/api_constants.dart';


class OrganizerAddNewSpeakerRepository {
  Future<OrganizerAddNewSpeakerResponseModel> addNewSpeaker(
      OrganizerAddNewSpeakerRequestModel speakerData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = '${ApiConstants.baseUrl}/speakers';
      print('=== Adding new speaker to: $url ===');
      print('=== Speaker Data: ${speakerData.toJson()} ===');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(speakerData.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('=== Add Speaker API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final responseData = OrganizerAddNewSpeakerResponseModel.fromJson(jsonResponse);

        print('=== Successfully created speaker with ID: ${responseData.id} ===');
        return responseData;
      } else {
        throw Exception('Failed to create speaker: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('=== Error creating speaker: $e ===');
      rethrow;
    }
  }
}