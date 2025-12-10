class ParticipantSessionRegistrationRequest {
  final int userId;
  final int eventId;
  final int sessionId;
  final String whyJoin;
  final String relevantExperience;

  ParticipantSessionRegistrationRequest({
    required this.userId,
    required this.eventId,
    required this.sessionId,
    required this.whyJoin,
    required this.relevantExperience,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'eventId': eventId,
      'sessionId': sessionId,
      'whyJoin': whyJoin,
      'relevantExperience': relevantExperience,
    };
  }
}

class ParticipantSessionRegistrationResponse {
  final bool success;
  final String message;
  final String? joinCode;
  final String? token;
  final int? remainingCapacity;

  ParticipantSessionRegistrationResponse({
    required this.success,
    required this.message,
    this.joinCode,
    this.token,
    this.remainingCapacity,
  });

  factory ParticipantSessionRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return ParticipantSessionRegistrationResponse(
      success: json['success'] ?? json['token'] != null, // If token exists, consider it successful
      message: json['message'] ?? 'Registration successful',
      joinCode: json['joinCode'],
      token: json['token'],
      remainingCapacity: json['remainingCapacity'],
    );
  }
}