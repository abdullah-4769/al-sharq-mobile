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




// class LoginResponseModel {
//   final String token;
//   final UserModel user;
//   final int? latestEventId; // Make this nullable
//
//   LoginResponseModel({
//     required this.token,
//     required this.user,
//     this.latestEventId, // Make optional
//   });
//
//   factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
//     return LoginResponseModel(
//       token: json["token"] ?? '', // Ensure token is never null
//       user: UserModel.fromJson(json["user"]),
//       latestEventId: json["latestEventId"], // Can be null
//     );
//   }
// }
//
// class UserModel {
//   final int id;
//   final String email;
//   final String name;
//   final String? phone;
//   final String role;
//   final String? organization;
//   final String? photo;
//   final String? file;
//   final String? createdAt;
//   final String? updatedAt;
//   final int? speakerId;
//   final int? sponsorId; // Add sponsorId
//   final String? category; // Add category for sponsor
//   final String? picUrl; // Add picUrl for sponsor
//
//   UserModel({
//     required this.id,
//     required this.email,
//     required this.name,
//     this.phone,
//     required this.role,
//     this.organization,
//     this.photo,
//     this.file,
//     this.createdAt,
//     this.updatedAt,
//     this.speakerId,
//     this.sponsorId,
//     this.category,
//     this.picUrl,
//   });
//
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json["id"] ?? 0, // Default to 0 if null
//       email: json["email"] ?? '', // Default to empty string
//       name: json["name"] ?? 'User', // Default name
//       phone: json["phone"],
//       role: json["role"] ?? 'participant', // Default role
//       organization: json["organization"],
//       photo: json["photo"] ?? json["Pic_url"], // Handle both field names
//       file: json["file"],
//       createdAt: json["createdAt"],
//       updatedAt: json["updatedAt"],
//       speakerId: json["speakerId"],
//       sponsorId: json["sponsorId"], // Parse sponsorId
//       category: json["category"], // Parse category
//       picUrl: json["Pic_url"], // Parse Pic_url
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "email": email,
//       "name": name,
//       "phone": phone,
//       "role": role,
//       "organization": organization,
//       "photo": photo,
//       "file": file,
//       "createdAt": createdAt,
//       "updatedAt": updatedAt,
//       "speakerId": speakerId,
//       "sponsorId": sponsorId,
//       "category": category,
//       "Pic_url": picUrl,
//     };
//   }
// }