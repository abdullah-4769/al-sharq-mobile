class SpeakerProfileShowOnDashboardModel {
  final int id;
  final int userId;
  final List<String> designations;
  final String bio;
  final List<String> expertise;
  final List<String> tags;
  final String? category;
  final String country;
  final String? website;
  final String? youtube;
  final String? facebook;
  final String? linkedin;
  final String? twitter;
  final bool featured;
  final bool verified;
  final int priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final SpeakerProfileUser user;

  SpeakerProfileShowOnDashboardModel({
    required this.id,
    required this.userId,
    required this.designations,
    required this.bio,
    required this.expertise,
    required this.tags,
    this.category,
    required this.country,
    this.website,
    this.youtube,
    this.facebook,
    this.linkedin,
    this.twitter,
    required this.featured,
    required this.verified,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.user,
  });

  factory SpeakerProfileShowOnDashboardModel.fromJson(Map<String, dynamic> json) {
    return SpeakerProfileShowOnDashboardModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      designations: List<String>.from(json['designations'] ?? []),
      bio: json['bio'] ?? '',
      expertise: List<String>.from(json['expertise'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
      country: json['country'] ?? '',
      website: json['website'],
      youtube: json['youtube'],
      facebook: json['facebook'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
      featured: json['featured'] ?? false,
      verified: json['verified'] ?? false,
      priority: json['priority'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
      user: SpeakerProfileUser.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'designations': designations,
      'bio': bio,
      'expertise': expertise,
      'tags': tags,
      'category': category,
      'country': country,
      'website': website,
      'youtube': youtube,
      'facebook': facebook,
      'linkedin': linkedin,
      'twitter': twitter,
      'featured': featured,
      'verified': verified,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'user': user.toJson(),
    };
  }
}

class SpeakerProfileUser {
  final String name;
  final String email;
  final String? phone;
  final String? file;

  SpeakerProfileUser({
    required this.name,
    required this.email,
    this.phone,
    this.file,
  });

  factory SpeakerProfileUser.fromJson(Map<String, dynamic> json) {
    return SpeakerProfileUser(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      file: json['file'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'file': file,
    };
  }
}