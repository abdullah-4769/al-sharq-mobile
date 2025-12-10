// event_session_response_model.dart
import 'package:al_sharq_conference/data/response_models/participant_response_model/session_model.dart';

class EventSessionsResponseModel {
  final List<SessionModel> liveSessions;
  final List<SessionModel> allSessions;

  EventSessionsResponseModel({
    required this.liveSessions,
    required this.allSessions,
  });

  factory EventSessionsResponseModel.fromJson(Map<String, dynamic> json) {
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



// class SessionModel {
//   final int sessionId;
//   final String sessionTitle;
//   final String sessionDescription;
//   final String category;
//   final String duration;
//   final String? location;
//   final bool registrationRequired;
//   final bool isLive;
//   final int? timeToStart;
//   final List<SpeakerModel> speakers;
//   final EventModel event;
//
//   SessionModel({
//     required this.sessionId,
//     required this.sessionTitle,
//     required this.sessionDescription,
//     required this.category,
//     required this.duration,
//     this.location,
//     required this.registrationRequired,
//     required this.isLive,
//     required this.timeToStart,
//     required this.speakers,
//     required this.event,
//   });
//
//   factory SessionModel.fromJson(Map<String, dynamic> json) {
//     return SessionModel(
//       sessionId: json['sessionId'] ?? 0,
//       sessionTitle: json['sessionTitle'] ?? '',
//       sessionDescription: json['sessionDescription'] ?? '',
//       category: json['category'] ?? 'General',
//       duration: json['duration'] ?? '',
//       location: json['location'],
//       registrationRequired: json['registrationRequired'] ?? false,
//       isLive: json['isLive'] ?? false,
//       timeToStart: json['timeToStart'],
//       speakers: (json['speakers'] as List<dynamic>?)
//           ?.map((speaker) => SpeakerModel.fromJson(speaker))
//           .toList() ?? [],
//       event: EventModel.fromJson(json['event'] ?? {}),
//     );
//   }
//
//   // Add these helper methods to calculate live status and today's sessions
//
//   DateTime get startDateTime {
//     try {
//       final times = duration.split(' - ');
//       if (times.isNotEmpty) {
//         return DateTime.parse(times[0]).toLocal();
//       }
//     } catch (e) {
//       print('Error parsing start date: $e');
//     }
//     return DateTime.now();
//   }
//
//   DateTime get endDateTime {
//     try {
//       final times = duration.split(' - ');
//       if (times.length >= 2) {
//         return DateTime.parse(times[1]).toLocal();
//       }
//     } catch (e) {
//       print('Error parsing end date: $e');
//     }
//     return DateTime.now().add(Duration(hours: 1));
//   }
//
//   // Check if session is currently live based on current time and duration
//   bool get isCurrentlyLive {
//     final now = DateTime.now();
//     return now.isAfter(startDateTime) && now.isBefore(endDateTime);
//   }
//
//   // Check if session is today (same date as current date)
//   bool get isToday {
//     final now = DateTime.now();
//     final startDate = startDateTime;
//     return startDate.year == now.year &&
//         startDate.month == now.month &&
//         startDate.day == now.day;
//   }
//
//   // Check if session is upcoming today (not started yet but today)
//   bool get isUpcomingToday {
//     final now = DateTime.now();
//     return isToday && now.isBefore(startDateTime);
//   }
//
//   // Get minutes until session starts (for today's upcoming sessions)
//   int? get minutesUntilStart {
//     if (!isToday) return null;
//     final now = DateTime.now();
//     if (now.isBefore(startDateTime)) {
//       return startDateTime.difference(now).inMinutes;
//     }
//     return null;
//   }
//
//   // Get formatted time range
//   String get formattedTime {
//     try {
//       return '${_formatTime(startDateTime)} - ${_formatTime(endDateTime)}';
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
//   // Format date
//   String get formattedDate {
//     final startDate = startDateTime;
//     final now = DateTime.now();
//
//     if (startDate.year == now.year &&
//         startDate.month == now.month &&
//         startDate.day == now.day) {
//       return 'Today';
//     } else if (startDate.year == now.year &&
//         startDate.month == now.month &&
//         startDate.day == now.day + 1) {
//       return 'Tomorrow';
//     }
//
//     final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//
//     return '${weekdayNames[startDate.weekday - 1]}, ${monthNames[startDate.month - 1]} ${startDate.day}';
//   }
//
//   String get displayLocation {
//     return location ?? 'Online';
//   }
//
//   static SessionModel empty() {
//     return SessionModel(
//       sessionId: 0,
//       sessionTitle: 'No sessions available',
//       sessionDescription: '',
//       category: 'General',
//       duration: '',
//       location: null,
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
// }
//

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