import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/response_models/organizer_response_models/organizer_all_speaker_get_model.dart';

class OrganizerAllSpeakerGetRepo {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<List<OrganizerAllSpeakerGetModel>> getAllSpeakers() async {
    try {
      print('📤 Sending get all speakers request');

      final response = await http.get(
        Uri.parse('$baseUrl/speakers/all-details'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData
            .map((item) => OrganizerAllSpeakerGetModel.fromJson(item))
            .toList();
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to load speakers: ${errorBody['message'] ?? response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException catch (e) {
      throw Exception('Request timeout: $e');
    } catch (e) {
      throw Exception('Failed to load speakers: $e');
    }
  }
}