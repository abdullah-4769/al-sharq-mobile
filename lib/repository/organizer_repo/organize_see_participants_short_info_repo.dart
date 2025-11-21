import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:al_sharq_conference/data/response_models/organizer_response_models/organize_see_participants_short_info_model.dart';
import 'package:al_sharq_conference/utils/api_constants.dart';
import 'package:al_sharq_conference/utils/shared_preference.dart';

class OrganizeSeeParticipantsShortInfoRepo {
  final String baseUrl = ApiConstants.baseUrl;

  Future<OrganizeSeeParticipantsShortInfoModel> getParticipantsData() async {
    try {
      final authToken = await SharedPrefsHelper.getAuthToken();

      if (authToken == null || authToken.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/participants'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return OrganizeSeeParticipantsShortInfoModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden: Organizer role required');
      } else {
        throw Exception('Failed to load participants data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching participants data: $e');
    }
  }
}