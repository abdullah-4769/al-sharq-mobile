// lib/data/request_models/event_sessions_response_model.dart

// Main response model
// class EventSessionsResponseModel {
//   final List<SessionModel> liveSessions;     // Currently live sessions
//   final List<SessionModel> allSessions;      // All sessions including upcoming
//
//   EventSessionsResponseModel({
//     required this.liveSessions,
//     required this.allSessions,
//   });
//
//   factory EventSessionsResponseModel.fromJson(Map<String, dynamic> json) {
//     return EventSessionsResponseModel(
//       liveSessions: (json['liveSessions'] as List)
//           .map((session) => SessionModel.fromJson(session))
//           .toList(),
//       allSessions: (json['allSessions'] as List)
//           .map((session) => SessionModel.fromJson(session))
//           .toList(),
//     );
//   }
// }


class EventSessionsResponseModel {
  final List<SessionModel> liveSessions;
  final List<SessionModel> allSessions;

  EventSessionsResponseModel({
    required this.liveSessions,
    required this.allSessions,
  });

  factory EventSessionsResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle cases where the lists might be null
    final liveSessionsList = json['liveSessions'] as List? ?? [];
    final allSessionsList = json['allSessions'] as List? ?? [];

    return EventSessionsResponseModel(
      liveSessions: liveSessionsList
          .map((session) => SessionModel.fromJson(session))
          .toList(),
      allSessions: allSessionsList
          .map((session) => SessionModel.fromJson(session))
          .toList(),
    );
  }
}
class SessionModel {
  final int sessionId;
  final String sessionTitle;
  final String sessionDescription;
  final String category;
  final String duration;
  final String? location; // Make nullable
  final bool registrationRequired;
  final bool isLive;
  final int? timeToStart;
  final List<SpeakerModel> speakers;
  final EventModel event;

  SessionModel({
    required this.sessionId,
    required this.sessionTitle,
    required this.sessionDescription,
    required this.category,
    required this.duration,
    this.location, // Now nullable
    required this.registrationRequired,
    required this.isLive,
    required this.timeToStart,
    required this.speakers,
    required this.event,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionId: json['sessionId'] ?? 0,
      sessionTitle: json['sessionTitle'] ?? '',
      sessionDescription: json['sessionDescription'] ?? '',
      category: json['category'] ?? 'General', // Provide default value
      duration: json['duration'] ?? '',
      location: json['location'], // Can be null
      registrationRequired: json['registrationRequired'] ?? false,
      isLive: json['isLive'] ?? false,
      timeToStart: json['timeToStart'],
      speakers: (json['speakers'] as List<dynamic>?)
          ?.map((speaker) => SpeakerModel.fromJson(speaker))
          .toList() ?? [],
      event: EventModel.fromJson(json['event'] ?? {}),
    );
  }

  static SessionModel empty() {
    return SessionModel(
      sessionId: 0,
      sessionTitle: 'No sessions available',
      sessionDescription: '',
      category: 'General',
      duration: '',
      location: null,
      registrationRequired: false,
      isLive: false,
      timeToStart: null,
      speakers: [],
      event: EventModel(
        eventId: 0,
        eventTitle: '',
        eventDescription: '',
      ),
    );
  }

