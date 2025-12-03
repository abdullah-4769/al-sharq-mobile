class ParticipantResponse {
  final int totalParticipants;
  final int totalBookmarks;
  final int totalSessionRegistrations;
  final List<Participant> users;

  ParticipantResponse({
    required this.totalParticipants,
    required this.totalBookmarks,
    required this.totalSessionRegistrations,
    required this.users,
  });

  factory ParticipantResponse.fromJson(Map<String, dynamic> json) {
    return ParticipantResponse(
      totalParticipants: json['totalParticipants'] ?? 0,
      totalBookmarks: json['totalBookmarks'] ?? 0,
      totalSessionRegistrations: json['totalSessionRegistrations'] ?? 0,
      users: List<Participant>.from(
        (json['users'] as List).map((x) => Participant.fromJson(x)),
      ),
    );
  }
}

class Participant {
  final int id;
  final String email;
  final String name;
  final String? bio;
  final String? phone;
  final String? file;
  final String role;
  final String? organization;
  final String? photo;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  Participant({
    required this.id,
    required this.email,
    required this.name,
    this.bio,
    this.phone,
    this.file,
    required this.role,
    this.organization,
    this.photo,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      bio: json['bio'],
      phone: json['phone'],
      file: json['file'],
      role: json['role'] ?? 'participant',
      organization: json['organization'],
      photo: json['photo'],
      isBlocked: json['isBlocked'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'bio': bio,
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