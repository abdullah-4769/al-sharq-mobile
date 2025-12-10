class OrganizerShowListExhibitorsModel {
  final int id;
  final String name;
  final String email;
  final String? picUrl;

  OrganizerShowListExhibitorsModel({
    required this.id,
    required this.name,
    required this.email,
    this.picUrl,
  });

  factory OrganizerShowListExhibitorsModel.fromJson(Map<String, dynamic> json) {
    return OrganizerShowListExhibitorsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      picUrl: json['picUrl'],
    );
  }
}