  // Update your helper methods to handle null location
  String get displayLocation {
    return location ?? 'Online';
  }
  // Update other helper methods to be more robust
  String get formattedTime {
    try {
      final times = duration.split(' - ');
      if (times.length >= 2) {
        final start = DateTime.tryParse(times[0]);
        final end = DateTime.tryParse(times[1]);
        if (start != null && end != null) {
          return '${_formatTime(start)} - ${_formatTime(end)}';
        }
      }
      return 'TBD';
    } catch (e) {
      return 'TBD';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : hour;
    return '$displayHour:$minute $period';
  }

  // Update startDate and endDate getters to handle parsing errors
  DateTime get startDate {
    try {
      return DateTime.parse(duration.split(' - ')[0]);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime get endDate {
    try {
      return DateTime.parse(duration.split(' - ')[1]);
    } catch (e) {
      return DateTime.now().add(Duration(hours: 1));
    }
  }

  bool get isUpcoming => !isLive && timeToStart != null;
}
// // Session model representing each session
// class SessionModel {
//   final int sessionId;
//   final String sessionTitle;
//   final String sessionDescription;
//   final String category;           // e.g., "Keynote", "Workshop", "General Discussion"
//   final String duration;           // Date range string
//   final String location;           // e.g., "Old Muslim town", "Online"
//   final bool registrationRequired;
//   final bool isLive;               // Whether session is currently live
//   final int? timeToStart;          // Time in minutes until session starts (null if live)
//   final List<SpeakerModel> speakers; // List of speakers for this session
//   final EventModel event;          // Event details
// // Add to your SessionModel class
//   static SessionModel empty() {
//     return SessionModel(
//       sessionId: 0,
//       sessionTitle: 'No sessions available',
//       sessionDescription: '',
//       category: '',
//       duration: '',
//       location: '',
//       registrationRequired: false,
//       isLive: false,
//       timeToStart: null,
//       speakers: [],
//       event: EventModel(
//         eventId: 0,
//         eventTitle: '',
//         eventDescription: '',
//       ),
//     );
//   }
//   SessionModel({
//     required this.sessionId,
//     required this.sessionTitle,
//     required this.sessionDescription,
//     required this.category,
//     required this.duration,
//     required this.location,
//     required this.registrationRequired,
//     required this.isLive,
//     required this.timeToStart,
//     required this.speakers,
//     required this.event,
//   });
//
//   factory SessionModel.fromJson(Map<String, dynamic> json) {
//     return SessionModel(
//       sessionId: json['sessionId'],
//       sessionTitle: json['sessionTitle'],
//       sessionDescription: json['sessionDescription'],
//       category: json['category'],
//       duration: json['duration'],
//       location: json['location'],
//       registrationRequired: json['registrationRequired'],
//       isLive: json['isLive'],
//       timeToStart: json['timeToStart'],
//       speakers: (json['speakers'] as List)
//           .map((speaker) => SpeakerModel.fromJson(speaker))
//           .toList(),
//       event: EventModel.fromJson(json['event']),
//     );
//   }
// // Add these methods to your SessionModel class in event_session_response_model.dart
//
// // Helper method to get formatted time
//   String get formattedTime {
//     try {
//       final times = duration.split(' - ');
//       if (times.length >= 2) {
//         final start = DateTime.parse(times[0]);
//         final end = DateTime.parse(times[1]);
//         return '${_formatTime(start)} - ${_formatTime(end)}';
//       }
//       return 'TBD';
//     } catch (e) {
//       return 'TBD';
//     }
//   }
//
//   String _formatTime(DateTime dateTime) {
//     final hour = dateTime.hour % 12;
//     final minute = dateTime.minute.toString().padLeft(2, '0');
//     final period = dateTime.hour < 12 ? 'AM' : 'PM';
//     final displayHour = hour == 0 ? 12 : hour;
//     return '$displayHour:$minute $period';
//   }
//
//   String get durationInMinutes {
//     try {
//       final times = duration.split(' - ');
//       if (times.length >= 2) {
//         final start = DateTime.parse(times[0]);
//         final end = DateTime.parse(times[1]);
//         final difference = end.difference(start);
//         final minutes = difference.inMinutes;
//         return '$minutes minutes';
//       }
//       return 'TBD';
//     } catch (e) {
//       return 'TBD';
//     }
//   }
//
//   DateTime get sessionDate {
//     try {
//       final times = duration.split(' - ');
//       if (times.isNotEmpty) {
//         return DateTime.parse(times[0]);
//       }
//       return DateTime.now();
//     } catch (e) {
//       return DateTime.now();
//     }
//   }
//
//   String get formattedDate {
//     try {
//       final times = duration.split(' - ');
//       if (times.isNotEmpty) {
//         final date = DateTime.parse(times[0]);
//         return '${_getWeekday(date)}, ${_getMonth(date)} ${date.day}, ${date.year}';
//       }
//       return 'Date TBD';
//     } catch (e) {
//       return 'Date TBD';
//     }
//   }
//
//   String _getWeekday(DateTime date) {
//     return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];
//   }
//
//   String _getMonth(DateTime date) {
//     return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
//   }
//   // Helper method to get start and end dates from duration string
//   DateTime get startDate => DateTime.parse(duration.split(' - ')[0]);
//   DateTime get endDate => DateTime.parse(duration.split(' - ')[1]);
//
//   // Helper to check if session is upcoming
//   bool get isUpcoming => !isLive && timeToStart != null;
//
//   // // Helper to get formatted time
//   // String get formattedTime {
//   //   final start = startDate;
//   //   return '${start.hour}:${start.minute.toString().padLeft(2, '0')}';
//   // }
// }



class SpeakerModel {
  final int speakerId;
  final String fullName;
  final String bio;
  final String? pic;

  SpeakerModel({
    required this.speakerId,
    required this.fullName,
    required this.bio,
    required this.pic,
  });

  factory SpeakerModel.fromJson(Map<String, dynamic> json) {
    return SpeakerModel(
      speakerId: json['speakerId'] ?? 0,
      fullName: json['fullName'] ?? '',
      bio: json['bio'] ?? '',
      pic: json['pic'], // Can be null
    );
  }
}
// Speaker model
// class SpeakerModel {
//   final int speakerId;
//   final String fullName;
//   final String bio;
//   final String? pic;  // Speaker photo URL (nullable)
//
//   SpeakerModel({
//     required this.speakerId,
//     required this.fullName,
//     required this.bio,
//     required this.pic,
//   });
//
//   factory SpeakerModel.fromJson(Map<String, dynamic> json) {
//     return SpeakerModel(
//       speakerId: json['speakerId'],
//       fullName: json['fullName'],
//       bio: json['bio'],
//       pic: json['pic'],
//     );
//   }
// }

// Event model
class EventModel {
  final int eventId;
  final String eventTitle;
  final String eventDescription;

  EventModel({
    required this.eventId,
    required this.eventTitle,
    required this.eventDescription,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      eventId: json['eventId'],
      eventTitle: json['eventTitle'],
      eventDescription: json['eventDescription'],
    );
  }
}