// session_model.dart
import 'event_session_response_model.dart';


class SessionModel {
  final int sessionId;
  final String sessionTitle;
  final String sessionDescription;
  final String category;
  final String duration;
  final String? location;
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
    this.location,
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
      category: json['category'] ?? 'General',
      duration: json['duration'] ?? '',
      location: json['location'],
      registrationRequired: json['registrationRequired'] ?? false,
      isLive: json['isLive'] ?? false,
      timeToStart: json['timeToStart'],
      speakers: (json['speakers'] as List<dynamic>?)
          ?.map((speaker) => SpeakerModel.fromJson(speaker))
          .toList() ?? [],
      event: EventModel.fromJson(json['event'] ?? {}),
    );
  }

  // Add all the helper methods I provided earlier
  DateTime get startDateTime {
    try {
      final times = duration.split(' - ');
      if (times.isNotEmpty) {
        return DateTime.parse(times[0]).toLocal();
      }
    } catch (e) {
      print('Error parsing start date: $e');
    }
    return DateTime.now();
  }

  DateTime get endDateTime {
    try {
      final times = duration.split(' - ');
      if (times.length >= 2) {
        return DateTime.parse(times[1]).toLocal();
      }
    } catch (e) {
      print('Error parsing end date: $e');
    }
    return DateTime.now().add(Duration(hours: 1));
  }

  bool get isCurrentlyLive {
    final now = DateTime.now();
    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }
  // Check if session is in the past
  bool get isPast {
    return DateTime.now().isAfter(endDateTime);
  }

  // Check if session is current (live or upcoming today)
  bool get isCurrentOrFuture {
    return !isPast;
  }
  bool get isToday {
    final now = DateTime.now();
    final startDate = startDateTime;
    return startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day;
  }

  bool get isUpcomingToday {
    final now = DateTime.now();
    return isToday && now.isBefore(startDateTime);
  }

  // FIX: Add the missing isUpcoming property
  bool get isUpcoming => !isCurrentlyLive && startDateTime.isAfter(DateTime.now());

  int? get minutesUntilStart {
    if (!isToday) return null;
    final now = DateTime.now();
    if (now.isBefore(startDateTime)) {
      return startDateTime.difference(now).inMinutes;
    }
    return null;
  }

  String get formattedTime {
    try {
      return '${_formatTime(startDateTime)} - ${_formatTime(endDateTime)}';
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
// In SessionModel class
  String get durationInMinutes {
    try {
      final difference = endDateTime.difference(startDateTime);
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${minutes}m';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  String get formattedDate {
    final startDate = startDateTime;
    final now = DateTime.now();

    if (startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day) {
      return 'Today';
    } else if (startDate.year == now.year &&
        startDate.month == now.month &&
        startDate.day == now.day + 1) {
      return 'Tomorrow';
    }

    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return '${weekdayNames[startDate.weekday - 1]}, ${monthNames[startDate.month - 1]} ${startDate.day}';
  }

  String get displayLocation {
    return location ?? 'Online';
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
}