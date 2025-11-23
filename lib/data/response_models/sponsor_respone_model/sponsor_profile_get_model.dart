class SponsorProfileGetModel {
  final int id;
  final String name;
  final String category;
  final String picUrl;
  final String description;
  final String website;
  final String email;
  final String phone;
  final String linkedin;
  final String twitter;
  final String youtube;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  SponsorProfileGetModel({
    required this.id,
    required this.name,
    required this.category,
    required this.picUrl,
    required this.description,
    required this.website,
    required this.email,
    required this.phone,
    required this.linkedin,
    required this.twitter,
    required this.youtube,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SponsorProfileGetModel.fromJson(Map<String, dynamic> json) {
    return SponsorProfileGetModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      picUrl: json['Pic_url'] ?? '',
      description: json['description'] ?? '',
      website: json['website'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      linkedin: json['linkedin'] ?? '',
      twitter: json['twitter'] ?? '',
      youtube: json['youtube'] ?? '',
      role: json['role'] ?? '',
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
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}