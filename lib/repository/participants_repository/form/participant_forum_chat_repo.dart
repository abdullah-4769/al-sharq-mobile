import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../data/request_models/participant_Request_models/forms/participant_forum_chat_model.dart';

class ParticipantForumChatRepository {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<ForumDetail> getForumDetails(int forumId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/forum-comments/forum/$forumId'),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ForumDetail.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load forum details: ${response.statusCode}');
    }
  }

  Future<AddCommentResponse> addComment(AddCommentRequest comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forum-comments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(comment.toJson()),
    );

    if (response.statusCode == 201) {
      return AddCommentResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add comment: ${response.statusCode}');
    }
  }

  Future<void> deleteComment(int commentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/forum-comments/$commentId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment: ${response.statusCode}');
    }
  }
}