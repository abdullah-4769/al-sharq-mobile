// lib/data/response_models/participant_response_model/participant_sponsor_details_show_model.dart

class ParticipantSponsorDetailsShowModel {
  final int id;
  final String name;
  final String? picUrl;
  final String description;
  final List<SocialMedia> socialMedia;
  final List<Contact> contacts;
  final List<Product> products;
  final List<Representative> representatives;

  ParticipantSponsorDetailsShowModel({
    required this.id,
    required this.name,
    this.picUrl,
    required this.description,
    required this.socialMedia,
    required this.contacts,
    required this.products,
    required this.representatives,
  });

  factory ParticipantSponsorDetailsShowModel.fromJson(Map<String, dynamic> json) {
    return ParticipantSponsorDetailsShowModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      picUrl: json['pic_url'],
      description: json['description'] ?? '',
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
    );
  }
}

class SocialMedia {
  final String name;
  final String website;

  SocialMedia({
    required this.name,
    required this.website,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      name: json['name'] ?? '',
      website: json['website'] ?? '',
    );
  }
}

class Contact {
  final String name;
  final String email;
  final String phone;

  Contact({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class Product {
  final int id;
  final String title;
  final String description;

  Product({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class Representative {
  final int id;
  final String displayTitle;
  final User user;

  Representative({
    required this.id,
    required this.displayTitle,
    required this.user,
  });

  factory Representative.fromJson(Map<String, dynamic> json) {
    return Representative(
      id: json['id'] ?? 0,
      displayTitle: json['displayTitle'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class User {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? file;
  final String? organization;

  User({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.file,
    this.organization,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      file: json['file'],
      organization: json['organization'],
    );
  }
}