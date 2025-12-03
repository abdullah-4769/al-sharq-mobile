class ConnectionRequestSend {
  final int senderId;
  final int receiverId;

  ConnectionRequestSend({
    required this.senderId,
    required this.receiverId,
  });

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'receiverId': receiverId,
  };
}

class ConnectionRequestResponse {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final DateTime createdAt;

  ConnectionRequestResponse({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  factory ConnectionRequestResponse.fromJson(Map<String, dynamic> json) {
    return ConnectionRequestResponse(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}