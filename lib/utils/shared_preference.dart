import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserRole = 'user_role';
  static const String keyUserPhone = 'user_phone';
  static const String keyUserOrganization = 'user_organization';
  static const String keyUserPhoto = 'user_photo';
  static const String keyRememberMe = 'remember_me';
  static const String keyLatestEventId = 'latest_event_id';
  static const String keySpeakerId = 'speaker_id';
  static const String keyUserBio = 'user_bio';

  // ==================== PASSWORD RESET KEYS ====================
  static const String keyPassResetId = 'pass_reset_id';
  static const String keyPassResetRole = 'pass_reset_role';
  static const String keyPassResetEmail = 'pass_reset_email';

  // Add these new methods for user image
  static const String _userImageKey = 'user_image';




  // Add to SharedPrefsHelper
  static Future<void> saveSponsorId(int sponsorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sponsorId', sponsorId);
  }

  static Future<int?> getSponsorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('sponsorId');
  }
  // ==================== PASSWORD RESET METHODS ====================
  /// Save password reset ID
  static Future<void> savePassResetId(int id) async {
    await _saveInt(keyPassResetId, id);
  }

  /// Get password reset ID
  static Future<int?> getPassResetId() async {
    return await _getInt(keyPassResetId);
  }

  /// Save password reset role
  static Future<void> savePassResetRole(String role) async {
    await _saveString(keyPassResetRole, role);
  }

  /// Get password reset role
  static Future<String?> getPassResetRole() async {
    return await _getString(keyPassResetRole);
  }

  /// Save password reset email
  static Future<void> savePassResetEmail(String email) async {
    await _saveString(keyPassResetEmail, email);
  }

  /// Get password reset email
  static Future<String?> getPassResetEmail() async {
    return await _getString(keyPassResetEmail);
  }

  /// Clear password reset data
  static Future<void> clearPassResetData() async {
    await _remove(keyPassResetId);
    await _remove(keyPassResetRole);
    await _remove(keyPassResetEmail);
  }

  // ==================== EXISTING METHODS ====================
  static Future<bool> isRegistrationTeam() async {
    final role = await getUserRole();
    return role == 'registrationteam';
  }

  static Future<void> saveUserBio(String? bio) async {
    final prefs = await SharedPreferences.getInstance();
    if (bio != null) {
      await prefs.setString('user_bio', bio);
    } else {
      await prefs.remove('user_bio');
    }
  }

  static Future<String?> getUserBio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_bio');
  }

  static Future<bool> setUserImage(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_userImageKey, imageUrl);
  }

  static Future<String?> getUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userImageKey);
  }

  static Future<bool> removeUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_userImageKey);
  }

  // Speaker ID methods
  static Future<void> saveSpeakerId(int speakerId) async {
    await _saveInt(keySpeakerId, speakerId);
  }

  static Future<int?> getSpeakerId() async {
    return await _getInt(keySpeakerId);
  }

  static Future<void> clearSpeakerId() async {
    await _remove(keySpeakerId);
  }

  // Save methods
  static Future<void> saveAuthToken(String token) async {
    await _saveString(keyAuthToken, token);
  }

  static Future<void> saveUserId(int userId) async {
    await _saveInt(keyUserId, userId);
  }

  static Future<void> saveUserName(String userName) async {
    await _saveString(keyUserName, userName);
  }

  static Future<void> saveUserEmail(String userEmail) async {
    await _saveString(keyUserEmail, userEmail);
  }

  static Future<void> saveUserRole(String userRole) async {
    await _saveString(keyUserRole, userRole);
  }

  static Future<void> saveUserPhone(String? userPhone) async {
    if (userPhone != null) {
      await _saveString(keyUserPhone, userPhone);
    }
  }

  static Future<void> saveUserOrganization(String? userOrganization) async {
    if (userOrganization != null) {
      await _saveString(keyUserOrganization, userOrganization);
    }
  }

  static Future<void> saveUserPhoto(String? userPhoto) async {
    if (userPhoto != null) {
      await _saveString(keyUserPhoto, userPhoto);
    }
  }

  static Future<void> saveLatestEventId(String? latestEventId) async {
    final prefs = await SharedPreferences.getInstance();
    if (latestEventId != null && latestEventId.isNotEmpty) {
      final eventId = int.tryParse(latestEventId);
      if (eventId != null) {
        await prefs.setInt('latest_event_id', eventId);
      } else {
        await prefs.remove('latest_event_id');
      }
    } else {
      await prefs.remove('latest_event_id');
    }
  }

  static Future<int?> getLatestEventId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('latest_event_id');
  }

  static Future<void> saveRememberMe(bool rememberMe) async {
    await _saveBool(keyRememberMe, rememberMe);
  }

  // Get methods
  static Future<String?> getAuthToken() async {
    return await _getString(keyAuthToken);
  }

  static Future<int?> getUserId() async {
    return await _getInt(keyUserId);
  }

  static Future<String?> getUserName() async {
    return await _getString(keyUserName);
  }

  static Future<String?> getUserEmail() async {
    return await _getString(keyUserEmail);
  }

  static Future<String?> getUserRole() async {
    return await _getString(keyUserRole);
  }

  static Future<String?> getUserPhone() async {
    return await _getString(keyUserPhone);
  }

  static Future<String?> getUserOrganization() async {
    return await _getString(keyUserOrganization);
  }

  static Future<String?> getUserPhoto() async {
    return await _getString(keyUserPhoto);
  }

  static Future<bool?> getRememberMe() async {
    return await _getBool(keyRememberMe);
  }

  // Clear methods
  static Future<void> clearAuthToken() async {
    await _remove(keyAuthToken);
  }

  static Future<void> clearUserData() async {
    await _remove(keyUserId);
    await _remove(keyUserName);
    await _remove(keyUserEmail);
    await _remove(keyUserRole);
    await _remove(keyUserPhone);
    await _remove(keyUserOrganization);
    await _remove(keyUserPhoto);
    await _remove(keyLatestEventId);
    await _remove(keyRememberMe);
    await _remove(keySpeakerId);
    await _remove(_userImageKey);
    await _remove('sponsorId'); // Add this
    await clearPassResetData();
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Get all user data
  static Future<Map<String, dynamic>> getAllUserData() async {
    return {
      'userId': await getUserId(),
      'userName': await getUserName(),
      'userEmail': await getUserEmail(),
      'userRole': await getUserRole(),
      'userPhone': await getUserPhone(),
      'userOrganization': await getUserOrganization(),
      'userPhoto': await getUserPhoto(),
      'latestEventId': await getLatestEventId(),
      'authToken': await getAuthToken(),
      'rememberMe': await getRememberMe() ?? false,
      'bio': await getUserBio(),
      'speakerId': await getSpeakerId(),
      'userImage': await getUserImage(),
      'speakerId': await getSpeakerId(),
      'isRegistrationTeam': await isRegistrationTeam(),
    };
  }

  // Private helper methods
  static Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<String?> _getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<int?> _getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<bool?> _getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<void> _remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}


