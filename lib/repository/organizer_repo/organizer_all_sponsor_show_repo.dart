import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:al_sharq_conference/data/response_models/organizer_response_models/organizer_all_sponsor_show_model.dart';
import 'package:al_sharq_conference/utils/api_constants.dart';
import 'package:al_sharq_conference/utils/shared_preference.dart';

class OrganizerAllSponsorShowRepo {
  final String baseUrl = ApiConstants.baseUrl;

  Future<OrganizerAllSponsorShowModel> getSponsors() async {
    try {
      final authToken = await SharedPrefsHelper.getAuthToken();

      if (authToken == null || authToken.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/sponsors'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201 ) {
        final List<dynamic> responseData = json.decode(response.body);
        return OrganizerAllSponsorShowModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden: Organizer role required');
      } else {
        throw Exception('Failed to load sponsors: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sponsors: $e');
    }
  }
}