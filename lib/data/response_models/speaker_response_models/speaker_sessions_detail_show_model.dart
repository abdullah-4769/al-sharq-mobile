import 'package:flutter/material.dart';
class SpeakerSessionsDetailShowResponse {
  final int total;
  final int ongoing;
  final int scheduled;
  final List<SpeakerSessionModel> sessions;

  SpeakerSessionsDetailShowResponse({
    required this.total,
    required this.ongoing,
    required this.scheduled,
    required this.sessions,
  });

  factory SpeakerSessionsDetailShowResponse.fromJson(Map<String, dynamic> json) {
    return SpeakerSessionsDetailShowResponse(
      total: json['total'] ?? 0,
      ongoing: json['ongoing'] ?? 0,
      scheduled: json['scheduled'] ?? 0,
      sessions: List<SpeakerSessionModel>.from(
        (json['sessions'] ?? []).map((x) => SpeakerSessionModel.fromJson(x)),
      ),
    );
  }
}

class SpeakerSessionModel {
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
  final List<SpeakerSessionSpeaker> speakers;

  SpeakerSessionModel({
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
  });

  factory SpeakerSessionModel.fromJson(Map<String, dynamic> json) {
    return SpeakerSessionModel(
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
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      speakers: List<SpeakerSessionSpeaker>.from(
        (json['speakers'] ?? []).map((x) => SpeakerSessionSpeaker.fromJson(x)),
      ),
    );
  }

  // Helper methods
  String get formattedTime {
    try {
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);
      final startFormat = '${start.hour}:${start.minute.toString().padLeft(2, '0')}';
      final endFormat = '${end.hour}:${end.minute.toString().padLeft(2, '0')}';
      return '$startFormat - $endFormat';
    } catch (e) {
      return 'TBD';
    }
  }

  String get duration {
    try {
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);
      final difference = end.difference(start);
      final minutes = difference.inMinutes;
      return '$minutes minutes';
    } catch (e) {
      return 'TBD';
    }
  }

  String get displayLocation {
    return location.isEmpty ? 'Main Hall' : location;
  }

  String get status {
    final now = DateTime.now();
    final start = DateTime.parse(startTime);
    final end = DateTime.parse(endTime);

    if (now.isBefore(start)) {
      return 'Upcoming';
    } else if (now.isAfter(start) && now.isBefore(end)) {
      return 'Ongoing';
    } else {
      return 'Completed';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'Ongoing':
        return Colors.green;
      case 'Upcoming':
        return Colors.orange;
      case 'Completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class SpeakerSessionSpeaker {
  final String name;
  final String file;

  SpeakerSessionSpeaker({
    required this.name,
    required this.file,
  });

  factory SpeakerSessionSpeaker.fromJson(Map<String, dynamic> json) {
    return SpeakerSessionSpeaker(
      name: json['name'] ?? '',
      file: json['file'] ?? '',
    );
  }
}