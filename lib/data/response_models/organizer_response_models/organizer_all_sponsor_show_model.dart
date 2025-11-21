class OrganizerAllSponsorShowModel {
  final List<OrganizerAllSponsorShowSponsor> sponsors;

  OrganizerAllSponsorShowModel({
    required this.sponsors,
  });

  factory OrganizerAllSponsorShowModel.fromJson(List<dynamic> json) {
    return OrganizerAllSponsorShowModel(
      sponsors: json.map((sponsor) => OrganizerAllSponsorShowSponsor.fromJson(sponsor)).toList(),
    );
  }

  List<dynamic> toJson() {
    return sponsors.map((sponsor) => sponsor.toJson()).toList();
  }
}

class OrganizerAllSponsorShowSponsor {
  final int id;
  final String name;
  final String category;
  final String? picUrl;
  final String description;
  final String? website;
  final String email;
  final String? phone;
  final String? linkedin;
  final String? twitter;
  final String? youtube;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrganizerAllSponsorShowSponsor({
    required this.id,
    required this.name,
    required this.category,
    this.picUrl,
    required this.description,
    this.website,
    required this.email,
    this.phone,
    this.linkedin,
    this.twitter,
    this.youtube,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganizerAllSponsorShowSponsor.fromJson(Map<String, dynamic> json) {
    return OrganizerAllSponsorShowSponsor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      picUrl: json['Pic_url'],
      description: json['description'] ?? '',
      website: json['website'],
      email: json['email'] ?? '',
      phone: json['phone'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
      youtube: json['youtube'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'Pic_url': picUrl,
      'description': description,
      'website': website,
      'email': email,
      'phone': phone,
      'linkedin': linkedin,
      'twitter': twitter,
      'youtube': youtube,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}