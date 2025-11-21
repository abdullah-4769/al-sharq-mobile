import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OrganizerEventDeleteRepo {
  static const String baseUrl = 'http://138.68.104.206:3000';
  final _storage = GetStorage();

  Future<bool> deleteEvent(int eventId) async {
    try {
      final token = _storage.read('token') ?? '';

      print('🗑️ Sending delete request for event ID: $eventId');

      final response = await http.delete(
        Uri.parse('$baseUrl/event/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Delete response status: ${response.statusCode}');
      print('📥 Delete response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // If the API returns the deleted event object, consider it successful
        print('✅ Event deleted successfully - ID: $eventId');
        return true;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to delete event: ${errorBody['message'] ?? response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }
}