class SponsorRepresentative {
  final int id;
  final int sponsorId;
  final int userId;
  final String displayTitle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final RepresentativeUser user;

  SponsorRepresentative({
    required this.id,
    required this.sponsorId,
    required this.userId,
    required this.displayTitle,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory SponsorRepresentative.fromJson(Map<String, dynamic> json) {
    return SponsorRepresentative(
      id: json['id'],
      sponsorId: json['sponsorId'],
      userId: json['userId'],
      displayTitle: json['displayTitle'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: RepresentativeUser.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sponsorId': sponsorId,
      'userId': userId,
      'displayTitle': displayTitle,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}

class RepresentativeUser {
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

  RepresentativeUser({
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

  factory RepresentativeUser.fromJson(Map<String, dynamic> json) {
    return RepresentativeUser(
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

class SponsorRepresentativeCreate {
  final int sponsorId;
  final int userId;
  final String displayTitle;

  SponsorRepresentativeCreate({
    required this.sponsorId,
    required this.userId,
    required this.displayTitle,
  });

  Map<String, dynamic> toJson() {
    return {
      'sponsorId': sponsorId,
      'userId': userId,
      'displayTitle': displayTitle,
    };
  }
}