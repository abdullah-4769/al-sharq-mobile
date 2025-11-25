// exhibitor_dashboard_model.dart
import 'package:flutter/foundation.dart';

class ExhibitorSessionsResponse {
  int? total;
  int? ongoing;
  int? scheduled;
  List<Sessions>? sessions;

  ExhibitorSessionsResponse({
    this.total,
    this.ongoing,
    this.scheduled,
    this.sessions,
  });

  factory ExhibitorSessionsResponse.fromJson(Map<String, dynamic> json) {
    return ExhibitorSessionsResponse(
      total: json['total'] as int?,
      ongoing: json['ongoing'] as int?,
      scheduled: json['scheduled'] as int?,
      sessions: json['sessions'] != null
          ? (json['sessions'] as List)
          .map((e) => Sessions.fromJson(e as Map<String, dynamic>))
          .toList()
          : <Sessions>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'ongoing': ongoing,
      'scheduled': scheduled,
      'sessions': sessions?.map((s) => s.toJson()).toList(),
    };
  }
}

class Sessions {
  int? id;
  String? title;
  String? description;
  DateTime? startTime;
  DateTime? endTime;
  String? location;
  String? category;
  int? capacity;
  List<String>? tags;
  int? eventId;
  String? joinToken;
  bool? registrationRequired;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Speaker>? speakers;

  Sessions({
    this.id,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.location,
    this.category,
    this.capacity,
    this.tags,
    this.eventId,
    this.joinToken,
    this.registrationRequired,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.speakers,
  });

  factory Sessions.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return Sessions(
      id: json['id'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      startTime: parseDate(json['startTime']),
      endTime: parseDate(json['endTime']),
      location: json['location'] as String?,
      category: json['category'] as String?,
      capacity: json['capacity'] is int
          ? json['capacity']
          : int.tryParse(json['capacity']?.toString() ?? ''),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
      eventId: json['eventId'] is int
          ? json['eventId']
          : int.tryParse(json['eventId']?.toString() ?? ''),
      joinToken: json['joinToken'] as String?,
      registrationRequired: json['registrationRequired'] as bool?,
      isActive: json['isActive'] as bool?,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      speakers: json['speakers'] != null
          ? (json['speakers'] as List)
          .map((e) => Speaker.fromJson(e as Map<String, dynamic>))
          .toList()
          : <Speaker>[],
    );
  }

  Map<String, dynamic> toJson() {
    String? toIso(DateTime? dt) => dt?.toIso8601String();

    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': toIso(startTime),
      'endTime': toIso(endTime),
      'location': location,
      'category': category,
      'capacity': capacity,
      'tags': tags,
      'eventId': eventId,
      'joinToken': joinToken,
      'registrationRequired': registrationRequired,
      'isActive': isActive,
      'createdAt': toIso(createdAt),
      'updatedAt': toIso(updatedAt),
      'speakers': speakers?.map((s) => s.toJson()).toList(),
    };
  }

  // --------------------
  // Convenience getters
  // --------------------

  /// "HH:MM - HH:MM"
  String get formattedTime {
    if (startTime == null || endTime == null) return '';
    final s = '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
    final e = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
    return '$s - $e';
  }

  /// "DD/MM/YYYY"
  String get formattedDate {
    if (startTime == null) return '';
    return '${startTime!.day.toString().padLeft(2, '0')}/${startTime!.month.toString().padLeft(2, '0')}/${startTime!.year}';
  }

  /// Duration like "1 hour 15 min"
  String get duration {
    if (startTime == null || endTime == null) return '';
    final diff = endTime!.difference(startTime!);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours > 0) {
      final h = '$hours hour${hours > 1 ? 's' : ''}';
      final m = minutes > 0 ? ' $minutes min' : '';
      return '$h$m';
    }
    return '$minutes minutes';
  }

  /// "Upcoming", "Ongoing", "Completed"
  String get status {
    if (startTime == null || endTime == null) return 'Unknown';
    final now = DateTime.now();

    if (now.isAfter(endTime!)) return 'Completed';
    if (now.isAfter(startTime!) && now.isBefore(endTime!)) return 'Ongoing';
    return 'Upcoming';
  }
}

class Speaker {
  final String name;
  final String? file;

  Speaker({
    required this.name,
    this.file,
  });

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
      name: (json['name'] ?? '').toString(),
      file: json['file']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'file': file,
    };
  }
}
