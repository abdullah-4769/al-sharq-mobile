import 'package:flutter/material.dart';
class OrganizerAllSessionDetailsShowModel {
  final int id;
  final int eventId;
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String location;
  final String category;
  final int capacity;
  final String joinToken;
  final bool registrationRequired;
  final List<OrganizerSessionSpeaker> speakers;

  OrganizerAllSessionDetailsShowModel({
    required this.id,
    required this.eventId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.category,
    required this.capacity,
    required this.joinToken,
    required this.registrationRequired,
    required this.speakers,
  });

  factory OrganizerAllSessionDetailsShowModel.fromJson(Map<String, dynamic> json) {
    return OrganizerAllSessionDetailsShowModel(
      id: json['id'] ?? 0,
      eventId: json['eventId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      capacity: json['capacity'] ?? 0,
      joinToken: json['joinToken'] ?? '',
      registrationRequired: json['registrationRequired'] ?? false,
      speakers: (json['speakers'] as List? ?? [])
          .map((speaker) => OrganizerSessionSpeaker.fromJson(speaker))
          .toList(),
    );
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(startTime);
      return '${_getWeekday(date)}, ${_getMonth(date)} ${date.day}, ${date.year}';
    } catch (e) {
      return 'Date not available';
    }
  }

  String get formattedTime {
    try {
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);
      return '${_formatTime(start)} - ${_formatTime(end)}';
    } catch (e) {
      return 'Time not available';
    }
  }

  String get duration {
    try {
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);
      final difference = end.difference(start);
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);

      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '${minutes}m';
      }
    } catch (e) {
      return 'Duration not available';
    }
  }

  String get primarySpeaker {
    return speakers.isNotEmpty ? speakers.first.name : 'No Speaker';
  }

  String get status {
    try {
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
    } catch (e) {
      return 'Unknown';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Ongoing':
        return Colors.green;
      case 'Completed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getWeekday(DateTime date) {
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];
  }

  String _getMonth(DateTime date) {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }
}

class OrganizerSessionSpeaker {
  final String name;
  final String file;

  OrganizerSessionSpeaker({
    required this.name,
    required this.file,
  });

  factory OrganizerSessionSpeaker.fromJson(Map<String, dynamic> json) {
    return OrganizerSessionSpeaker(
      name: json['name'] ?? '',
      file: json['file'] ?? '',
    );
  }
}