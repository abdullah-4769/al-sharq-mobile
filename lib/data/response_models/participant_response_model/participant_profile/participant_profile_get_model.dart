import '../../login_response_model.dart';

class ParticipantProfileGetModel {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final String? file;
  final String role;
  final String organization;
  final String? photo;
  final String? bio; // Added bio field
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  ParticipantProfileGetModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.file,
    required this.role,
    required this.organization,
    this.photo,
    this.bio, // Added bio field
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParticipantProfileGetModel.fromJson(Map<String, dynamic> json) {
    return ParticipantProfileGetModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      file: json['file'],
      role: json['role'] ?? 'participant',
      organization: json['organization'] ?? '',
      photo: json['photo'],
      bio: json['bio'], // Added bio field
      isBlocked: json['isBlocked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'file': file,
      'role': role,
      'organization': organization,
      'photo': photo,
      'bio': bio, // Added bio field
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
// You can now remove ParticipantProfileGetModel and use UserModel instead
class ParticipantProfileGetResponse {
  final UserModel user;

  ParticipantProfileGetResponse({required this.user});

  factory ParticipantProfileGetResponse.fromJson(Map<String, dynamic> json) {
    return ParticipantProfileGetResponse(
      user: UserModel.fromJson(json),
    );
  }
}