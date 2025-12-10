// In OrganizerShowListExhibitorsRepo
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data/response_models/organizer_response_models/organizer_showlist_exhibitors_model.dart';

class OrganizerShowListExhibitorsRepo {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<List<OrganizerShowListExhibitorsModel>> getExhibitorsList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exhibiteros/event/short-info'), // Fixed typo: exhibiteros -> exhibitors
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData
            .map((item) => OrganizerShowListExhibitorsModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load exhibitors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load exhibitors: $e');
    }
  }
}