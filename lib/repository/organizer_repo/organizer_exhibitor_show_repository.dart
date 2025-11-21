import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/response_models/organizer_response_models/organizer_exhibitor_show_model.dart';
import '../../utils/api_constants.dart';

class OrganizerExhibitorShowRepository {
  Future<OrganizerExhibitorShowModel> fetchExhibitors() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/exhibiteros'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> responseData = json.decode(response.body);
        return OrganizerExhibitorShowModel.fromJson(responseData);
      } else {
        throw Exception('Failed to load exhibitors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load exhibitors: $e');
    }
  }
}