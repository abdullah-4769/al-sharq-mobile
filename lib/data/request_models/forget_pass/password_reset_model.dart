// ==================== PASSWORD RESET MODELS ====================

/// User model for password reset
class PasswordResetUser {
  final int? id;
  final String? name;
  final String? email;
  final String? role;

  PasswordResetUser({
    this.id,
    this.name,
    this.email,
    this.role,
  });

  factory PasswordResetUser.fromJson(Map<String, dynamic> json) {
    return PasswordResetUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };
}

/// Response model for sending OTP
class SendOTPResponse {
  final String message;
  final PasswordResetUser? user;

  SendOTPResponse({
    required this.message,
    this.user,
  });

  factory SendOTPResponse.fromJson(Map<String, dynamic> json) {
    return SendOTPResponse(
      message: json['message'] ?? '',
      user: json['user'] != null
          ? PasswordResetUser.fromJson(json['user'])
          : null,
    );
  }
}

/// Response model for OTP verification
class VerifyOTPResponse {
  final String message;

  VerifyOTPResponse({required this.message});

  factory VerifyOTPResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOTPResponse(
      message: json['message'] ?? '',
    );
  }
}

/// Response model for password reset
class ResetPasswordResponse {
  final String message;
  final int? id;
  final String? name;
  final String? email;

  ResetPasswordResponse({
    required this.message,
    this.id,
    this.name,
    this.email,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      // Handle both cases: message field might be missing
      message: json['message'] ?? 'Password updated successfully',
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}