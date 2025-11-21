import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:al_sharq_conference/data/response_models/organizer_response_models/organizer_sponsor_detail_model.dart';
import 'package:al_sharq_conference/utils/api_constants.dart';
import 'package:al_sharq_conference/utils/shared_preference.dart';

class OrganizerSponsorDetailRepo {
  final String baseUrl = ApiConstants.baseUrl;

  Future<OrganizerSponsorDetailModel> getSponsorDetail(int sponsorId) async {
    try {
      final authToken = await SharedPrefsHelper.getAuthToken();

      if (authToken == null || authToken.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/sponsors/$sponsorId/details'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return OrganizerSponsorDetailModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden: Organizer role required');
      } else if (response.statusCode == 404) {
        throw Exception('Sponsor not found');
      } else {
        throw Exception('Failed to load sponsor details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sponsor details: $e');
    }
  }
}