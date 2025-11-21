class LoginResponseModel {
  final String token;
  final UserModel user;
  final int latestEventId;

  LoginResponseModel({
    required this.token,
    required this.user,
    required this.latestEventId,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json["token"],
      user: UserModel.fromJson(json["user"]),
      latestEventId: json["latestEventId"],
    );
  }
}

class UserModel {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final String role;
  final String? organization;
  final String? photo;
  final String? file;
  final String createdAt;
  final String updatedAt;
  final int? speakerId; // Add this field

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.organization,
    required this.photo,
    required this.file,
    required this.createdAt,
    required this.updatedAt,
    this.speakerId, // Add this parameter
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      email: json["email"],
      name: json["name"],
      phone: json["phone"],
      role: json["role"],
      organization: json["organization"],
      photo: json["photo"],
      file: json["file"],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      speakerId: json["speakerId"], // Parse speakerId from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "phone": phone,
      "role": role,
      "organization": organization,
      "photo": photo,
      "file": file,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "speakerId": speakerId, // Include speakerId in toJson
    };
  }
}