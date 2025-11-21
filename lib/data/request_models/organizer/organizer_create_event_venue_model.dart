class OrganizerCreateEventVenueModel {
  final int id;
  final String title;
  final String description;
  final String? startTime;
  final String? endTime;
  final String location;
  final String googleMapLink;
  final String joinToken;
  final bool mapstatus;
  final List<OrganizerCreateEventVenueSponsor> sponsors;
  final List<OrganizerCreateEventVenueExhibitor> exhibitors;

  OrganizerCreateEventVenueModel({
    required this.id,
    required this.title,
    required this.description,
    this.startTime,
    this.endTime,
    required this.location,
    required this.googleMapLink,
    required this.joinToken,
    required this.mapstatus,
    required this.sponsors,
    required this.exhibitors,
  });

  factory OrganizerCreateEventVenueModel.fromJson(Map<String, dynamic> json) {
    return OrganizerCreateEventVenueModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: json['startTime'],
      endTime: json['endTime'],
      location: json['location'] ?? '',
      googleMapLink: json['googleMapLink'] ?? '',
      joinToken: json['joinToken'] ?? '',
      mapstatus: json['mapstatus'] ?? false,
      sponsors: (json['sponsors'] as List? ?? [])
          .map((sponsor) => OrganizerCreateEventVenueSponsor.fromJson(sponsor))
          .toList(),
      exhibitors: (json['exhibitors'] as List? ?? [])
          .map((exhibitor) => OrganizerCreateEventVenueExhibitor.fromJson(exhibitor))
          .toList(),
    );
  }
}

class OrganizerCreateEventVenueSponsor {
  final int id;
  final String name;
  final String category;
  final String? picUrl;
  final String description;
  final String website;
  final String email;
  final String phone;
  final String linkedin;
  final String twitter;
  final String youtube;

  OrganizerCreateEventVenueSponsor({
    required this.id,
    required this.name,
    required this.category,
    this.picUrl,
    required this.description,
    required this.website,
    required this.email,
    required this.phone,
    required this.linkedin,
    required this.twitter,
    required this.youtube,
  });

  factory OrganizerCreateEventVenueSponsor.fromJson(Map<String, dynamic> json) {
    return OrganizerCreateEventVenueSponsor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      picUrl: json['Pic_url'],
      description: json['description'] ?? '',
      website: json['website'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      linkedin: json['linkedin'] ?? '',
      twitter: json['twitter'] ?? '',
      youtube: json['youtube'] ?? '',
    );
  }
}

class OrganizerCreateEventVenueExhibitor {
  final int id;
  final String name;
  final String? picUrl;
  final String description;
  final String location;
  final String website;
  final String email;
  final String phone;
  final String linkedin;
  final String twitter;
  final String youtube;

  OrganizerCreateEventVenueExhibitor({
    required this.id,
    required this.name,
    this.picUrl,
    required this.description,
    required this.location,
    required this.website,
    required this.email,
    required this.phone,
    required this.linkedin,
    required this.twitter,
    required this.youtube,
  });

  factory OrganizerCreateEventVenueExhibitor.fromJson(Map<String, dynamic> json) {
    return OrganizerCreateEventVenueExhibitor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      picUrl: json['picUrl'],
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