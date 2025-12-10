class ParticipantFormCreateModel {
  final int sessionId;
  final int userId;
  final String title;
  final String content;
  final String tag;

  ParticipantFormCreateModel({
    required this.sessionId,
    required this.userId,
    required this.title,
    required this.content,
    required this.tag,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'title': title,
      'content': content,
      'tag': tag,
    };
  }
}

class ParticipantFormCreateResponse {
  final int id;
  final int sessionId;
  final int userId;
  final String title;
  final String content;
  final String tag;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParticipantFormCreateResponse({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.title,
    required this.content,
    required this.tag,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParticipantFormCreateResponse.fromJson(Map<String, dynamic> json) {
    return ParticipantFormCreateResponse(
      id: json['id'],
      sessionId: json['sessionId'],
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      tag: json['tag'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}