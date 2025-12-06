class EventRegistrationToggleStatusResponse {
  final bool isRegistered;

  EventRegistrationToggleStatusResponse({
    required this.isRegistered,
  });

  factory EventRegistrationToggleStatusResponse.fromJson(Map<String, dynamic> json) {
    return EventRegistrationToggleStatusResponse(
      isRegistered: json['isRegistered'] as bool,
    );
  }
}