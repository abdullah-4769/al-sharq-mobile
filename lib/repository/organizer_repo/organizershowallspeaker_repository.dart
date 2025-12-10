import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/response_models/organizer_response_models/organizershowallspeaker_model.dart';
import '../../utils/api_constants.dart';

class OrganizerShowAllSpeakerRepository {
  Future<OrganizerShowAllSpeakerModel> fetchAllSpeakers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/speakers'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> responseData = json.decode(response.body);
        return OrganizerShowAllSpeakerModel.fromJson(responseData);
      } else {
        throw Exception('Failed to load speakers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load speakers: $e');
    }
  }
}