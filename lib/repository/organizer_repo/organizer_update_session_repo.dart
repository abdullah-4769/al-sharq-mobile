import 'dart:async';
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../data/response_models/organizer_response_models/organizer_create_session_model.dart';

class OrganizerUpdateSessionRepo {
  static const String baseUrl = 'http://138.68.104.206:3000';
  final _storage = GetStorage();

  Future<OrganizerCreateSessionModel> updateSession(int sessionId, Map<String, dynamic> data) async {
    try {
      final token = _storage.read('token') ?? '';

      print('📤 Sending update session request for ID: $sessionId');
      print('📤 Update data: $data');

      final response = await http.patch(
        Uri.parse('$baseUrl/sessions/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      ).timeout(Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return OrganizerCreateSessionModel.fromJson(responseData);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to update session: ${errorBody['message'] ?? response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException catch (e) {
      throw Exception('Request timeout: $e');
    } catch (e) {
      throw Exception('Failed to update session: $e');
    }
  }
}