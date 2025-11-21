import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:al_sharq_conference/utils/shared_preference.dart';
import '../../../data/response_models/participant_response_model/participant_profile/participant_profile_update_model.dart';


class ParticipantProfileUpdateRepository {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<ParticipantProfileUpdateResponse> updateProfile({
    required String name,
    required String email,
    required String organization,
    String? filePath,
  }) async {
    try {
      final userId = await SharedPrefsHelper.getUserId();
      final token = await SharedPrefsHelper.getAuthToken();

      print('DEBUG: User ID: $userId, Token: $token'); // Add debug print

      if (userId == null || token == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/auth/update/$userId'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['organization'] = organization;

      // Add file if provided
      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          filePath,
        ));
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      print('DEBUG: Update response status: ${response.statusCode}'); // Add debug print
      print('DEBUG: Update response body: $responseString'); // Add debug print

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(responseString);
        return ParticipantProfileUpdateResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to update profile: ${response.statusCode} - $responseString');
      }
    } catch (e) {
      print('DEBUG: Error in updateProfile: $e'); // Add debug print
      throw Exception('Failed to update profile: $e');
    }
  }
}