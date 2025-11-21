import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../data/request_models/participant_Request_models/forms/participant_form_create_model.dart';

class ParticipantFormCreateRepository {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<ParticipantFormCreateResponse> createForum(
      ParticipantFormCreateModel forumData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/session-forums'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(forumData.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 201) {
      return ParticipantFormCreateResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create forum: ${response.statusCode}');
    }
  }
}