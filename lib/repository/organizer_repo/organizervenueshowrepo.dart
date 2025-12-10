import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/response_models/organizer_response_models/organizer_venue_show_model.dart';

class OrganizerVenueShowRepo {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<OrganizerVenueShowModel> getVenueSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/event/summary/mapview'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return OrganizerVenueShowModel.fromJson(responseData);
      } else {
        throw Exception('Failed to load venue summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load venue summary: $e');
    }
  }
}