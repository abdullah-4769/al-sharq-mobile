class OrganizerSessionDetailsGetModel {
  final int id;
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String location;
  final String category;
  final int capacity;
  final List<String> tags;
  final int eventId;
  final bool registrationRequired;
  final List<OrganizerSessionSpeakerDetail> speakers;

  OrganizerSessionDetailsGetModel({
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
    required this.registrationRequired,
    required this.speakers,
  });

  factory OrganizerSessionDetailsGetModel.fromJson(Map<String, dynamic> json) {
    return OrganizerSessionDetailsGetModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      capacity: json['capacity'] ?? 0,
      tags: (json['tags'] as List? ?? []).map((item) => item.toString()).toList(),
      eventId: json['eventId'] ?? 0,
      registrationRequired: json['registrationRequired'] ?? false,
      speakers: (json['speakers'] as List? ?? [])
          .map((speaker) => OrganizerSessionSpeakerDetail.fromJson(speaker))
          .toList(),
    );
  }
}

class OrganizerSessionSpeakerDetail {
  final int id;
  final OrganizerSpeakerUserDetail user;

  OrganizerSessionSpeakerDetail({
    required this.id,
    required this.user,
  });

  factory OrganizerSessionSpeakerDetail.fromJson(Map<String, dynamic> json) {
    return OrganizerSessionSpeakerDetail(
      id: json['id'] ?? 0,
      user: OrganizerSpeakerUserDetail.fromJson(json['user'] ?? {}),
    );
  }
}

class OrganizerSpeakerUserDetail {
  final int id;
  final String name;
  final String email;
  final String? file;

  OrganizerSpeakerUserDetail({
    required this.id,
    required this.name,
    required this.email,
    this.file,
  });

  factory OrganizerSpeakerUserDetail.fromJson(Map<String, dynamic> json) {
    return OrganizerSpeakerUserDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      file: json['file'],
    );
  }
}