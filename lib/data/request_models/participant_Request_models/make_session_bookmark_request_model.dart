// lib/data/request_models/make_session_bookmarked_request_model.dart

class MakeSessionBookmarkedRequestModel {
  final int userId;
  final int sessionId;
  final int eventId;

  MakeSessionBookmarkedRequestModel({
    required this.userId,
    required this.sessionId,
    required this.eventId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sessionId': sessionId,
      'eventId': eventId,
    };
  }

  @override
  String toString() {
    return 'MakeSessionBookmarkedRequestModel{userId: $userId, sessionId: $sessionId, eventId: $eventId}';
  }
}