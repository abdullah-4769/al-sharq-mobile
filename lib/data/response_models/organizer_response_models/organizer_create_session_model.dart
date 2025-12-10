class OrganizerCreateSessionModel {
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
  final String joinToken;
  final bool registrationRequired;
  final bool isActive;

  OrganizerCreateSessionModel({
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
    required this.joinToken,
    required this.registrationRequired,
    required this.isActive,
  });

  factory OrganizerCreateSessionModel.fromJson(Map<String, dynamic> json) {
    return OrganizerCreateSessionModel(
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
      joinToken: json['joinToken'] ?? '',
      registrationRequired: json['registrationRequired'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }
}