import 'dart:convert';
import 'package:http/http.dart' as http;

class ForumsListRepository {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<ForumsData> getForumsBySession(int sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/session-forums/session/$sessionId'),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ForumsData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load forums: ${response.statusCode}');
    }
  }
}

class ForumsData {
  final int id;
  final String title;
  final List<String> tags;
  final List<Forum> forums;

  ForumsData({
    required this.id,
    required this.title,
    required this.tags,
    required this.forums,
  });

  factory ForumsData.fromJson(Map<String, dynamic> json) {
    return ForumsData(
      id: json['id'],
      title: json['title'],
      tags: List<String>.from(json['tags']),
      forums: List<Forum>.from(json['forums'].map((x) => Forum.fromJson(x))),
    );
  }
}

class Forum {
  final int forumId;
  final String title;
  final String content;
  final String status;
  final String tag;
  final int totalComments;
  final int totalUsers;
  final Creator creator;

  Forum({
    required this.forumId,
    required this.title,
    required this.content,
    required this.status,
    required this.tag,
    required this.totalComments,
    required this.totalUsers,
    required this.creator,
  });

  factory Forum.fromJson(Map<String, dynamic> json) {
    return Forum(
      forumId: json['forumId'],
      title: json['title'],
      content: json['content'],
      status: json['status'],
      tag: json['tag'],
      totalComments: json['totalComments'],
      totalUsers: json['totalUsers'],
      creator: Creator.fromJson(json['creator']),
    );
  }
}

class Creator {
  final int id;
  final String name;
  final String file;

  Creator({
    required this.id,
    required this.name,
    required this.file,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'],
      name: json['name'],
      file: json['file'],
    );
  }
}