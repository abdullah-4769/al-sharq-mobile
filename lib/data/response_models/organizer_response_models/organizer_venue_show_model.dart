import 'package:google_maps_flutter/google_maps_flutter.dart';
class OrganizerVenueShowModel {
  final int totalSessions;
  final int liveSessions;
  final int scheduledSessions;
  final List<OrganizerVenueShowEvent> events;

  OrganizerVenueShowModel({
    required this.totalSessions,
    required this.liveSessions,
    required this.scheduledSessions,
    required this.events,
  });

  factory OrganizerVenueShowModel.fromJson(Map<String, dynamic> json) {
    return OrganizerVenueShowModel(
      totalSessions: json['totalSessions'] ?? 0,
      liveSessions: json['liveSessions'] ?? 0,
      scheduledSessions: json['scheduledSessions'] ?? 0,
      events: (json['events'] as List? ?? [])
          .map((event) => OrganizerVenueShowEvent.fromJson(event))
          .toList(),
    );
  }
}

class OrganizerVenueShowEvent {
  final int id;
  final String name;
  final String description;
  final String googleMapLink;
  final int totalSessions;
  final int liveSessions;
  final int scheduledSessions;
  final String? startTime;
  final String? endTime;
  final String? location;
  final bool? mapstatus;
  final List<OrganizerVenueShowSponsor> sponsors;
  final List<OrganizerVenueShowExhibitor> exhibitors;

  OrganizerVenueShowEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.googleMapLink,
    required this.totalSessions,
    this.liveSessions = 0,
    this.scheduledSessions = 0,
    this.startTime,
    this.endTime,
    this.location,
    this.mapstatus,
    required this.sponsors,
    required this.exhibitors,
  });

  factory OrganizerVenueShowEvent.fromJson(Map<String, dynamic> json) {
    return OrganizerVenueShowEvent(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? '',
      description: json['description'] ?? '',
      googleMapLink: json['googleMapLink'] ?? '',
      totalSessions: json['totalSessions'] ?? 0,
      liveSessions: json['liveSessions'] ?? 0,
      scheduledSessions: json['scheduledSessions'] ?? 0,
      startTime: json['startTime'],
      endTime: json['endTime'],
      location: json['location'],
      mapstatus: json['mapstatus'],
      sponsors: (json['sponsors'] as List? ?? [])
          .map((sponsor) => OrganizerVenueShowSponsor.fromJson(sponsor))
          .toList(),
      exhibitors: (json['exhibitors'] as List? ?? [])
          .map((exhibitor) => OrganizerVenueShowExhibitor.fromJson(exhibitor))
          .toList(),
    );
  }

  LatLng? getLatLngFromUrl() {
    try {
      print('🗺️ Parsing URL: $googleMapLink');

      // Method 1: Extract from @lat,lng format in URL path
      if (googleMapLink.contains('@')) {
        final parts = googleMapLink.split('@');
        if (parts.length > 1) {
          final coordString = parts[1].split('/')[0];
          final coords = coordString.split(',');
          if (coords.length >= 2) {
            final lat = double.tryParse(coords[0].trim());
            final lng = double.tryParse(coords[1].trim());
            if (lat != null && lng != null) {
              print('✅ Extracted coordinates: $lat, $lng');
              return LatLng(lat, lng);
            }
          }
        }
      }

      // Method 2: Extract from query parameters
      final uri = Uri.parse(googleMapLink);
      if (uri.queryParameters.containsKey('q')) {
        final location = uri.queryParameters['q']!;
        final coords = location.split(',');
        if (coords.length == 2) {
          final lat = double.tryParse(coords[0].trim());
          final lng = double.tryParse(coords[1].trim());
          if (lat != null && lng != null) {
            print('✅ Extracted from query: $lat, $lng');
            return LatLng(lat, lng);
          }
        }
      }

      print('❌ Failed to extract coordinates');
    } catch (e) {
      print('❌ Error parsing coordinates: $e');
    }
    return null;
  }
}

class OrganizerVenueShowSponsor {
  final int id;
  final String name;
  final String email;
  final String? picUrl;

  OrganizerVenueShowSponsor({
    required this.id,
    required this.name,
    required this.email,
    this.picUrl,
  });

  factory OrganizerVenueShowSponsor.fromJson(Map<String, dynamic> json) {
    return OrganizerVenueShowSponsor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      picUrl: json['Pic_url'] ?? json['picUrl'],
    );
  }
}

class OrganizerVenueShowExhibitor {
  final int id;
  final String name;
  final String email;
  final String? picUrl;

  OrganizerVenueShowExhibitor({
    required this.id,
    required this.name,
    required this.email,
    this.picUrl,
  });

  factory OrganizerVenueShowExhibitor.fromJson(Map<String, dynamic> json) {
    return OrganizerVenueShowExhibitor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      picUrl: json['picUrl'],
    );
  }
}