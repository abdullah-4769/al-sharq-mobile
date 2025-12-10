class OrganizerAllSpeakerGetModel {
  final int speakerId;
  final List<String> designations;
  final OrganizerSpeakerUser user;

  OrganizerAllSpeakerGetModel({
    required this.speakerId,
    required this.designations,
    required this.user,
  });

  factory OrganizerAllSpeakerGetModel.fromJson(Map<String, dynamic> json) {
    return OrganizerAllSpeakerGetModel(
      speakerId: json['speakerid'] ?? 0,
      designations: (json['designations'] as List? ?? []).map((item) => item.toString()).toList(),
      user: OrganizerSpeakerUser.fromJson(json['user'] ?? {}),
    );
  }

  String get displayName => user.name;
  String get email => user.email;
  String? get imageUrl => user.file;

  String get designationsText {
    if (designations.isEmpty) return 'No designation';
    if (designations.length == 1) return designations.first;
    return '${designations.first} +${designations.length - 1} more';
  }
}

class OrganizerSpeakerUser {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? file;

  OrganizerSpeakerUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.file,
  });

  factory OrganizerSpeakerUser.fromJson(Map<String, dynamic> json) {
    return OrganizerSpeakerUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      file: json['file'],
    );
  }
}