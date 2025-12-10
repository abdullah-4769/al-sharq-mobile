class ProfileVisibilityRequest {
  final int userId;
  final int eventId;
  final bool optedIn;

  ProfileVisibilityRequest({
    required this.userId,
    required this.eventId,
    required this.optedIn,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'eventId': eventId,
    'optedIn': optedIn,
  };
}

class ProfileVisibilityResponse {
  final int id;
  final int eventId;
  final int? sessionId;
  final int userId;
  final bool optedIn;

  ProfileVisibilityResponse({
    required this.id,
    required this.eventId,
    required this.sessionId,
    required this.userId,
    required this.optedIn,
  });

  factory ProfileVisibilityResponse.fromJson(Map<String, dynamic> json) {
    return ProfileVisibilityResponse(
      id: json['id'],
      eventId: json['eventId'],
      sessionId: json['sessionId'],
      userId: json['userId'],
      optedIn: json['optedIn'],
    );
  }
}