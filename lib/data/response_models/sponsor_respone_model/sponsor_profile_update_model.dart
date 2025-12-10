import 'package:al_sharq_conference/data/response_models/sponsor_respone_model/sponsor_profile_get_model.dart';

class SponsorProfileUpdateModel {
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

  SponsorProfileUpdateModel({
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

class SponsorProfileUpdateResponse {
  final String message;
  final SponsorProfileGetModel sponsor;

  SponsorProfileUpdateResponse({
    required this.message,
    required this.sponsor,
  });

  factory SponsorProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return SponsorProfileUpdateResponse(
      message: json['message'] ?? '',
      sponsor: SponsorProfileGetModel.fromJson(json['sponsor'] ?? {}),
    );
  }
}