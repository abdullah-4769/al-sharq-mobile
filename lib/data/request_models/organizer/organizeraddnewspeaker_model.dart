class OrganizerAddNewSpeakerRequestModel {
  final int userId;
  final List<String> designations;
  final String bio;
  final List<String> expertise;
  final List<String> tags;
  final String country;
  final String? website;
  final String? facebook;
  final String? linkedin;
  final bool featured;
  final bool verified;
  final int priority;
  final bool isActive;

  OrganizerAddNewSpeakerRequestModel({
    required this.userId,
    required this.designations,
    required this.bio,
    required this.expertise,
    required this.tags,
    required this.country,
    this.website,
    this.facebook,
    this.linkedin,
    this.featured = true,
    this.verified = true,
    this.priority = 1,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'designations': designations,
      'bio': bio,
      'expertise': expertise,
      'tags': tags,
      'country': country,
      if (website != null && website!.isNotEmpty) 'website': website,
      if (facebook != null && facebook!.isNotEmpty) 'facebook': facebook,
      if (linkedin != null && linkedin!.isNotEmpty) 'linkedin': linkedin,
      'featured': featured,
      'verified': verified,
      'priority': priority,
      'isActive': isActive,
    };
  }
}

class OrganizerAddNewSpeakerResponseModel {
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
  final String createdAt;
  final String updatedAt;
  final bool isActive;

  OrganizerAddNewSpeakerResponseModel({
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
  });

  factory OrganizerAddNewSpeakerResponseModel.fromJson(Map<String, dynamic> json) {
    return OrganizerAddNewSpeakerResponseModel(
      id: json['id'],
      userId: json['userId'],
      designations: List<String>.from(json['designations']),
      bio: json['bio'],
      expertise: List<String>.from(json['expertise']),
      tags: List<String>.from(json['tags']),
      category: json['category'],
      country: json['country'],
      website: json['website'],
      youtube: json['youtube'],
      facebook: json['facebook'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
      featured: json['featured'],
      verified: json['verified'],
      priority: json['priority'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isActive: json['isActive'],
    );
  }
}