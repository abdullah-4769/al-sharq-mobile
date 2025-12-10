// lib/data/response_models/participant_response_model/speaker_short_detail_model.dart

class SpeakerShortDetailResponse {
  final List<SpeakerShortDetail> speakers;

  SpeakerShortDetailResponse({
    required this.speakers,
  });

  factory SpeakerShortDetailResponse.fromJson(List<dynamic> json) {
    return SpeakerShortDetailResponse(
      speakers: json.map((speaker) => SpeakerShortDetail.fromJson(speaker)).toList(),
    );
  }
}

class SpeakerShortDetail {
  final int id;
  final String bio;
  final List<String> designations;
  final List<String> expertise;
  final List<String> tags;
  final int sessionCount;
  final List<SpeakerSession> sessions;
  final SpeakerUser user;

  SpeakerShortDetail({
    required this.id,
    required this.bio,
    required this.designations,
    required this.expertise,
    required this.tags,
    required this.sessionCount,
    required this.sessions,
    required this.user,
  });

  factory SpeakerShortDetail.fromJson(Map<String, dynamic> json) {
    return SpeakerShortDetail(
      id: json['id'] ?? 0,
      bio: json['bio'] ?? '',
      designations: List<String>.from(json['designations'] ?? []),
      expertise: List<String>.from(json['expertise'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      sessionCount: json['sessionCount'] ?? 0,
      sessions: (json['sessions'] as List? ?? [])
          .map((session) => SpeakerSession.fromJson(session))
          .toList(),
      user: SpeakerUser.fromJson(json['user'] ?? {}),
    );
  }

  // Helper method to get first designation
  String get firstDesignation => designations.isNotEmpty ? designations.first : '';

  // Helper method to get session titles
  List<String> get sessionTitles => sessions.map((session) => session.title).toList();

  // Helper method to check if speaker has specific tag
  bool hasTag(String tag) => tags.any((t) => t.toLowerCase().contains(tag.toLowerCase()));

  // Helper method to get expertise as string
  String get expertiseString => expertise.join(', ');

  // Helper method to get sessions count text
  String get sessionsCountText => '$sessionCount Session${sessionCount != 1 ? 's' : ''}';
}

class SpeakerSession {
  final int id;
  final String title;

  SpeakerSession({
    required this.id,
    required this.title,
  });

  factory SpeakerSession.fromJson(Map<String, dynamic> json) {
    return SpeakerSession(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
    );
  }
}

class SpeakerUser {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? file;

  SpeakerUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.file,
  });

  factory SpeakerUser.fromJson(Map<String, dynamic> json) {
    return SpeakerUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      file: json['file'],
    );
  }
}