import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/shared_preference.dart';

class NotificationController extends GetxController {
  var notifications = <RemoteMessage>[].obs;
  var fcmToken = ''.obs;
  var firebaseUserId = ''.obs;
  var backendUserId = 0.obs;
  var userRole = ''.obs;
  var userEmail = ''.obs;
  var userName = ''.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    _initFirebaseUser();
    _checkExistingUser();
  }

  Future<void> _initFirebaseUser() async {
    try {
      // Check if Firebase user exists
      if (_auth.currentUser == null) {
        print('👤 No Firebase user found, creating anonymous...');
        await _auth.signInAnonymously();
      }

      firebaseUserId.value = _auth.currentUser?.uid ?? '';
      print('🔑 Firebase User ID: ${firebaseUserId.value}');

      // Set up token refresh listener
      _setupTokenRefreshListener();

    } catch (e) {
      print('❌ Error initializing Firebase user: $e');
    }
  }

  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token Refreshed: ${newToken.substring(0, 20)}...');
      if (fcmToken.value.isNotEmpty) {
        _updateTokenInFirestore(fcmToken.value, newToken);
      } else {
        fcmToken.value = newToken;
        saveFCMTokenToFirestore(newToken);
      }
    });
  }

  Future<void> _checkExistingUser() async {
    try {
      // Check if we have backend user data in SharedPreferences
      final userId = await SharedPrefsHelper.getUserId();
      final userRole = await SharedPrefsHelper.getUserRole();
      final userEmail = await SharedPrefsHelper.getUserEmail();
      final userName = await SharedPrefsHelper.getUserName();

      if (userId != null && firebaseUserId.value.isNotEmpty) {
        await syncWithBackendUser(
          backendUserId: userId,
          email: userEmail ?? '',
          name: userName ?? 'User',
          role: userRole ?? 'participant',
        );
      }
    } catch (e) {
      print('❌ Error checking existing user: $e');
    }
  }

  // Sync with backend user after login
  Future<void> syncWithBackendUser({
    required int backendUserId,
    required String email,
    required String name,
    required String role,
    String? profileImage,
  }) async {
    try {
      this.backendUserId.value = backendUserId;
      this.userRole.value = role;
      this.userEmail.value = email;
      this.userName.value = name;

      if (firebaseUserId.value.isEmpty) {
        await _initFirebaseUser();
      }

      if (firebaseUserId.value.isNotEmpty) {
        // Get app version
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String appVersion = packageInfo.version;

        // Create or update user document in Firestore
        await _firestore.collection('users').doc(firebaseUserId.value).set({
          'backendUserId': backendUserId,
          'email': email,
          'name': name,
          'role': role,
          'profileImage': profileImage,
          'appVersion': appVersion,
          'lastLoginAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'platform': _getPlatform(),
        }, SetOptions(merge: true));

        print('✅ User synced with Firestore: $backendUserId ($role)');

        // Save FCM token if we have one
        if (fcmToken.value.isNotEmpty) {
          await saveFCMTokenToFirestore(fcmToken.value);
        }
      }
    } catch (e) {
      print('❌ Error syncing user with Firestore: $e');
    }
  }

  String _getPlatform() {
    if (kIsWeb) {
      return 'web';
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'android';
        case TargetPlatform.iOS:
          return 'ios';
        case TargetPlatform.macOS:
          return 'macos';
        case TargetPlatform.windows:
          return 'windows';
        case TargetPlatform.linux:
          return 'linux';
        default:
          return 'unknown';
      }
    }
  }

  Future<void> saveFCMTokenToFirestore(String token) async {
    try {
      if (firebaseUserId.value.isEmpty) {
        await _initFirebaseUser();
      }

      if (firebaseUserId.value.isEmpty) {
        print('❌ No Firebase user ID available');
        return;
      }

      final platform = _getPlatform();
      final userDocRef = _firestore.collection('users').doc(firebaseUserId.value);
      final tokenDocRef = userDocRef.collection('deviceTokens').doc(token);

      // Get app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String appVersion = packageInfo.version;
      String appBuildNumber = packageInfo.buildNumber;

      await tokenDocRef.set({
        'token': token,
        'platform': platform,
        'appVersion': appVersion,
        'buildNumber': appBuildNumber,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      }, SetOptions(merge: true));

      print('✅ FCM token saved to Firestore for $platform');

      // Update user's last active timestamp
      await userDocRef.update({
        'lastActiveAt': FieldValue.serverTimestamp(),
        'devicePlatform': platform,
        'hasActiveToken': true,
      });

    } catch (e) {
      print('❌ Error saving FCM token to Firestore: $e');
    }
  }

  Future<void> _updateTokenInFirestore(String oldToken, String newToken) async {
    try {
      if (firebaseUserId.value.isNotEmpty) {
        // Delete old token
        await _firestore
            .collection('users')
            .doc(firebaseUserId.value)
            .collection('deviceTokens')
            .doc(oldToken)
            .delete();

        print('🗑️ Old token removed from Firestore');

        // Save new token
        fcmToken.value = newToken;
        await saveFCMTokenToFirestore(newToken);
      }
    } catch (e) {
      print('❌ Error updating token: $e');
    }
  }

  Future<void> deactivateToken(String token) async {
    try {
      if (firebaseUserId.value.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(firebaseUserId.value)
            .collection('deviceTokens')
            .doc(token)
            .update({
          'isActive': false,
          'deactivatedAt': FieldValue.serverTimestamp(),
        });

        print('🔴 Token deactivated in Firestore');
      }
    } catch (e) {
      print('❌ Error deactivating token: $e');
    }
  }

  Future<void> getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        fcmToken.value = token;
        print('🔑 FCM Token obtained: ${token.substring(0, 20)}...');

        // Save to Firestore if user is logged in
        if (backendUserId.value > 0) {
          await saveFCMTokenToFirestore(token);
        }
      } else {
        print('⚠️ No FCM token available');
      }

    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  Future<void> cleanupOnLogout() async {
    try {
      print('🧹 Starting cleanup on logout...');

      if (fcmToken.value.isNotEmpty && firebaseUserId.value.isNotEmpty) {
        // Deactivate token instead of deleting (for analytics)
        await deactivateToken(fcmToken.value);
      }

      // Clear local data
      fcmToken.value = '';
      backendUserId.value = 0;
      userRole.value = '';
      userEmail.value = '';
      userName.value = '';
      notifications.clear();

      // Sign out from Firebase Auth if not anonymous
      final currentUser = _auth.currentUser;
      if (currentUser != null && !currentUser.isAnonymous) {
        await _auth.signOut();
        print('👋 Signed out from Firebase Auth');
      }

      print('✅ Cleanup completed');
    } catch (e) {
      print('❌ Error during logout cleanup: $e');
    }
  }

  // Get tokens for multiple backend user IDs
  Future<List<String>> getTokensForBackendUsers(List<int> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      List<String> allTokens = [];

      for (var userId in userIds) {
        final tokens = await getTokensForBackendUser(userId);
        allTokens.addAll(tokens);
      }

      return allTokens.toSet().toList(); // Remove duplicates
    } catch (e) {
      print('❌ Error getting tokens for multiple users: $e');
      return [];
    }
  }

  Future<List<String>> getTokensForBackendUser(int backendUserId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('backendUserId', isEqualTo: backendUserId)
          .where('isActive', isEqualTo: true)
          .get();

      List<String> tokens = [];

      for (var userDoc in snapshot.docs) {
        final tokensSnapshot = await userDoc.reference
            .collection('deviceTokens')
            .where('isActive', isEqualTo: true)
            .get();

        for (var tokenDoc in tokensSnapshot.docs) {
          tokens.add(tokenDoc.id); // Token is the document ID
        }
      }

      print('📱 Found ${tokens.length} active tokens for user $backendUserId');
      return tokens;
    } catch (e) {
      print('❌ Error getting tokens for backend user $backendUserId: $e');
      return [];
    }
  }

  Future<List<String>> getTokensForRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .where('isActive', isEqualTo: true)
          .where('hasActiveToken', isEqualTo: true)
          .get();

      List<String> tokens = [];

      for (var userDoc in snapshot.docs) {
        final tokensSnapshot = await userDoc.reference
            .collection('deviceTokens')
            .where('isActive', isEqualTo: true)
            .get();

        for (var tokenDoc in tokensSnapshot.docs) {
          tokens.add(tokenDoc.id);
        }
      }

      print('📱 Found ${tokens.length} active tokens for role $role');
      return tokens;
    } catch (e) {
      print('❌ Error getting tokens for role $role: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final usersSnapshot = await _firestore.collection('users').count().get();
      final tokensSnapshot = await _firestore.collectionGroup('deviceTokens').count().get();

      return {
        'totalUsers': usersSnapshot.count,
        'totalDevices': tokensSnapshot.count,
      };
    } catch (e) {
      print('❌ Error getting user stats: $e');
      return {'totalUsers': 0, 'totalDevices': 0};
    }
  }

  void addNotification(RemoteMessage message) {
    print('📌 Adding notification: ${message.notification?.title}');
    notifications.insert(0, message);
    print('📌 Total notifications: ${notifications.length}');
  }

  void clearNotifications() {
    print('🗑️ Clearing all notifications');
    notifications.clear();
  }
}


// // lib/notifications/notification_controller.dart
//
// import 'package:get/get.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class NotificationController extends GetxController {
//   // List to store notifications
//   var notifications = <RemoteMessage>[].obs;
//
//   // FCM Token
//   var fcmToken = ''.obs;
//
//   // Add new notification to list
//   void addNotification(RemoteMessage message) {
//     print('📌 [NotificationController] Adding notification: ${message.notification?.title}');
//     notifications.insert(0, message);
//     print('📌 [NotificationController] Total notifications: ${notifications.length}');
//   }
//
//   // Clear all notifications
//   void clearNotifications() {
//     print('🗑️  [NotificationController] Clearing all notifications');
//     notifications.clear();
//   }
//
//   // Get FCM Token
//   Future<void> getFCMToken() async {
//     try {
//       final token = await FirebaseMessaging.instance.getToken();
//       if (token != null) {
//         fcmToken.value = token;
//         print('🔑 [NotificationController] FCM Token: $token');
//       }
//     } catch (e) {
//       print('❌ [NotificationController] Error getting FCM token: $e');
//     }
//   }
// }