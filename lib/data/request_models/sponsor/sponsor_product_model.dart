class SponsorProduct {
  final int id;
  final int sponsorId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  SponsorProduct({
    required this.id,
    required this.sponsorId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SponsorProduct.fromJson(Map<String, dynamic> json) {
    return SponsorProduct(
      id: json['id'],
      sponsorId: json['sponsorId'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sponsorId': sponsorId,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SponsorProductCreate {
  final int sponsorId;
  final String title;
  final String description;

  SponsorProductCreate({
    required this.sponsorId,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'sponsorId': sponsorId,
      'title': title,
      'description': description,
    };
  }
}