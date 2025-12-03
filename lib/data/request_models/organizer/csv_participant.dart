// Model for CSV Participant Data
class CsvParticipant {
  final String name;
  final String email;
  final String phone;
  final String role;
  bool invitationSent;
  String? statusMessage;

  CsvParticipant({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.invitationSent = false,
    this.statusMessage,
  });

  factory CsvParticipant.fromCsvRow(List<String> row) {
    return CsvParticipant(
      name: row.length > 0 ? row[0].trim() : '',
      email: row.length > 1 ? row[1].trim() : '',
      phone: row.length > 2 ? row[2].trim() : '',
      role: row.length > 3 ? row[3].trim() : 'participant',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}

// Model for Send Email Request
class SendEmailRequest {
  final String email;
  final String name;

  SendEmailRequest({
    required this.email,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
    };
  }
}

// Model for Send Email Response
class SendEmailResponse {
  final String? messageId;
  final bool success;
  final String? error;

  SendEmailResponse({
    this.messageId,
    required this.success,
    this.error,
  });

  factory SendEmailResponse.fromJson(Map<String, dynamic> json) {
    return SendEmailResponse(
      messageId: json['messageId'] as String?,
      success: json['messageId'] != null,
      error: json['error'] as String?,
    );
  }
}