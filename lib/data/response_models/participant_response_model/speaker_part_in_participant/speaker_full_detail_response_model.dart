// lib/data/response_models/participant_response_model/speaker_part_in_participant/speaker_full_detail_responsemodel.dart

class SpeakerFullDetailResponse {
  final SpeakerFullDetail speaker;

  SpeakerFullDetailResponse({
    required this.speaker,
  });

  factory SpeakerFullDetailResponse.fromJson(Map<String, dynamic> json) {
    return SpeakerFullDetailResponse(
      speaker: SpeakerFullDetail.fromJson(json),
    );
  }
}

class SpeakerFullDetail {
  final int id;
  final int userId;
  final List<String> designations;
  final String bio;
  final List<String> expertise;
  final List<String> tags;
  final String? category;
  final String? country;
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
  final SpeakerFullDetailUser user;

  SpeakerFullDetail({
    required this.id,
    required this.userId,
    required this.designations,
    required this.bio,
    required this.expertise,
    required this.tags,
    this.category,
    this.country,
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

  factory SpeakerFullDetail.fromJson(Map<String, dynamic> json) {
    return SpeakerFullDetail(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      designations: List<String>.from(json['designations'] ?? []),
      bio: json['bio'] ?? '',
      expertise: List<String>.from(json['expertise'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
      country: json['country'],
      website: json['website'],
      youtube: json['youtube'],
      facebook: json['facebook'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
      featured: json['featured'] ?? false,
      verified: json['verified'] ?? false,
      priority: json['priority'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      isActive: json['isActive'] ?? true,
      user: SpeakerFullDetailUser.fromJson(json['user'] ?? {}),
    );
  }

  // Helper methods
  bool get hasSocialMedia => website != null || youtube != null ||
      facebook != null || linkedin != null || twitter != null;

  String get primaryDesignation => designations.isNotEmpty ? designations.first : '';

  List<String> get remainingDesignations => designations.length > 1
      ? designations.sublist(1)
      : [];
}

class SpeakerFullDetailUser {
  final String name;
  final String email;
  final String? phone;
  final String? file;

  SpeakerFullDetailUser({
    required this.name,
    required this.email,
    this.phone,
    this.file,
  });

  factory SpeakerFullDetailUser.fromJson(Map<String, dynamic> json) {
    return SpeakerFullDetailUser(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      file: json['file'],
    );
  }
}