// ==================== SIGNUP MODELS ====================

class SignupRequestModel {
  final String name;
  final String email;
  final String password;
  final String role;

  SignupRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "role": role,
    };
  }
}

class SignupResponseModel {
  final String token;
  final Map<String, dynamic> user;

  SignupResponseModel({required this.token, required this.user});

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    return SignupResponseModel(
      token: json["token"],
      user: json["user"],
    );
  }
}

// ==================== COMPLETE SIGNUP MODEL ====================
/// Model for completing signup after OTP verification
class CompleteSignupResponse {
  final String message;

  CompleteSignupResponse({required this.message});

  factory CompleteSignupResponse.fromJson(Map<String, dynamic> json) {
    return CompleteSignupResponse(
      message: json['message'] ?? 'Signup completed',
    );
  }
}
// class SignupRequestModel {
//   final String name;
//   final String email;
//   final String password;
//   final String role;
//
//   SignupRequestModel({
//     required this.name,
//     required this.email,
//     required this.password,
//     required this.role,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       "name": name,
//       "email": email,
//       "password": password,
//       "role": role,
//     };
//   }
// }
//
// class SignupResponseModel {
//   final String token;
//   final Map<String, dynamic> user;
//
//   SignupResponseModel({required this.token, required this.user});
//
//   factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
//     return SignupResponseModel(
//       token: json["token"],
//       user: json["user"],
//     );
//   }
// }
