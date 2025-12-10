class SessionDetailShowResponseModel {
  final int id;
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String location;
  final String category;
  final int capacity;
  final List<String> tags;
  final int eventId;
  final String joinToken;
  final bool registrationRequired;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final List<SessionDetailShowSpeakerModel> speakers;
  final SessionDetailShowEventModel event;
  final List<dynamic> registeredUsers;
  final int registrationCount;

  SessionDetailShowResponseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.category,
    required this.capacity,
    required this.tags,
    required this.eventId,
    required this.joinToken,
    required this.registrationRequired,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.speakers,
    required this.event,
    required this.registeredUsers,
    required this.registrationCount,
  });

  factory SessionDetailShowResponseModel.fromJson(Map<String, dynamic> json) {
    return SessionDetailShowResponseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      capacity: json['capacity'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      eventId: json['eventId'] ?? 0,
      joinToken: json['joinToken'] ?? '',
      registrationRequired: json['registrationRequired'] ?? false,
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      speakers: (json['speakers'] as List? ?? [])
          .map((speaker) => SessionDetailShowSpeakerModel.fromJson(speaker))
          .toList(),
      event: SessionDetailShowEventModel.fromJson(json['event'] ?? {}),
      registeredUsers: json['registeredUsers'] ?? [],
      registrationCount: json['registrationCount'] ?? 0,
    );
  }
}

class SessionDetailShowSpeakerModel {
  final int id;
  final int userId;
  final List<String> designations;
  final String bio;
  final List<String> expertise;
  final List<String> tags;
  final String? category;
  final String country;
  final String website;
  final String? youtube;
  final String facebook;
  final String linkedin;
  final String? twitter;
  final bool featured;
  final bool verified;
  final int priority;
  final String createdAt;
  final String updatedAt;
  final bool isActive;
  final SessionDetailShowSpeakerUserModel user;

  SessionDetailShowSpeakerModel({
    required this.id,
    required this.userId,
    required this.designations,
    required this.bio,
    required this.expertise,
    required this.tags,
    this.category,
    required this.country,
    required this.website,
    this.youtube,
    required this.facebook,
    required this.linkedin,
    this.twitter,
    required this.featured,
    required this.verified,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.user,
  });

  factory SessionDetailShowSpeakerModel.fromJson(Map<String, dynamic> json) {
    return SessionDetailShowSpeakerModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      designations: List<String>.from(json['designations'] ?? []),
      bio: json['bio'] ?? '',
      expertise: List<String>.from(json['expertise'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'],
      country: json['country'] ?? '',
      website: json['website'] ?? '',
      youtube: json['youtube'],
      facebook: json['facebook'] ?? '',
      linkedin: json['linkedin'] ?? '',
      twitter: json['twitter'],
      featured: json['featured'] ?? false,
      verified: json['verified'] ?? false,
      priority: json['priority'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isActive: json['isActive'] ?? false,
      user: SessionDetailShowSpeakerUserModel.fromJson(json['user'] ?? {}),
    );
  }
}

class SessionDetailShowSpeakerUserModel {
  final int id;
  final String email;
  final String password;
  final String name;
  final String? phone;
  final String? file;
  final String role;
  final String? organization;
  final String? photo;
  final bool isBlocked;
  final String createdAt;
  final String updatedAt;

  SessionDetailShowSpeakerUserModel({
    required this.id,
    required this.email,
    required this.password,
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

  factory SessionDetailShowSpeakerUserModel.fromJson(Map<String, dynamic> json) {
    return SessionDetailShowSpeakerUserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      file: json['file'],
      role: json['role'] ?? '',
      organization: json['organization'],
      photo: json['photo'],
      isBlocked: json['isBlocked'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class SessionDetailShowEventModel {
  final int id;
  final String title;
  final String description;
  final String? startTime;
  final String? endTime;
  final String location;
  final String googleMapLink;
  final String joinToken;
  final bool mapstatus;
  final String createdAt;
  final String updatedAt;

  SessionDetailShowEventModel({
    required this.id,
    required this.title,
    required this.description,
    this.startTime,
    this.endTime,
    required this.location,
    required this.googleMapLink,
    required this.joinToken,
    required this.mapstatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SessionDetailShowEventModel.fromJson(Map<String, dynamic> json) {
    return SessionDetailShowEventModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: json['startTime'],
      endTime: json['endTime'],
      location: json['location'] ?? '',
      googleMapLink: json['googleMapLink'] ?? '',
      joinToken: json['joinToken'] ?? '',
      mapstatus: json['mapstatus'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}