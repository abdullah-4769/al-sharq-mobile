import 'dart:convert';
import 'package:al_sharq_conference/utils/api_constants.dart';
import 'package:al_sharq_conference/utils/shared_preference.dart';
import 'package:http/http.dart' as http;
import '../../data/response_models/organizer_response_models/registration_team_response_model.dart';

class RegistrationTeamRepository {
  Future<List<RegistrationTeamMember>> getRegistrationTeam({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    try {
      final token = await SharedPrefsHelper.getAuthToken();

      print('Fetching registration team members - Page: $page, Search: "$search"');

      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // Build URI
      final uri = Uri.parse(ApiConstants.registrationTeam).replace(
        queryParameters: queryParams,
      );

      print('Request URL: ${uri.toString()}');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the JSON array directly
        final List<dynamic> jsonList = json.decode(response.body);
        final List<RegistrationTeamMember> members = jsonList
            .map((item) => RegistrationTeamMember.fromJson(item))
            .toList();

        print('Successfully parsed ${members.length} team members');
        return members;
      } else {
        throw Exception('Failed to load registration team. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in RegistrationTeamRepository.getRegistrationTeam: $e');
      rethrow;
    }
  }
}