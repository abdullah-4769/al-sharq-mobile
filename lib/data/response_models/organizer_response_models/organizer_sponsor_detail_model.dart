class OrganizerSponsorDetailModel {
  final int id;
  final String name;
  final String? picUrl;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrganizerSponsorSocialMedia> socialMedia;
  final List<OrganizerSponsorContact> contacts;
  final List<OrganizerSponsorProduct> products;
  final List<OrganizerSponsorRepresentative> representatives;

  OrganizerSponsorDetailModel({
    required this.id,
    required this.name,
    this.picUrl,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.socialMedia,
    required this.contacts,
    required this.products,
    required this.representatives,
  });

  factory OrganizerSponsorDetailModel.fromJson(Map<String, dynamic> json) {
    return OrganizerSponsorDetailModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      picUrl: json['pic_url'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      socialMedia: (json['socialMedia'] as List? ?? [])
          .map((social) => OrganizerSponsorSocialMedia.fromJson(social))
          .toList(),
      contacts: (json['contacts'] as List? ?? [])
          .map((contact) => OrganizerSponsorContact.fromJson(contact))
          .toList(),
      products: (json['products'] as List? ?? [])
          .map((product) => OrganizerSponsorProduct.fromJson(product))
          .toList(),
      representatives: (json['representatives'] as List? ?? [])
          .map((rep) => OrganizerSponsorRepresentative.fromJson(rep))
          .toList(),
    );
  }
}

class OrganizerSponsorSocialMedia {
  final String name;
  final String website;

  OrganizerSponsorSocialMedia({
    required this.name,
    required this.website,
  });

  factory OrganizerSponsorSocialMedia.fromJson(Map<String, dynamic> json) {
    return OrganizerSponsorSocialMedia(
      name: json['name'] ?? '',
      website: json['website'] ?? '',
    );
  }
}

class OrganizerSponsorContact {
  final String name;
  final String email;
  final String phone;

  OrganizerSponsorContact({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory OrganizerSponsorContact.fromJson(Map<String, dynamic> json) {
    return OrganizerSponsorContact(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class OrganizerSponsorProduct {
  final int id;
  final int sponsorId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrganizerSponsorProduct({
    required this.id,
    required this.sponsorId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganizerSponsorProduct.fromJson(Map<String, dynamic> json) {
    return OrganizerSponsorProduct(
      id: json['id'] ?? 0,
      sponsorId: json['sponsorId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class OrganizerSponsorRepresentative {
  final int id;
  final int userId;
  final String displayTitle;
  final int sponsorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final OrganizerSponsorRepresentativeUser user;

  OrganizerSponsorRepresentative({
    required this.id,
    required this.userId,
    required this.displayTitle,
    required this.sponsorId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory OrganizerSponsorRepresentative.fromJson(Map<String, dynamic> json) {
    return OrganizerSponsorRepresentative(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      displayTitle: json['displayTitle'] ?? '',
      sponsorId: json['sponsorId'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      user: OrganizerSponsorRepresentativeUser.fromJson(json['user'] ?? {}),
    );
  }
}

class OrganizerSponsorRepresentativeUser {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final String? file;
  final String role;
  final String? organization;

  OrganizerSponsorRepresentativeUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.file,
    required this.role,
    this.organization,
  });

  factory OrganizerSponsorRepresentativeUser.fromJson(Map<String, dynamic> json) {
    return OrganizerSponsorRepresentativeUser(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      file: json['file'],
      role: json['role'] ?? '',
      organization: json['organization'],
    );
  }
}