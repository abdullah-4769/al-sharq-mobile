class OrganizerExhibitorShowModel {
  final List<OrganizerExhibitor> exhibitors;

  OrganizerExhibitorShowModel({required this.exhibitors});

  factory OrganizerExhibitorShowModel.fromJson(List<dynamic> json) {
    return OrganizerExhibitorShowModel(
      exhibitors: json.map((item) => OrganizerExhibitor.fromJson(item)).toList(),
    );
  }
}

class OrganizerExhibitor {
  final int id;
  final String name;
  final String? picUrl;
  final String description;
  final String location;
  final String? website;
  final String? email;
  final String? phone;
  final String? linkedin;
  final String? twitter;
  final String? youtube;
  final String role;
  final String createdAt;
  final String updatedAt;
  final List<ExhibitorProduct> products;
  final List<ExhibitorRepresentative> representatives;
  final List<ExhibitorBooth> booths;

  OrganizerExhibitor({
    required this.id,
    required this.name,
    this.picUrl,
    required this.description,
    required this.location,
    this.website,
    this.email,
    this.phone,
    this.linkedin,
    this.twitter,
    this.youtube,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.products,
    required this.representatives,
    required this.booths,
  });

  factory OrganizerExhibitor.fromJson(Map<String, dynamic> json) {
    return OrganizerExhibitor(
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
      role: json['role'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      products: (json['products'] as List<dynamic>?)
          ?.map((item) => ExhibitorProduct.fromJson(item))
          .toList() ?? [],
      representatives: (json['representatives'] as List<dynamic>?)
          ?.map((item) => ExhibitorRepresentative.fromJson(item))
          .toList() ?? [],
      booths: (json['booths'] as List<dynamic>?)
          ?.map((item) => ExhibitorBooth.fromJson(item))
          .toList() ?? [],
    );
  }

  String get boothInfo {
    if (booths.isEmpty) return 'No booth assigned';
    final booth = booths.first;
    return '${booth.boothNumber} • ${booth.boothLocation}';
  }

  String get productsCount => '${products.length} products';
}

class ExhibitorProduct {
  final int id;
  final int exhibitorId;
  final String title;
  final String description;
  final String createdAt;
  final String updatedAt;

  ExhibitorProduct({
    required this.id,
    required this.exhibitorId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExhibitorProduct.fromJson(Map<String, dynamic> json) {
    return ExhibitorProduct(
      id: json['id'],
      exhibitorId: json['exhibitorId'],
      title: json['title'],
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class ExhibitorRepresentative {
  final int id;
  final int exhibitorId;
  final int userId;
  final String displayTitle;
  final String createdAt;
  final String updatedAt;

  ExhibitorRepresentative({
    required this.id,
    required this.exhibitorId,
    required this.userId,
    required this.displayTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExhibitorRepresentative.fromJson(Map<String, dynamic> json) {
    return ExhibitorRepresentative(
      id: json['id'],
      exhibitorId: json['exhibitorId'],
      userId: json['userId'],
      displayTitle: json['displayTitle'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class ExhibitorBooth {
  final int id;
  final int exhibitorId;
  final String boothNumber;
  final String boothLocation;
  final String? mapLink;
  final String? distance;
  final String? openTime;
  final String createdAt;
  final String updatedAt;

  ExhibitorBooth({
    required this.id,
    required this.exhibitorId,
    required this.boothNumber,
    required this.boothLocation,
    this.mapLink,
    this.distance,
    this.openTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExhibitorBooth.fromJson(Map<String, dynamic> json) {
    return ExhibitorBooth(
      id: json['id'],
      exhibitorId: json['exhibitorId'],
      boothNumber: json['boothNumber'],
      boothLocation: json['boothLocation'],
      mapLink: json['mapLink'],
      distance: json['distance'],
      openTime: json['openTime'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}