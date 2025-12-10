class SponsorDashboardDataModel {
  final int total;
  final int ongoing;
  final int scheduled;
  final List<SponsorSession> sessions;

  SponsorDashboardDataModel({
    required this.total,
    required this.ongoing,
    required this.scheduled,
    required this.sessions,
  });

  factory SponsorDashboardDataModel.fromJson(Map<String, dynamic> json) {
    return SponsorDashboardDataModel(
      total: json['total'] ?? 0,
      ongoing: json['ongoing'] ?? 0,
      scheduled: json['scheduled'] ?? 0,
      sessions: (json['sessions'] as List? ?? [])
          .map((sessionJson) => SponsorSession.fromJson(sessionJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'ongoing': ongoing,
      'scheduled': scheduled,
      'sessions': sessions.map((session) => session.toJson()).toList(),
    };
  }
}

class SponsorSession {
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
  final List<SponsorSpeaker> speakers;

  SponsorSession({
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

  factory SponsorSession.fromJson(Map<String, dynamic> json) {
    return SponsorSession(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      capacity: json['capacity'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      eventId: json['eventId'] ?? 0,
      joinToken: json['joinToken'] ?? '',
      registrationRequired: json['registrationRequired'] ?? false,
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      speakers: (json['speakers'] as List? ?? [])
          .map((speakerJson) => SponsorSpeaker.fromJson(speakerJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'category': category,
      'capacity': capacity,
      'tags': tags,
      'eventId': eventId,
      'joinToken': joinToken,
      'registrationRequired': registrationRequired,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'speakers': speakers.map((speaker) => speaker.toJson()).toList(),
    };
  }

  // Helper methods for session status
  String get sessionStatus {
    final now = DateTime.now();
    if (now.isAfter(endTime)) {
      return 'Completed';
    } else if (now.isAfter(startTime) && now.isBefore(endTime)) {
      return 'Live';
    } else {
      return 'Scheduled';
    }
  }

  bool get isLive => sessionStatus == 'Live';
  bool get isCompleted => sessionStatus == 'Completed';
  bool get isScheduled => sessionStatus == 'Scheduled';

  String get formattedStartTime {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedEndTime {
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  String get timeRange {
    return '$formattedStartTime - $formattedEndTime';
  }

  String get duration {
    final difference = endTime.difference(startTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class SponsorSpeaker {
  final String name;
  final String file;

  SponsorSpeaker({
    required this.name,
    required this.file,
  });

  factory SponsorSpeaker.fromJson(Map<String, dynamic> json) {
    return SponsorSpeaker(
      name: json['name'] ?? '',
      file: json['file'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'file': file,
    };
  }
}