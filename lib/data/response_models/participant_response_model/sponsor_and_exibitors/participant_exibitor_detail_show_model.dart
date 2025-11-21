// lib/data/response_models/participant_response_model/participant_exhibitor_details_model.dart

import 'package:al_sharq_conference/data/response_models/participant_response_model/sponsor_and_exibitors/participant_sponsor_detail_showmodel.dart';

class ParticipantExhibitorDetailsModel {
  final int id;
  final String name;
  final String? picUrl;
  final String description;
  final String location;
  final String? website;
  final String? email;
  final String? phone;
  final List<SocialMedia> socialMedia;
  final List<Contact> contacts;
  final List<Product> products;
  final List<Representative> representatives;
  final List<Booth> booths;

  ParticipantExhibitorDetailsModel({
    required this.id,
    required this.name,
    this.picUrl,
    required this.description,
    required this.location,
    this.website,
    this.email,
    this.phone,
    required this.socialMedia,
    required this.contacts,
    required this.products,
    required this.representatives,
    required this.booths,
  });

  factory ParticipantExhibitorDetailsModel.fromJson(Map<String, dynamic> json) {
    return ParticipantExhibitorDetailsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      picUrl: json['picUrl'],
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      website: json['website'],
      email: json['email'],
      phone: json['phone'],
      socialMedia: (json['socialMedia'] as List? ?? [])
          .map((social) => SocialMedia.fromJson(social))
          .toList(),
      contacts: (json['contacts'] as List? ?? [])
          .map((contact) => Contact.fromJson(contact))
          .toList(),
      products: (json['products'] as List? ?? [])
          .map((product) => Product.fromJson(product))
          .toList(),
      representatives: (json['representatives'] as List? ?? [])
          .map((rep) => Representative.fromJson(rep))
          .toList(),
      booths: (json['booths'] as List? ?? [])
          .map((booth) => Booth.fromJson(booth))
          .toList(),
    );
  }
}

class Booth {
  final int id;
  final String boothNumber;
  final String boothLocation;
  final String? mapLink;
  final String? distance;
  final String? openTime;

  Booth({
    required this.id,
    required this.boothNumber,
    required this.boothLocation,
    this.mapLink,
    this.distance,
    this.openTime,
  });

  factory Booth.fromJson(Map<String, dynamic> json) {
    return Booth(
      id: json['id'] ?? 0,
      boothNumber: json['boothNumber'] ?? '',
      boothLocation: json['boothLocation'] ?? '',
      mapLink: json['mapLink'],
      distance: json['distance'],
      openTime: json['openTime'],
    );
  }
}