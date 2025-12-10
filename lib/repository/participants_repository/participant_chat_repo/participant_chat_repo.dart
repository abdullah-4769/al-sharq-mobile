import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:al_sharq_conference/utils/shared_preference.dart';

class ParticipantChatRepository {
  final String baseUrl = 'http://138.68.104.206:3000';

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SharedPrefsHelper.getAuthToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Get all connections for a user - matches: /connections/all?userId=${userId}
  Future<List<dynamic>> getConnections() async {
    try {
      final userId = await SharedPrefsHelper.getUserId();
      if (userId == null) throw Exception('User ID not found');

      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/connections/all?userId=$userId'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('=== Connections API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      } else {
        throw Exception('Failed to load connections: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('=== Error fetching connections: $e ===');
      rethrow;
    }
  }

  // Get messages between two users - matches: /chat/messages?userId=${userId}&otherUserId=${otherUserId}
  Future<Map<String, dynamic>> getMessages(int otherUserId) async {
    try {
      final userId = await SharedPrefsHelper.getUserId();
      if (userId == null) throw Exception('User ID not found');

      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat/messages?userId=$userId&otherUserId=$otherUserId'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      print('=== Messages API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load messages: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('=== Error fetching messages: $e ===');
      rethrow;
    }
  }

  // Send a message - matches: POST /chat/send
  Future<bool> sendMessage({
    required int receiverId,
    required String content,
  }) async {
    try {
      final senderId = await SharedPrefsHelper.getUserId();
      if (senderId == null) throw Exception('User ID not found');

      final headers = await _getAuthHeaders();
      final payload = {
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
      };

      print('=== Sending message: $payload ===');

      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: headers,
        body: jsonEncode(payload),
      ).timeout(Duration(seconds: 10));

      print('=== Send Message API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to send message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('=== Error sending message: $e ===');
      rethrow;
    }
  }

  // Mark messages as read
  Future<bool> markMessagesAsRead(int otherUserId) async {
    try {
      final userId = await SharedPrefsHelper.getUserId();
      if (userId == null) throw Exception('User ID not found');

      final headers = await _getAuthHeaders();
      final payload = {
        'userId': userId,
        'otherUserId': otherUserId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/chat/mark-read'),
        headers: headers,
        body: jsonEncode(payload),
      ).timeout(Duration(seconds: 10));

      print('=== Mark Read API Response: ${response.statusCode} ===');

      return response.statusCode == 200;
    } catch (e) {
      print('=== Error marking messages as read: $e ===');
      return false;
    }
  }

// Add this method to ParticipantChatRepository for debugging
  Future<void> testAllApis() async {
    try {
      final userId = await SharedPrefsHelper.getUserId();
      print('=== Testing Chat APIs for User ID: $userId ===');

      // Test connections API
      print('=== Testing Connections API ===');
      final connections = await getConnections();
      print('=== Connections Response Type: ${connections.runtimeType} ===');
      print('=== Connections Data: $connections ===');

      if (connections.isNotEmpty) {
        dynamic firstConnection = connections.first;
        int? otherUserId;

        if (firstConnection is Map<String, dynamic>) {
          if (firstConnection['user'] is Map) {
            otherUserId = firstConnection['user']?['id'];
          } else {
            otherUserId = firstConnection['id'];
          }
        }

        if (otherUserId != null) {
          // Test messages API
          print('=== Testing Messages API with otherUserId: $otherUserId ===');
          final messages = await getMessages(otherUserId);
          print('=== Messages Response Type: ${messages.runtimeType} ===');
          print('=== Messages Data: $messages ===');

          // Test send message API
          print('=== Testing Send Message API ===');
          final sendResult = await sendMessage(
            receiverId: otherUserId,
            content: 'Test message from Flutter app',
          );
          print('=== Send Message Result: $sendResult ===');
        }
      }

    } catch (e) {
      print('=== API Test Error: $e ===');
    }
  }
}