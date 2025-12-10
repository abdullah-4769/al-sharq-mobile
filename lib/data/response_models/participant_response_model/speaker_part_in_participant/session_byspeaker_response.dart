// lib/data/response_models/participant_response_model/speaker_part_in_participant/session_by_speaker_responsemodel.dart

class SessionBySpeakerResponse {
  final int total;
  final int ongoing;
  final int scheduled;
  final List<SessionBySpeaker> sessions;

  SessionBySpeakerResponse({
    required this.total,
    required this.ongoing,
    required this.scheduled,
    required this.sessions,
  });

  factory SessionBySpeakerResponse.fromJson(Map<String, dynamic> json) {
    return SessionBySpeakerResponse(
      total: json['total'] ?? 0,
      ongoing: json['ongoing'] ?? 0,
      scheduled: json['scheduled'] ?? 0,
      sessions: (json['sessions'] as List? ?? [])
          .map((session) => SessionBySpeaker.fromJson(session))
          .toList(),
    );
  }
}

class SessionBySpeaker {
  final int id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String category;
  final int capacity;
  final List<String> tags;
  final int eventId;
  final String joinToken;
  final bool registrationRequired;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SessionSpeaker> speakers;

  SessionBySpeaker({
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

  factory SessionBySpeaker.fromJson(Map<String, dynamic> json) {
    return SessionBySpeaker(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toString()),
      endTime: DateTime.parse(json['endTime'] ?? DateTime.now().toString()),
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      capacity: json['capacity'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      eventId: json['eventId'] ?? 0,
      joinToken: json['joinToken'] ?? '',
      registrationRequired: json['registrationRequired'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      speakers: (json['speakers'] as List? ?? [])
          .map((speaker) => SessionSpeaker.fromJson(speaker))
          .toList(),
    );
  }

  // Helper methods
  String get formattedTime {
    final start = startTime.toLocal();
    final end = endTime.toLocal();
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final start = startTime.toLocal();
    return '${start.day}/${start.month}/${start.year}';
  }

  String get duration {
    final difference = endTime.difference(startTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String get speakerNames {
    if (speakers.isEmpty) return 'Speaker TBA';
    return speakers.map((speaker) => speaker.name).join(', ');
  }

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startTime);
  }
}

class SessionSpeaker {
  final String name;
  final String? file;

  SessionSpeaker({
    required this.name,
    this.file,
  });

  factory SessionSpeaker.fromJson(Map<String, dynamic> json) {
    return SessionSpeaker(
      name: json['name'] ?? '',
      file: json['file'],
    );
  }
}