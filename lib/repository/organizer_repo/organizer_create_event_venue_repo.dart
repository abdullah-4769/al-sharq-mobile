import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../data/request_models/organizer/organizer_create_event_venue_model.dart';

class OrganizerCreateEventVenueRepo {
  static const String baseUrl = 'http://138.68.104.206:3000';
  final _storage = GetStorage();

  Future<OrganizerCreateEventVenueModel> createEvent(Map<String, dynamic> data) async {
    try {
      final token = _storage.read('token') ?? '';

      print('📤 Sending create event request: $data');

      final response = await http.post(
        Uri.parse('$baseUrl/event'),
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
        return OrganizerCreateEventVenueModel.fromJson(responseData);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to create event: ${errorBody['message'] ?? response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    }
    // on TimeoutException catch (e) {
    //   throw Exception('Request timeout: $e');
    // }
    catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<OrganizerCreateEventVenueModel> updateEvent(int eventId, Map<String, dynamic> data) async {
    try {
      final token = _storage.read('token') ?? '';

      print('📤 Sending update event request for ID: $eventId');
      print('📤 Update data: $data');

      final response = await http.patch(
        Uri.parse('$baseUrl/event/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      ).timeout(Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return OrganizerCreateEventVenueModel.fromJson(responseData);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to update event: ${errorBody['message'] ?? response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    }
    // on TimeoutException catch (e) {
    //   throw Exception('Request timeout: $e');
    // }
    catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  Future<OrganizerCreateEventVenueModel> getEvent(int eventId) async {
    try {
      final token = _storage.read('token') ?? '';

      print('📤 Sending get event request for ID: $eventId');

      final response = await http.get(
        Uri.parse('$baseUrl/event/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return OrganizerCreateEventVenueModel.fromJson(responseData);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to get event: ${errorBody['message'] ?? response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    }
    // } on TimeoutException catch (e) {
    //   throw Exception('Request timeout: $e');
    // }
    catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }
}