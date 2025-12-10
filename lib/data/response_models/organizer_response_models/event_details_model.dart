// lib/data/response_models/organizer_response_models/event_details_model.dart

class EventDetailsModel {
  final int id;
  final String title;
  final String description;
  final DateTime? startTime;
  final DateTime? endTime;
  final String location;
  final String googleMapLink;
  final String joinToken;
  final bool mapstatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Sponsor> sponsors;
  final List<Exhibitor> exhibitors;

  EventDetailsModel({
    required this.id,
    required this.title,
    required this.description,
    this.startTime,
    this.endTime,
    required this.location,
    required this.googleMapLink,
    required this.joinToken,
    required this.mapstatus,
    required this.createdAt,
    required this.updatedAt,
    required this.sponsors,
    required this.exhibitors,
  });

  factory EventDetailsModel.fromJson(Map<String, dynamic> json) {
    return EventDetailsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime']).toLocal()
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime']).toLocal()
          : null,
      location: json['location'] ?? '',
      googleMapLink: json['googleMapLink'] ?? '',
      joinToken: json['joinToken'] ?? '',
      mapstatus: json['mapstatus'] ?? false,
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt']).toLocal(),
      sponsors: (json['sponsors'] as List<dynamic>?)
          ?.map((sponsor) => Sponsor.fromJson(sponsor))
          .toList() ?? [],
      exhibitors: (json['exhibitors'] as List<dynamic>?)
          ?.map((exhibitor) => Exhibitor.fromJson(exhibitor))
          .toList() ?? [],
    );
  }

  String? getCoordinatesFromMapLink() {
    try {
      // Extract coordinates from Google Maps link
      final regex = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
      final match = regex.firstMatch(googleMapLink);
      if (match != null) {
        return '${match.group(1)},${match.group(2)}';
      }
    } catch (e) {
      print('Error extracting coordinates: $e');
    }
    return null;
  }

  bool get hasValidMapLink => googleMapLink.isNotEmpty && googleMapLink.contains('google.com/maps');
// Add this method to your EventDetailsModel class
  (double, double)? getCoordinates() {
    try {
      // Extract coordinates from Google Maps link
      final regex = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
      final match = regex.firstMatch(googleMapLink);
      if (match != null) {
        final lat = double.parse(match.group(1)!);
        final lng = double.parse(match.group(2)!);
        return (lat, lng);
      }
    } catch (e) {
      print('Error extracting coordinates: $e');
    }
    return null;
  }

}

class Sponsor {
  final int id;
  final String name;
  final String category;
  final String picUrl;
  final String description;
  final String? website;
  final String email;
  final String phone;
  final String linkedin;
  final String twitter;
  final String youtube;

  Sponsor({
    required this.id,
    required this.name,
    required this.category,
    required this.picUrl,
    required this.description,
    this.website,
    required this.email,
    required this.phone,
    required this.linkedin,
    required this.twitter,
    required this.youtube,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) {
    return Sponsor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      picUrl: json['Pic_url'] ?? '',
      description: json['description'] ?? '',
      website: json['website'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      linkedin: json['linkedin'] ?? '',
      twitter: json['twitter'] ?? '',
      youtube: json['youtube'] ?? '',
    );
  }

  String get categoryColor {
    switch (category.toLowerCase()) {
      case 'platinum': return '#E5E4E2'; // Platinum color
      case 'gold': return '#FFD700'; // Gold color
      case 'silver': return '#C0C0C0'; // Silver color
      case 'bronze': return '#CD7F32'; // Bronze color
      default: return '#4CAF50'; // Green for other
    }
  }
}

class Exhibitor {
  final int id;
  final String name;
  final String picUrl;
  final String description;
  final String location;
  final String website;
  final String email;
  final String phone;
  final String linkedin;
  final String twitter;
  final String youtube;

  Exhibitor({
    required this.id,
    required this.name,
    required this.picUrl,
    required this.description,
    required this.location,
    required this.website,
    required this.email,
    required this.phone,
    required this.linkedin,
    required this.twitter,
    required this.youtube,
  });

  factory Exhibitor.fromJson(Map<String, dynamic> json) {
    return Exhibitor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      picUrl: json['picUrl'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      website: json['website'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      linkedin: json['linkedin'] ?? '',
      twitter: json['twitter'] ?? '',
      youtube: json['youtube'] ?? '',
    );
  }
}