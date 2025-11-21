class OrganizerAddNewExhibitorRequestModel {
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
  final String password;

  OrganizerAddNewExhibitorRequestModel({
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
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'picUrl': picUrl,
      'description': description,
      'location': location,
      'website': website,
      'email': email,
      'phone': phone,
      'linkedin': linkedin,
      'twitter': twitter,
      'youtube': youtube,
      'password': password,
    };
  }
}

class OrganizerAddNewExhibitorResponseModel {
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
  final String password;
  final String role;
  final String createdAt;
  final String updatedAt;

  OrganizerAddNewExhibitorResponseModel({
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
    required this.password,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganizerAddNewExhibitorResponseModel.fromJson(Map<String, dynamic> json) {
    return OrganizerAddNewExhibitorResponseModel(
      id: json['id'],
      name: json['name'],
      picUrl: json['picUrl'],
      description: json['description'],
      location: json['location'],
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