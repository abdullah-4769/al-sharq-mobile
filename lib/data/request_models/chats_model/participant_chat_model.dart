// Add this to your participant_chat_model.dart file

class ChatConnection {
  final int connectionId;
  final ChatUser user;
  final String connectedAt;
  final int unreadMessages;

  ChatConnection({
    required this.connectionId,
    required this.user,
    required this.connectedAt,
    required this.unreadMessages,
  });

  factory ChatConnection.fromJson(Map<String, dynamic> json) {
    return ChatConnection(
      connectionId: _parseInt(json['connectionId'] ?? json['id']),
      user: ChatUser.fromJson(json['user'] ?? json['connectedUser'] ?? {}),
      connectedAt: json['connectedAt'] ?? json['createdAt'] ?? '',
      unreadMessages: _parseInt(json['unreadMessages'] ?? json['unreadCount']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class ChatUser {
  final int id;
  final String name;
  final String email;
  final String? file;
  final String role;
  final String displayImage;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    this.file,
    required this.role,
    required this.displayImage,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      file: json['file'],
      role: json['role'] ?? '',
      displayImage: json['displayImage'] ?? json['file'] ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class ChatMessage {
  final int? id;
  final String from;
  final String content;
  final String createdAt;
  final String? tempId;
  final MessageStatus status;
  final bool? isRead;

  ChatMessage({
    this.id,
    required this.from,
    required this.content,
    required this.createdAt,
    this.tempId,
    this.status = MessageStatus.sent,
    this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: _parseInt(json['id']),
      from: json['from'] ?? 'receiver',
      content: json['content'] ?? json['message'] ?? '',
      createdAt: json['createdAt'] ?? json['timestamp'] ?? DateTime.now().toIso8601String(),
      status: _getStatusFromJson(json),
      isRead: json['isRead'] ?? json['read'],
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static MessageStatus _getStatusFromJson(Map<String, dynamic> json) {
    // Check if message is read
    if (json['isRead'] == true || json['read'] == true) {
      return MessageStatus.read;
    }

    // Check status field
    final status = json['status']?.toString().toLowerCase();
    if (status == 'sending') return MessageStatus.sending;
    if (status == 'failed') return MessageStatus.failed;

    return MessageStatus.sent;
  }

  ChatMessage copyWith({
    int? id,
    String? from,
    String? content,
    String? createdAt,
    String? tempId,
    MessageStatus? status,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      from: from ?? this.from,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      tempId: tempId ?? this.tempId,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum MessageStatus {
  sending,
  sent,
  read,
  failed,
}

class MessagesResponse {
  final List<ChatMessage> messages;

  MessagesResponse({required this.messages});

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    final messages = json['messages'] as List? ?? [];
    return MessagesResponse(
      messages: messages.map((msg) {
        if (msg is Map<String, dynamic>) {
          return ChatMessage.fromJson(msg);
        } else {
          return ChatMessage(
            from: 'receiver',
            content: '',
            createdAt: DateTime.now().toIso8601String(),
          );
        }
      }).toList(),
    );
  }
}