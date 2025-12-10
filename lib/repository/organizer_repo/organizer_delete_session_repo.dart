
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrganizerDeleteSessionRepo {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<bool> deleteSession(int sessionId) async {
    try {
      print('📤 Sending delete session request for ID: $sessionId');

      final response = await http.delete(
        Uri.parse('$baseUrl/sessions/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200  || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final message = responseData['message'] ?? '';
        print('✅ Session deleted successfully: $message');
        return true;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to delete session: ${errorBody['message'] ?? response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on TimeoutException catch (e) {
      throw Exception('Request timeout: $e');
    } catch (e) {
      throw Exception('Failed to delete session: $e');
    }
  }
}