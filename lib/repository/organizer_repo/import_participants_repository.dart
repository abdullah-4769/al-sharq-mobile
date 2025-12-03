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

      final response = await http.post(
        Uri.parse('$baseUrl/admin/users/send-email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

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
      return SendEmailResponse(
        success: false,
        error: 'Error sending invitation: $e',
      );
    }
  }

  Future<List<SendEmailResponse>> sendBulkInvitations(
      List<CsvParticipant> participants,
      ) async {
    List<SendEmailResponse> responses = [];

    for (var participant in participants) {
      final response = await sendInvitation(
        email: participant.email,
        name: participant.name,
      );
      responses.add(response);

      // Small delay to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 300));
    }

    return responses;
  }
}