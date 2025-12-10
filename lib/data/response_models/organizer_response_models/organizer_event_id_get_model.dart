class OrganizerEventIdGetModel {
  final int eventId; // Changed from 'id' to 'eventId'
  final String title;
  final String? description;
  final String? location;
  final String? startTime;
  final String? endTime;

  OrganizerEventIdGetModel({
    required this.eventId, // Updated field name
    required this.title,
    this.description,
    this.location,
    this.startTime,
    this.endTime,
  });

  factory OrganizerEventIdGetModel.fromJson(Map<String, dynamic> json) {
    return OrganizerEventIdGetModel(
      eventId: json['eventId'] ?? 0, // Updated field name
      title: json['title'] ?? '',
      description: json['description'],
      location: json['location'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}