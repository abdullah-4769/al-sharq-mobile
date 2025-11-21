class OrganizerEventDeleteModel {
  final bool success;
  final String message;

  OrganizerEventDeleteModel({
    required this.success,
    required this.message,
  });

  factory OrganizerEventDeleteModel.fromJson(Map<String, dynamic> json) {
    return OrganizerEventDeleteModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}