// lib/data/response_models/participant_response_model/all_bookmarked_sessions_response_model.dart

class BookmarkedSessionsResponse {
  final List<BookmarkedSession> liveSessions;
  final List<BookmarkedSession> allSessions;

  BookmarkedSessionsResponse({
    required this.liveSessions,
    required this.allSessions,
  });

  factory BookmarkedSessionsResponse.fromJson(Map<String, dynamic> json) {
    return BookmarkedSessionsResponse(
      liveSessions: (json['liveSessions'] as List? ?? [])
          .map((session) => BookmarkedSession.fromJson(session))
          .toList(),
      allSessions: (json['allSessions'] as List? ?? [])
          .map((session) => BookmarkedSession.fromJson(session))
          .toList(),
    );
  }
}

class BookmarkedSession {
  final int sessionId;
  final String sessionTitle;
  final String sessionDescription;
  final String duration;
  final String location;
  final String category;
  final bool bookmarked;
  final bool registrationRequired;
  final bool isLive;
  final List<SessionSpeaker> speakers;
  final Event? event;

  BookmarkedSession({
    required this.sessionId,
    required this.sessionTitle,
    required this.sessionDescription,
    required this.duration,
    required this.location,
    required this.category,
    required this.bookmarked,
    required this.registrationRequired,
    required this.isLive,
    required this.speakers,
    this.event,
  });

  factory BookmarkedSession.fromJson(Map<String, dynamic> json) {
    return BookmarkedSession(
      sessionId: json['sessionId'] ?? 0,
      sessionTitle: json['sessionTitle'] ?? '',
      sessionDescription: json['sessionDescription'] ?? '',
      duration: json['duration'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      bookmarked: json['bookmarked'] ?? false,
      registrationRequired: json['registrationRequired'] ?? false,
      isLive: json['isLive'] ?? false,
      speakers: (json['speakers'] as List? ?? [])
          .map((speaker) => SessionSpeaker.fromJson(speaker))
          .toList(),
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
    );
  }

  // Helper method to get formatted time
  String get formattedTime {
    try {
      final times = duration.split(' - ');
      if (times.length >= 2) {
        final start = DateTime.parse(times[0]);
        final end = DateTime.parse(times[1]);
        return '${_formatTime(start)} - ${_formatTime(end)}';
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

  // Helper method to calculate duration in minutes
  String get durationInMinutes {
    try {
      final times = duration.split(' - ');
      if (times.length >= 2) {
        final start = DateTime.parse(times[0]);
        final end = DateTime.parse(times[1]);
        final difference = end.difference(start);
        final minutes = difference.inMinutes;
        return '$minutes minutes';
      }
      return 'TBD';
    } catch (e) {
      return 'TBD';
    }
  }
// Add this getter to your BookmarkedSession model
  String get startTime {
    try {
      final times = duration.split(' - ');
      if (times.isNotEmpty) {
        return times[0];
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  String get endTime {
    try {
      final times = duration.split(' - ');
      if (times.length >= 2) {
        return times[1];
      }
      return '';
    } catch (e) {
      return '';
    }
  }
  // Helper method to get date
  DateTime get sessionDate {
    try {
      final times = duration.split(' - ');
      if (times.isNotEmpty) {
        return DateTime.parse(times[0]);
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedDate {
    try {
      final times = duration.split(' - ');
      if (times.isNotEmpty) {
        final date = DateTime.parse(times[0]);
        return '${_getWeekday(date)}, ${_getMonth(date)} ${date.day}, ${date.year}';
      }
      return 'Date TBD';
    } catch (e) {
      return 'Date TBD';
    }
  }

  String _getWeekday(DateTime date) {
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];
  }

  String _getMonth(DateTime date) {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
  }

  // Alias for compatibility with existing code
  bool get isBookmarked => bookmarked;
  String get time => formattedTime;
  String get room => location;
}

class SessionSpeaker {
  final int speakerId;
  final String fullName;
  final String bio;
  final String? pic;

  SessionSpeaker({
    required this.speakerId,
    required this.fullName,
    required this.bio,
    this.pic,
  });

  factory SessionSpeaker.fromJson(Map<String, dynamic> json) {
    return SessionSpeaker(
      speakerId: json['speakerId'] ?? 0,
      fullName: json['fullName'] ?? '',
      bio: json['bio'] ?? '',
      pic: json['pic'],
    );
  }
}

class Event {
  final int eventId;
  final String eventTitle;
  final String eventDescription;

  Event({
    required this.eventId,
    required this.eventTitle,
    required this.eventDescription,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'] ?? 0,
      eventTitle: json['eventTitle'] ?? '',
      eventDescription: json['eventDescription'] ?? '',
    );
  }
}