// lib/data/response_models/registration_team_model/session_check_model.dart
class SessionCheckResponse {
  final bool success;
  final String message;
  final bool isRegistered;

  SessionCheckResponse({
    required this.success,
    required this.message,
    required this.isRegistered,
  });

  factory SessionCheckResponse.fromJson(Map<String, dynamic> json) {
    // Check if user already joined based on message
    final message = json['message'] ?? '';
    final isRegistered = message.toLowerCase().contains('already joined');

    return SessionCheckResponse(
      success: json['success'] ?? isRegistered,
      message: message,
      isRegistered: isRegistered,
    );
  }
}

// lib/data/request_models/registration_team_model/session_check_request.dart
class SessionCheckRequest {
  final String userId;

  SessionCheckRequest({
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
    };
  }
}