import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/request_models/organizer/csv_participant.dart';

class ImportParticipantsRepository {
  final String baseUrl = 'http://138.68.104.206:3000';

  Future<SendEmailResponse> sendInvitation({
    required String email,
    required String name,
  }) async {
    try {
      final request = SendEmailRequest(email: email, name: name);

      print('DEBUG: Sending invitation to $email');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/users/send-email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return SendEmailResponse.fromJson(data);
      } else {
        return SendEmailResponse(
          success: false,
          error: 'Failed to send invitation: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('DEBUG: Error in sendInvitation: $e');
      return SendEmailResponse(
        success: false,
        error: 'Error: ${e.toString()}',
      );
    }
  }
}