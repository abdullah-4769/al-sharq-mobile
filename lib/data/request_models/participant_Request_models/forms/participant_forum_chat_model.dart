class ForumDetail {
  final int id;
  final int sessionId;
  final User user;
  final String title;
  final String content;
  final String tag;
  final int totalUsers;
  final int totalComments;
  final List<Comment> comments;

  ForumDetail({
    required this.id,
    required this.sessionId,
    required this.user,
    required this.title,
    required this.content,
    required this.tag,
    required this.totalUsers,
    required this.totalComments,
    required this.comments,
  });

  factory ForumDetail.fromJson(Map<String, dynamic> json) {
    return ForumDetail(
      id: json['id'],
      sessionId: json['sessionId'],
      user: User.fromJson(json['user']),
      title: json['title'],
      content: json['content'],
      tag: json['tag'],
      totalUsers: json['totalUsers'],
      totalComments: json['totalComments'],
      comments: List<Comment>.from(json['comments'].map((x) => Comment.fromJson(x))),
    );
  }
}

class Comment {
  final int id;
  final int forumId;
  final int userId;
  final String content;
  final int? parentCommentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.forumId,
    required this.userId,
    required this.content,
    this.parentCommentId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      forumId: json['forumId'],
      userId: json['userId'],
      content: json['content'],
      parentCommentId: json['parentCommentId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: User.fromJson(json['user']),
      replies: json['replies'] != null
          ? List<Comment>.from(json['replies'].map((x) => Comment.fromJson(x)))
          : [],
    );
  }
}

class User {
  final int id;
  final String name;
  final String role;
  final String file;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.file,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      file: json['file'],
    );
  }
}

class AddCommentRequest {
  final int forumId;
  final int userId;
  final String content;
  final int? parentCommentId;

  AddCommentRequest({
    required this.forumId,
    required this.userId,
    required this.content,
    this.parentCommentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'forumId': forumId,
      'userId': userId,
      'content': content,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
    };
  }
}

class AddCommentResponse {
  final int id;
  final int forumId;
  final int userId;
  final String content;
  final int? parentCommentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddCommentResponse({
    required this.id,
    required this.forumId,
    required this.userId,
    required this.content,
    this.parentCommentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddCommentResponse.fromJson(Map<String, dynamic> json) {
    return AddCommentResponse(
      id: json['id'],
      forumId: json['forumId'],
      userId: json['userId'],
      content: json['content'],
      parentCommentId: json['parentCommentId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}