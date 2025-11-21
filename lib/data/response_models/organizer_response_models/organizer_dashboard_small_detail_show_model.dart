class OrganizerDashboardSmallDetailShowModel {
  final int countTotalRegistration;
  final int totalCheckin;
  final int totalActiveSession;
  final int totalSpeaker;
  final int totalSponsor;
  final int totalExhibitor;
  final List<OrganizerDashboardSmallDetailShowRecentUser> recentUsers;

  OrganizerDashboardSmallDetailShowModel({
    required this.countTotalRegistration,
    required this.totalCheckin,
    required this.totalActiveSession,
    required this.totalSpeaker,
    required this.totalSponsor,
    required this.totalExhibitor,
    required this.recentUsers,
  });

  factory OrganizerDashboardSmallDetailShowModel.fromJson(Map<String, dynamic> json) {
    return OrganizerDashboardSmallDetailShowModel(
      countTotalRegistration: json['countTotalRegistration'] ?? 0,
      totalCheckin: json['totalCheckin'] ?? 0,
      totalActiveSession: json['totalActiveSession'] ?? 0,
      totalSpeaker: json['totalSpeaker'] ?? 0,
      totalSponsor: json['totalSponsor'] ?? 0,
      totalExhibitor: json['totalExhibitor'] ?? 0,
      recentUsers: (json['recentUsers'] as List? ?? [])
          .map((user) => OrganizerDashboardSmallDetailShowRecentUser.fromJson(user))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countTotalRegistration': countTotalRegistration,
      'totalCheckin': totalCheckin,
      'totalActiveSession': totalActiveSession,
      'totalSpeaker': totalSpeaker,
      'totalSponsor': totalSponsor,
      'totalExhibitor': totalExhibitor,
      'recentUsers': recentUsers.map((user) => user.toJson()).toList(),
    };
  }
}

class OrganizerDashboardSmallDetailShowRecentUser {
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

  OrganizerDashboardSmallDetailShowRecentUser({
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

  factory OrganizerDashboardSmallDetailShowRecentUser.fromJson(Map<String, dynamic> json) {
    return OrganizerDashboardSmallDetailShowRecentUser(
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