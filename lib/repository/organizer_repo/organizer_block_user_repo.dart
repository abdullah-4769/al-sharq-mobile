import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:al_sharq_conference/utils/api_constants.dart';
import 'package:al_sharq_conference/utils/shared_preference.dart';

import '../../data/request_models/organizer/organizer_block_user_model.dart';

class OrganizerBlockUserRepo {
  final String baseUrl = ApiConstants.baseUrl;

  Future<OrganizerBlockUserResponseModel> blockUser(OrganizerBlockUserRequestModel request) async {
    try {
      final authToken = await SharedPrefsHelper.getAuthToken();

      if (authToken == null || authToken.isEmpty) {
        throw Exception('Authentication token not found');
      }

      print('Block User API Call:');
      print('URL: $baseUrl/admin/users/block');
      print('Request: ${request.toJson()}');
      print('Token: ${authToken.substring(0, 20)}...');

      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/block'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(request.toJson()),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Success Response: $responseData');
        return OrganizerBlockUserResponseModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden: Organizer role required');
      } else {
        // Try to parse error message from response
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to block user: ${response.statusCode}');
        } catch (e) {
          throw Exception('Failed to block user: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('Error in blockUser repo: $e');
      throw Exception('Error blocking user: $e');
    }
  }
}