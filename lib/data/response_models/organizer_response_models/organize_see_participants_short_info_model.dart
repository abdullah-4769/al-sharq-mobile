class OrganizeSeeParticipantsShortInfoModel {
  final int totalParticipants;
  final int totalBookmarks;
  final int totalSessionRegistrations;
  final List<OrganizeSeeParticipantsShortInfoUser> users;

  OrganizeSeeParticipantsShortInfoModel({
    required this.totalParticipants,
    required this.totalBookmarks,
    required this.totalSessionRegistrations,
    required this.users,
  });

  factory OrganizeSeeParticipantsShortInfoModel.fromJson(Map<String, dynamic> json) {
    return OrganizeSeeParticipantsShortInfoModel(
      totalParticipants: json['totalParticipants'] ?? 0,
      totalBookmarks: json['totalBookmarks'] ?? 0,
      totalSessionRegistrations: json['totalSessionRegistrations'] ?? 0,
      users: (json['users'] as List? ?? [])
          .map((user) => OrganizeSeeParticipantsShortInfoUser.fromJson(user))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalParticipants': totalParticipants,
      'totalBookmarks': totalBookmarks,
      'totalSessionRegistrations': totalSessionRegistrations,
      'users': users.map((user) => user.toJson()).toList(),
    };
  }
}

class OrganizeSeeParticipantsShortInfoUser {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final String? file;
  final String role;
  final String? organization;
  final String? photo;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrganizeSeeParticipantsShortInfoUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.file,
    required this.role,
    this.organization,
    this.photo,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganizeSeeParticipantsShortInfoUser.fromJson(Map<String, dynamic> json) {
    return OrganizeSeeParticipantsShortInfoUser(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      file: json['file'],
      role: json['role'] ?? '',
      organization: json['organization'],
      photo: json['photo'],
      isBlocked: json['isBlocked'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
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
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}