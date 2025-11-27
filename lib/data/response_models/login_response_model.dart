class LoginResponseModel {
  final String token;
  final UserModel user;
  final int? latestEventId; // Change to int?

  LoginResponseModel({
    required this.token,
    required this.user,
    this.latestEventId,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'],
      user: UserModel.fromJson(json['user']),
      latestEventId: json['latestEventId'] != null
          ? int.tryParse(json['latestEventId'].toString())
          : null,
    );
  }
}
// lib/data/models/user_model.dart
class UserModel {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final String? file;
  final String role;
  final String organization;
  final String? photo;
  final String? bio;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? speakerId; // From login response

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.file,
    required this.role,
    required this.organization,
    this.photo,
    this.bio,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
    this.speakerId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      file: json['file'],
      role: json['role'] ?? 'participant',
      organization: json['organization'] ?? '',
      photo: json['photo'],
      bio: json['bio'],
      isBlocked: json['isBlocked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      speakerId: json['speakerId'],
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
      'bio': bio,
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'speakerId': speakerId,
    };
  }

  // Helper method to update specific fields
  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    String? phone,
    String? file,
    String? role,
    String? organization,
    String? photo,
    String? bio,
    bool? isBlocked,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? speakerId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      file: file ?? this.file,
      role: role ?? this.role,
      organization: organization ?? this.organization,
      photo: photo ?? this.photo,
      bio: bio ?? this.bio,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      speakerId: speakerId ?? this.speakerId,
    );
  }
}