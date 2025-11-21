class ParticipantProfileUpdateModel {
  final String name;
  final String email;
  final String organization;
  final String? file;

  ParticipantProfileUpdateModel({
    required this.name,
    required this.email,
    required this.organization,
    this.file,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'organization': organization,
      if (file != null) 'file': file,
    };
  }
}

class ParticipantProfileUpdateResponse {
  final String message;
  final UpdatedUser user;

  ParticipantProfileUpdateResponse({
    required this.message,
    required this.user,
  });

  factory ParticipantProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ParticipantProfileUpdateResponse(
      message: json['message'],
      user: UpdatedUser.fromJson(json['user']),
    );
  }
}

class UpdatedUser {
  final int id;
  final String email;
  final String name;
  final String organization;
  final String? file;
  final DateTime updatedAt;

  UpdatedUser({
    required this.id,
    required this.email,
    required this.name,
    required this.organization,
    required this.file,
    required this.updatedAt,
  });

  factory UpdatedUser.fromJson(Map<String, dynamic> json) {
    return UpdatedUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      organization: json['organization'],
      file: json['file'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}