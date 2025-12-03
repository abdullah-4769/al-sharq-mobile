// lib/data/response_models/participant_response_model/today_session_model.dart
// lib/data/response_models/participant_response_model/today_session_model.dart
import 'package:intl/intl.dart';

class TodaySessionModel {
  final int sessionId;
  final String sessionTitle;
  final String? sessionDescription;
  final String duration;
  final String? location;
  final String? category;
  final bool? isLive;
  final List<SessionSpeaker> speakers;
  final bool? isRegistered;
  final DateTime startTime;
  final DateTime endTime;

  TodaySessionModel({
    required this.sessionId,
    required this.sessionTitle,
    this.sessionDescription,
    required this.duration,
    this.location,
    this.category,
    this.isLive,
    required this.speakers,
    this.isRegistered,
    required this.startTime,
    required this.endTime,
  });

  factory TodaySessionModel.fromJson(Map<String, dynamic> json) {
    // Parse start and end times
    DateTime startTime;
    DateTime endTime;
    String durationStr = '';

    try {
      final startTimeStr = json['startTime'];
      final endTimeStr = json['endTime'];

      if (startTimeStr != null) {
        startTime = DateTime.parse(startTimeStr).toLocal();
      } else {
        startTime = DateTime.now();
      }

      if (endTimeStr != null) {
        endTime = DateTime.parse(endTimeStr).toLocal();
      } else {
        endTime = DateTime.now().add(Duration(hours: 1));
      }

      // Create duration string
      durationStr = '$startTimeStr - $endTimeStr';
    } catch (e) {
      print('Error parsing time: $e');
      startTime = DateTime.now();
      endTime = DateTime.now().add(Duration(hours: 1));
      durationStr = '';
    }

    // Parse speakers from the API structure
    List<SessionSpeaker> speakersList = [];
    if (json['speakers'] != null && json['speakers'] is List) {
      speakersList = (json['speakers'] as List).map((speakerJson) {
        return SessionSpeaker.fromJson(speakerJson);
      }).toList();
    }

    return TodaySessionModel(
      sessionId: json['sessionId'] ?? json['id'] ?? 0,
      sessionTitle: json['title'] ?? json['sessionTitle'] ?? '',
      sessionDescription: json['description'] ?? json['sessionDescription'],
      duration: durationStr,
      location: json['location'] ?? json['room'],
      category: json['category'] ?? json['type'],
      isLive: json['isActive'] ?? json['isLive'] ?? false,
      speakers: speakersList,
      isRegistered: json['isRegistered'] ?? false,
      startTime: startTime,
      endTime: endTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'sessionTitle': sessionTitle,
      'sessionDescription': sessionDescription,
      'duration': duration,
      'location': location,
      'category': category,
      'isLive': isLive,
      'speakers': speakers.map((speaker) => speaker.toJson()).toList(),
      'isRegistered': isRegistered,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  // Helper method to check if session is currently live
  bool get isCurrentlyLive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  // Check if session is today
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  // Check if session is upcoming (not started yet)
  bool get isUpcoming {
    return DateTime.now().isBefore(startTime);
  }

  // Get formatted time
  String get formattedTime {
    try {
      return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
    } catch (e) {
      return 'TBD';
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  // Get duration in minutes
  String get durationInMinutes {
    try {
      final difference = endTime.difference(startTime);
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${minutes}m';
      }
    } catch (e) {
      return 'TBD';
    }
  }

  // Get time until session starts
  String get timeUntilStart {
    final now = DateTime.now();
    if (now.isBefore(startTime)) {
      final difference = startTime.difference(now);

      if (difference.inDays > 0) {
        return 'In ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
      } else if (difference.inHours > 0) {
        return 'In ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
      } else {
        return 'In ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
      }
    }
    return '';
  }
}
class SessionSpeaker {
  final int speakerId;
  final String fullName;
  final String? bio;
  final String? photoUrl;
  final String? organization;
  final List<String>? expertise;
  final List<String>? designations;

  SessionSpeaker({
    required this.speakerId,
    required this.fullName,
    this.bio,
    this.photoUrl,
    this.organization,
    this.expertise,
    this.designations,
  });

  factory SessionSpeaker.fromJson(Map<String, dynamic> json) {
    // Handle nested user structure from API
    String name = '';
    String? photo;

    if (json['user'] != null) {
      name = json['user']['name'] ?? '';
      photo = json['user']['file'];
    } else {
      name = json['fullName'] ?? json['name'] ?? '';
      photo = json['photoUrl'] ?? json['photo'] ?? json['file'];
    }

    // Parse expertise array
    List<String>? expertiseList;
    if (json['expertise'] != null && json['expertise'] is List) {
      expertiseList = (json['expertise'] as List).map((e) => e.toString()).toList();
    }

    // Parse designations array
    List<String>? designationsList;
    if (json['designations'] != null && json['designations'] is List) {
      designationsList = (json['designations'] as List).map((e) => e.toString()).toList();
    }

    return SessionSpeaker(
      speakerId: json['speakerId'] ?? json['id'] ?? 0,
      fullName: name,
      bio: json['bio'],
      photoUrl: photo,
      organization: json['organization'] ?? json['company'],
      expertise: expertiseList,
      designations: designationsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speakerId': speakerId,
      'fullName': fullName,
      'bio': bio,
      'photoUrl': photoUrl,
      'organization': organization,
      'expertise': expertise,
      'designations': designations,
    };
  }
}