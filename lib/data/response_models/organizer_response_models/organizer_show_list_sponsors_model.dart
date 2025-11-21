class OrganizerShowListSponsorsModel {
  final int id;
  final String name;
  final String email;
  final String? picUrl;

  OrganizerShowListSponsorsModel({
    required this.id,
    required this.name,
    required this.email,
    this.picUrl,
  });

  factory OrganizerShowListSponsorsModel.fromJson(Map<String, dynamic> json) {
    return OrganizerShowListSponsorsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      picUrl: json['Pic_url'] ?? json['picUrl'],
    );
  }
}