// lib/data/response_models/participant_response_model/participant_pending_connection_show_model.dart

class ParticipantPendingConnectionShowModel {
  final int requestId;
  final PendingSender sender;
  final String sentAt;

  ParticipantPendingConnectionShowModel({
    required this.requestId,
    required this.sender,
    required this.sentAt,
  });

  factory ParticipantPendingConnectionShowModel.fromJson(Map<String, dynamic> json) {
    return ParticipantPendingConnectionShowModel(
      requestId: json['requestId'] ?? 0,
      sender: PendingSender.fromJson(json['sender'] ?? {}),
      sentAt: json['sentAt'] ?? '',
    );
  }
}

class PendingSender {
  final int id;
  final String name;
  final String role;
  final String? file;

  PendingSender({
    required this.id,
    required this.name,
    required this.role,
    this.file,
  });

  factory PendingSender.fromJson(Map<String, dynamic> json) {
    return PendingSender(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      file: json['file'],
    );
  }

  // In both ConnectedUser and PendingSender classes
  String get displayImage {
    if (file != null && file!.isNotEmpty) {
      return file!;
    }
    // Use a valid default network image URL
    return 'https://via.placeholder.com/150/cccccc/ffffff?text=User';
  }
}