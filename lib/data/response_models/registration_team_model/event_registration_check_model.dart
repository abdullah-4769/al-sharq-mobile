class EventRegistrationCheckModel {
  final bool required;
  final bool isRegistered;
  final String message;
  final String? eventId;
  final String? userId;

  EventRegistrationCheckModel({
    required this.required,
    required this.isRegistered,
    required this.message,
    this.eventId,
    this.userId,
  });

  factory EventRegistrationCheckModel.fromJson(Map<String, dynamic> json) {
    return EventRegistrationCheckModel(
      required: json['required'] ?? false,
      isRegistered: json['isRegistered'] ?? false,
      message: json['message'] ?? 'Unknown status',
      eventId: json['eventId']?.toString(),
      userId: json['userId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'required': required,
      'isRegistered': isRegistered,
      'message': message,
      'eventId': eventId,
      'userId': userId,
    };
  }

  @override
  String toString() {
    return 'EventRegistrationCheckModel(required: $required, isRegistered: $isRegistered, message: $message)';
  }
}