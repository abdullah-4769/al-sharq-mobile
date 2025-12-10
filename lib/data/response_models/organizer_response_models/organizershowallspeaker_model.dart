import 'package:flutter/material.dart';
class OrganizerShowAllSpeakerModel {
  final List<OrganizerSpeaker> speakers;

  OrganizerShowAllSpeakerModel({required this.speakers});

  factory OrganizerShowAllSpeakerModel.fromJson(List<dynamic> json) {
    return OrganizerShowAllSpeakerModel(
      speakers: json.map((item) => OrganizerSpeaker.fromJson(item)).toList(),
    );
  }
}

class OrganizerSpeaker {
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
  final OrganizerSpeakerUser user;

  OrganizerSpeaker({
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

  factory OrganizerSpeaker.fromJson(Map<String, dynamic> json) {
    return OrganizerSpeaker(
      id: json['id'],
      userId: json['userId'],
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
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isActive: json['isActive'] ?? true,
      user: OrganizerSpeakerUser.fromJson(json['user']),
    );
  }

  String get primaryDesignation {
    return designations.isNotEmpty ? designations.first : 'Speaker';
  }

  String get expertiseSummary {
    if (expertise.isEmpty) return 'No expertise listed';
    return expertise.take(3).join(', ');
  }

  String get status {
    if (featured && verified) return 'Featured & Verified';
    if (featured) return 'Featured';
    if (verified) return 'Verified';
    return 'Standard';
  }

  Color get statusColor {
    if (featured && verified) return Colors.green;
    if (featured) return Colors.orange;
    if (verified) return Colors.blue;
    return Colors.grey;
  }

  String get sessionsCountText {
    // This would need to be calculated from actual session data
    // For now, we'll use a placeholder
    return '${priority} Sessions';
  }
}

class OrganizerSpeakerUser {
  final String name;
  final String email;
  final String? phone;
  final String? file;

  OrganizerSpeakerUser({
    required this.name,
    required this.email,
    this.phone,
    this.file,
  });

  factory OrganizerSpeakerUser.fromJson(Map<String, dynamic> json) {
    return OrganizerSpeakerUser(
      name: json['name'] ?? 'Unknown Speaker',
      email: json['email'] ?? '',
      phone: json['phone'],
      file: json['file'],
    );
  }

  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return 'S';
  }
}