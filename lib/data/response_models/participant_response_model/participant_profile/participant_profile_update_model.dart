class ParticipantProfileUpdateModel {
  final String name;
  final String email;
  final String? organization; // Made nullable
  final String? file;
  final String? bio;

  ParticipantProfileUpdateModel({
    required this.name,
    required this.email,
    this.organization, // Optional
    this.file,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
    };

    // Only add organization if it exists
    if (organization != null && organization!.isNotEmpty) {
      map['organization'] = organization;
    }

    if (file != null) {
      map['file'] = file;
    }

    if (bio != null && bio!.isNotEmpty) {
      map['bio'] = bio;
    }

    return map;
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
      message: json['message'] ?? 'Profile updated successfully',
      user: UpdatedUser.fromJson(json['user'] ?? {}),
    );
  }
}

class UpdatedUser {
  final int id;
  final String email;
  final String name;
  final String? organization;
  final String? file;
  final String? phone;
  final DateTime updatedAt;
  final String? bio;

  UpdatedUser({
    required this.id,
    required this.email,
    required this.name,
    this.organization,
    this.file,
    this.phone,
    required this.updatedAt,
    this.bio,
  });

  factory UpdatedUser.fromJson(Map<String, dynamic> json) {
    return UpdatedUser(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      organization: json['organization'],
      file: json['file'],
      phone: json['phone'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      bio: json['bio'],
    );
  }
}






// class ParticipantProfileUpdateModel {
//   final String name;
//   final String email;
//   final String organization;
//   final String? file;
//   final String? bio; // Added bio field
//
//   ParticipantProfileUpdateModel({
//     required this.name,
//     required this.email,
//     required this.organization,
//     this.file,
//     this.bio, // Added bio field
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'email': email,
//       'organization': organization,
//       if (file != null) 'file': file,
//       if (bio != null) 'bio': bio, // Added bio field
//     };
//   }
// }
// class ParticipantProfileUpdateResponse {
//   final String message;
//   final UpdatedUser user;
//
//   ParticipantProfileUpdateResponse({
//     required this.message,
//     required this.user,
//   });
//
//   factory ParticipantProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
//     return ParticipantProfileUpdateResponse(
//       message: json['message'],
//       user: UpdatedUser.fromJson(json['user']),
//     );
//   }
// }
//
// class UpdatedUser {
//   final int id;
//   final String email;
//   final String name;
//   final String organization;
//   final String? file;
//   final DateTime updatedAt;
//
//   UpdatedUser({
//     required this.id,
//     required this.email,
//     required this.name,
//     required this.organization,
//     required this.file,
//     required this.updatedAt,
//   });
//
//   factory UpdatedUser.fromJson(Map<String, dynamic> json) {
//     return UpdatedUser(
//       id: json['id'],
//       email: json['email'],
//       name: json['name'],
//       organization: json['organization'],
//       file: json['file'],
//       updatedAt: DateTime.parse(json['updatedAt']),
//     );
//   }
// }