// import 'package:shared_preferences/shared_preferences.dart';
//
// class SharedPrefsHelper {
//   static const String keyAuthToken = 'auth_token';
//   static const String keyUserId = 'user_id';
//   static const String keyUserName = 'user_name';
//   static const String keyUserEmail = 'user_email';
//   static const String keyUserRole = 'user_role';
//   static const String keyUserPhone = 'user_phone';
//   static const String keyUserOrganization = 'user_organization';
//   static const String keyUserPhoto = 'user_photo';
//   static const String keyRememberMe = 'remember_me';
//   static const String keyLatestEventId = 'latest_event_id';
//   static const String keySpeakerId = 'speaker_id';
//   static const String keyUserBio = 'user_bio';
//
//   // ==================== PASSWORD RESET KEYS ====================
//   static const String keyPassResetId = 'pass_reset_id';
//   static const String keyPassResetRole = 'pass_reset_role';
//   static const String keyPassResetEmail = 'pass_reset_email';
//
//   // Add these new methods for user image
//   static const String _userImageKey = 'user_image';
//
//   // ==================== PASSWORD RESET METHODS ====================
//   /// Save password reset ID
//   static Future<void> savePassResetId(int id) async {
//     await _saveInt(keyPassResetId, id);
//   }
//
//   /// Get password reset ID
//   static Future<int?> getPassResetId() async {
//     return await _getInt(keyPassResetId);
//   }
//
//   /// Save password reset role
//   static Future<void> savePassResetRole(String role) async {
//     await _saveString(keyPassResetRole, role);
//   }
//
//   /// Get password reset role
//   static Future<String?> getPassResetRole() async {
//     return await _getString(keyPassResetRole);
//   }
//
//   /// Save password reset email
//   static Future<void> savePassResetEmail(String email) async {
//     await _saveString(keyPassResetEmail, email);
//   }
//
//   /// Get password reset email
//   static Future<String?> getPassResetEmail() async {
//     return await _getString(keyPassResetEmail);
//   }
//
//   /// Clear password reset data
//   static Future<void> clearPassResetData() async {
//     await _remove(keyPassResetId);
//     await _remove(keyPassResetRole);
//     await _remove(keyPassResetEmail);
//   }
//
//   // ==================== EXISTING METHODS ====================
//   static Future<bool> isRegistrationTeam() async {
//     final role = await getUserRole();
//     return role == 'registrationteam';
//   }
//
//   static Future<void> saveUserBio(String? bio) async {
//     final prefs = await SharedPreferences.getInstance();
//     if (bio != null) {
//       await prefs.setString('user_bio', bio);
//     } else {
//       await prefs.remove('user_bio');
//     }
//   }
//
//   static Future<String?> getUserBio() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('user_bio');
//   }
//
//   static Future<bool> setUserImage(String imageUrl) async {
//     final prefs = await SharedPreferences.getInstance();
//     return await prefs.setString(_userImageKey, imageUrl);
//   }
//
//   static Future<String?> getUserImage() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_userImageKey);
//   }
//
//   static Future<bool> removeUserImage() async {
//     final prefs = await SharedPreferences.getInstance();
//     return await prefs.remove(_userImageKey);
//   }
//
//   // Speaker ID methods
//   static Future<void> saveSpeakerId(int speakerId) async {
//     await _saveInt(keySpeakerId, speakerId);
//   }
//
//   static Future<int?> getSpeakerId() async {
//     return await _getInt(keySpeakerId);
//   }
//
//   static Future<void> clearSpeakerId() async {
//     await _remove(keySpeakerId);
//   }
//
//   // Save methods
//   static Future<void> saveAuthToken(String token) async {
//     await _saveString(keyAuthToken, token);
//   }
//
//   static Future<void> saveUserId(int userId) async {
//     await _saveInt(keyUserId, userId);
//   }
//
//   static Future<void> saveUserName(String userName) async {
//     await _saveString(keyUserName, userName);
//   }
//
//   static Future<void> saveUserEmail(String userEmail) async {
//     await _saveString(keyUserEmail, userEmail);
//   }
//
//   static Future<void> saveUserRole(String userRole) async {
//     await _saveString(keyUserRole, userRole);
//   }
//
//   static Future<void> saveUserPhone(String? userPhone) async {
//     if (userPhone != null) {
//       await _saveString(keyUserPhone, userPhone);
//     }
//   }
//
//   static Future<void> saveUserOrganization(String? userOrganization) async {
//     if (userOrganization != null) {
//       await _saveString(keyUserOrganization, userOrganization);
//     }
//   }
//
//   static Future<void> saveUserPhoto(String? userPhoto) async {
//     if (userPhoto != null) {
//       await _saveString(keyUserPhoto, userPhoto);
//     }
//   }
//
//   static Future<void> saveLatestEventId(String? latestEventId) async {
//     final prefs = await SharedPreferences.getInstance();
//     if (latestEventId != null && latestEventId.isNotEmpty) {
//       final eventId = int.tryParse(latestEventId);
//       if (eventId != null) {
//         await prefs.setInt('latest_event_id', eventId);
//       } else {
//         await prefs.remove('latest_event_id');
//       }
//     } else {
//       await prefs.remove('latest_event_id');
//     }
//   }
//
//   static Future<int?> getLatestEventId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('latest_event_id');
//   }
//
//   static Future<void> saveRememberMe(bool rememberMe) async {
//     await _saveBool(keyRememberMe, rememberMe);
//   }
//
//   // Get methods
//   static Future<String?> getAuthToken() async {
//     return await _getString(keyAuthToken);
//   }
//
//   static Future<int?> getUserId() async {
//     return await _getInt(keyUserId);
//   }
//
//   static Future<String?> getUserName() async {
//     return await _getString(keyUserName);
//   }
//
//   static Future<String?> getUserEmail() async {
//     return await _getString(keyUserEmail);
//   }
//
//   static Future<String?> getUserRole() async {
//     return await _getString(keyUserRole);
//   }
//
//   static Future<String?> getUserPhone() async {
//     return await _getString(keyUserPhone);
//   }
//
//   static Future<String?> getUserOrganization() async {
//     return await _getString(keyUserOrganization);
//   }
//
//   static Future<String?> getUserPhoto() async {
//     return await _getString(keyUserPhoto);
//   }
//
//   static Future<bool?> getRememberMe() async {
//     return await _getBool(keyRememberMe);
//   }
//
//   // Clear methods
//   static Future<void> clearAuthToken() async {
//     await _remove(keyAuthToken);
//   }
//
//   static Future<void> clearUserData() async {
//     await _remove(keyUserId);
//     await _remove(keyUserName);
//     await _remove(keyUserEmail);
//     await _remove(keyUserRole);
//     await _remove(keyUserPhone);
//     await _remove(keyUserOrganization);
//     await _remove(keyUserPhoto);
//     await _remove(keyLatestEventId);
//     await _remove(keyRememberMe);
//     await _remove(keySpeakerId);
//     await _remove(_userImageKey);
//     await clearPassResetData();
//   }
//
//   static Future<void> clearAll() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
//
//   // Check if user is logged in
//   static Future<bool> isUserLoggedIn() async {
//     final token = await getAuthToken();
//     return token != null && token.isNotEmpty;
//   }
//
//   // Get all user data
//   static Future<Map<String, dynamic>> getAllUserData() async {
//     return {
//       'userId': await getUserId(),
//       'userName': await getUserName(),
//       'userEmail': await getUserEmail(),
//       'userRole': await getUserRole(),
//       'userPhone': await getUserPhone(),
//       'userOrganization': await getUserOrganization(),
//       'userPhoto': await getUserPhoto(),
//       'latestEventId': await getLatestEventId(),
//       'authToken': await getAuthToken(),
//       'rememberMe': await getRememberMe() ?? false,
//       'bio': await getUserBio(),
//       'speakerId': await getSpeakerId(),
//       'userImage': await getUserImage(),
//       'isRegistrationTeam': await isRegistrationTeam(),
//     };
//   }
//
//   // Private helper methods
//   static Future<void> _saveString(String key, String value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(key, value);
//   }
//
//   static Future<void> _saveInt(String key, int value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(key, value);
//   }
//
//   static Future<void> _saveBool(String key, bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(key, value);
//   }
//
//   static Future<String?> _getString(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(key);
//   }
//
//   static Future<int?> _getInt(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt(key);
//   }
//
//   static Future<bool?> _getBool(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(key);
//   }
//
//   static Future<void> _remove(String key) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(key);
//   }
// }
//
//





