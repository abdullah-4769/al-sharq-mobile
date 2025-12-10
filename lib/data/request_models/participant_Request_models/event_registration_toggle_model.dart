import 'dart:convert';

class EventRegistrationToggleRequest {
  final int eventId;
  final int userId;

  EventRegistrationToggleRequest({
    required this.eventId,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'userId': userId,
    };
  }
}

class EventRegistrationToggleResponse {
  final int id;
  final int eventId;
  final int userId;
  final bool isRegistered;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventRegistrationToggleResponse({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.isRegistered,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventRegistrationToggleResponse.fromJson(Map<String, dynamic> json) {
    return EventRegistrationToggleResponse(
      id: json['id'] as int,
      eventId: json['eventId'] as int,
      userId: json['userId'] as int,
      isRegistered: json['isRegistered'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}