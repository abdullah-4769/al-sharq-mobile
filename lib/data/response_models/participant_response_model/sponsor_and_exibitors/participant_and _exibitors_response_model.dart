// lib/data/response_models/participant_response_model/participant_sponsor_model.dart

class ParticipantSponsorModel {
  final int id;
  final String name;
  final String description;
  final String category;

  ParticipantSponsorModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  factory ParticipantSponsorModel.fromJson(Map<String, dynamic> json) {
    return ParticipantSponsorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
    };
  }
}

// lib/data/response_models/participant_response_model/participant_exhibitor_model.dart

class ParticipantExhibitorModel {
  final int id;
  final String name;
  final String description;
  final String location;

  ParticipantExhibitorModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
  });

  factory ParticipantExhibitorModel.fromJson(Map<String, dynamic> json) {
    return ParticipantExhibitorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
    };
  }
}

// lib/data/response_models/participant_response_model/participant_sponsor_exhibitor_response_model.dart

class ParticipantSponsorExhibitorResponseModel {
  final List<ParticipantSponsorModel> sponsors;
  final List<ParticipantExhibitorModel> exhibitors;

  ParticipantSponsorExhibitorResponseModel({
    required this.sponsors,
    required this.exhibitors,
  });

  factory ParticipantSponsorExhibitorResponseModel.fromJson(Map<String, dynamic> json) {
    final sponsorsList = json['sponsors'] as List? ?? [];
    final exhibitorsList = json['exhibitors'] as List? ?? [];

    return ParticipantSponsorExhibitorResponseModel(
      sponsors: sponsorsList
          .map((sponsor) => ParticipantSponsorModel.fromJson(sponsor))
          .toList(),
      exhibitors: exhibitorsList
          .map((exhibitor) => ParticipantExhibitorModel.fromJson(exhibitor))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sponsors': sponsors.map((sponsor) => sponsor.toJson()).toList(),
      'exhibitors': exhibitors.map((exhibitor) => exhibitor.toJson()).toList(),
    };
  }
}