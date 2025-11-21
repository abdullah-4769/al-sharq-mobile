// lib/data/response_models/participant_response_model/participant_connected_users_model.dart

class ParticipantConnectedUsersModel {
  final int connectionId;
  final ConnectedUser user;
  final String connectedAt;
  final int unreadMessages;

  ParticipantConnectedUsersModel({
    required this.connectionId,
    required this.user,
    required this.connectedAt,
    required this.unreadMessages,
  });

  factory ParticipantConnectedUsersModel.fromJson(Map<String, dynamic> json) {
    return ParticipantConnectedUsersModel(
      connectionId: json['connectionId'] ?? 0,
      user: ConnectedUser.fromJson(json['user'] ?? {}),
      connectedAt: json['connectedAt'] ?? '',
      unreadMessages: json['unreadMessages'] ?? 0,
    );
  }
}
class ConnectedUser {
  final int id;
  final String name;
  final String email;
  final String? file;

  ConnectedUser({
    required this.id,
    required this.name,
    required this.email,
    this.file,
  });

  factory ConnectedUser.fromJson(Map<String, dynamic> json) {
    return ConnectedUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
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