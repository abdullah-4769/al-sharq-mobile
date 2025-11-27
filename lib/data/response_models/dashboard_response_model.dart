// lib/data/response_models/dashboard_response_model.dart
class DashboardResponseModel {
  final List<DailyAttendance> dailyAttendance;
  final List<TopSession> topSessions;

  DashboardResponseModel({
    required this.dailyAttendance,
    required this.topSessions,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return DashboardResponseModel(
      dailyAttendance: (json['dailyAttendance'] as List)
          .map((item) => DailyAttendance.fromJson(item))
          .toList(),
      topSessions: (json['topSessions'] as List)
          .map((item) => TopSession.fromJson(item))
          .toList(),
    );
  }
}

class DailyAttendance {
  final String date;
  final int count;

  DailyAttendance({
    required this.date,
    required this.count,
  });

  factory DailyAttendance.fromJson(Map<String, dynamic> json) {
    return DailyAttendance(
      date: json['date'],
      count: json['count'],
    );
  }
}

class TopSession {
  final int id;
  final String title;
  final int totalRegistrations;
  final List<String> speakers;

  TopSession({
    required this.id,
    required this.title,
    required this.totalRegistrations,
    required this.speakers,
  });

  factory TopSession.fromJson(Map<String, dynamic> json) {
    return TopSession(
      id: json['id'],
      title: json['title'],
      totalRegistrations: json['totalRegistrations'],
      speakers: List<String>.from(json['speakers']),
    );
  }

  String get speakerNames => speakers.join(', ');
}