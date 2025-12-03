import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/request_models/connection_request_send_model.dart';
import '../data/response/api_response.dart';

class ConnectionRequestSendRepository {
  static const String _baseUrl = 'http://138.68.104.206:3000';

  Future<ApiResponse<ConnectionRequestResponse>> sendConnectionRequest(
      ConnectionRequestSend request,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/connections/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = ConnectionRequestResponse.fromJson(responseBody);
        return ApiResponse<ConnectionRequestResponse>.completed(data);
      } else if (response.statusCode == 400) {
        // Handle 400 Bad Request - usually "already sent" or "pending"
        final errorMessage = responseBody['message'] ?? responseBody['error'] ?? 'Bad request';
        return ApiResponse<ConnectionRequestResponse>.error(
          errorMessage,
        );
      } else if (response.statusCode == 409) {
        // Handle 409 Conflict - already connected
        final errorMessage = responseBody['message'] ?? responseBody['error'] ?? 'Already connected';
        return ApiResponse<ConnectionRequestResponse>.error(
          errorMessage,
        );
      } else {
        return ApiResponse<ConnectionRequestResponse>.error(
          'Failed to send connection request: ${response.statusCode} - ${responseBody['message'] ?? responseBody.toString()}',
        );
      }
    } catch (e) {
      return ApiResponse<ConnectionRequestResponse>.error(
        'Network error: $e',
      );
    }
  }
}