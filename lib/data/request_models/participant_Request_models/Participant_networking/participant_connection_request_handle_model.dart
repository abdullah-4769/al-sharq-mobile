// lib/data/response_models/participant_response_model/participant_connection_request_handle_model.dart

class ParticipantConnectionRequestHandleModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String lastReadAt;

  ParticipantConnectionRequestHandleModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.lastReadAt,
  });

  factory ParticipantConnectionRequestHandleModel.fromJson(Map<String, dynamic> json) {
    return ParticipantConnectionRequestHandleModel(
      id: json['id'] ?? 0,
      senderId: json['senderId'] ?? 0,
      receiverId: json['receiverId'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      lastReadAt: json['lastReadAt'] ?? '',
    );
  }
}