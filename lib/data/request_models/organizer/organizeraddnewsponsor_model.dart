class OrganizerAddNewSponsorRequestModel {
  final String name;
  final String description;
  final String category;
  final String picUrl;
  final String linkedin;
  final String twitter;
  final String youtube;
  final String email;
  final String phone;
  final String password;

  OrganizerAddNewSponsorRequestModel({
    required this.name,
    required this.description,
    required this.category,
    required this.picUrl,
    required this.linkedin,
    required this.twitter,
    required this.youtube,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'Pic_url': picUrl,
      'linkedin': linkedin,
      'twitter': twitter,
      'youtube': youtube,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }
}

class OrganizerAddNewSponsorResponseModel {
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
  final String password;
  final String role;
  final String createdAt;
  final String updatedAt;

  OrganizerAddNewSponsorResponseModel({
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
    required this.password,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganizerAddNewSponsorResponseModel.fromJson(Map<String, dynamic> json) {
    return OrganizerAddNewSponsorResponseModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      picUrl: json['Pic_url'],
      description: json['description'],
      website: json['website'],
      email: json['email'],
      phone: json['phone'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
      youtube: json['youtube'],
      password: json['password'],
      role: json['role'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}