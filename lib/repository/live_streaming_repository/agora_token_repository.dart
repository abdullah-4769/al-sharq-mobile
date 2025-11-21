import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AgoraTokenRepository {
  final String baseUrl = 'http://138.68.104.206:3000';

  Future<String> generateToken({
    required String channelName,
    required int uid,
    required String role, // 'host' or 'audience'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Clean the channel name - remove spaces and special characters
      final cleanChannelName = _cleanChannelName(channelName);

      final url = '$baseUrl/agora/token?channelName=$cleanChannelName&uid=$uid&role=$role';
      print('=== Generating Agora token - URL: $url ===');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('=== Agora Token API Response: ${response.statusCode} ===');
      print('=== Response Body: ${response.body} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        // Extract token from the nested structure
        final token = jsonResponse['data']?['token'];

        if (token == null) {
          throw Exception('Token not found in response. Response structure: ${jsonResponse}');
        }

        print('=== Agora token generated successfully: ${token.substring(0, 20)}... ===');
        return token;
      } else {
        throw Exception('Failed to generate token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('=== Error generating Agora token: $e ===');
      rethrow;
    }
  }

  String _cleanChannelName(String channelName) {
    // Remove spaces and special characters, keep only alphanumeric and underscores
    return channelName
        .replaceAll(RegExp(r'[^\w]'), '_') // Replace non-word characters with underscore
        .replaceAll(RegExp(r'_+'), '_') // Replace multiple underscores with single
        .toLowerCase();
  }
}


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AgoraTokenRepository {
//   final String baseUrl = 'http://138.68.104.206:3000';
//
//   Future<String> generateToken({
//     required String channelName,
//     required int uid,
//     required String role, // 'host' or 'audience'
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token');
//
//       // Clean the channel name - remove spaces and special characters
//       final cleanChannelName = _cleanChannelName(channelName);
//
//       final url = '$baseUrl/agora/token?channelName=$cleanChannelName&uid=$uid&role=$role';
//       print('=== Generating Agora token - URL: $url ===');
//
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           if (token != null) 'Authorization': 'Bearer $token',
//         },
//       ).timeout(const Duration(seconds: 10));
//
//       print('=== Agora Token API Response: ${response.statusCode} ===');
//       print('=== Response Body: ${response.body} ===');
//
//       if (response.statusCode == 200  ) {
//         final jsonResponse = jsonDecode(response.body);
//
//         // Extract token from the nested structure
//         final token = jsonResponse['data']?['token'];
//
//         if (token == null) {
//           throw Exception('Token not found in response. Response structure: ${jsonResponse}');
//         }
//
//         print('=== Agora token generated successfully: ${token.substring(0, 20)}... ===');
//         return token;
//       } else {
//         throw Exception('Failed to generate token: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       print('=== Error generating Agora token: $e ===');
//       rethrow;
//     }
//   }
//
//   String _cleanChannelName(String channelName) {
//     // Remove spaces and special characters, keep only alphanumeric and underscores
//     return channelName
//         .replaceAll(RegExp(r'[^\w]'), '_') // Replace non-word characters with underscore
//         .replaceAll(RegExp(r'_+'), '_') // Replace multiple underscores with single
//         .toLowerCase();
//   }
// }

//import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
//
// class AgoraTokenRepository {
//   final Dio _dio = Dio();
//
//   // Replace with your backend URL
//   static const String _baseUrl = 'YOUR_BACKEND_URL';
//
//   Future<String> generateToken({
//     required String channelName,
//     required int uid,
//     required String role,
//   }) async {
//     try {
//       debugPrint('=== Generating token for channel: $channelName, uid: $uid, role: $role ===');
//
//       final response = await _dio.post(
//         '$_baseUrl/generate-token',
//         data: {
//           'channelName': channelName,
//           'uid': uid,
//           'role': role,
//         },
//         options: Options(
//           headers: {
//             'Content-Type': 'application/json',
//           },
//           validateStatus: (status) => status! < 500,
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         final token = response.data['token'] as String;
//         debugPrint('=== Token generated successfully ===');
//         return token;
//       } else {
//         throw Exception('Failed to generate token: ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('=== Error generating token: $e ===');
//
//       // For testing purposes, return a test token
//       // REMOVE THIS IN PRODUCTION!
//       return _generateTestToken();
//     }
//   }
//
//   // TEMPORARY: For testing without backend
//   // REMOVE THIS IN PRODUCTION!
//   String _generateTestToken() {
//     debugPrint('=== WARNING: Using test token. Replace with real token generation! ===');
//
//     // This is a placeholder. In production, you MUST:
//     // 1. Set up a backend server
//     // 2. Generate tokens on the server using Agora's token generation libraries
//     // 3. Never expose your Agora App Certificate in the client app
//
//     return 'YOUR_TEST_TOKEN_HERE';
//   }
// }
//
// /*
// BACKEND IMPLEMENTATION EXAMPLE (Node.js):
//
// const express = require('express');
// const { RtcTokenBuilder, RtcRole } = require('agora-access-token');
//
// const app = express();
// app.use(express.json());
//
// const APP_ID = 'bc95ca12d08b4233babfb9a7803b59b7';
// const APP_CERTIFICATE = 'YOUR_APP_CERTIFICATE'; // Get from Agora Console
//
// app.post('/generate-token', (req, res) => {
//   const { channelName, uid, role } = req.body;
//
//   if (!channelName || uid === undefined) {
//     return res.status(400).json({ error: 'Missing required parameters' });
//   }
//
//   const agoraRole = role === 'host' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;
//   const expirationTimeInSeconds = 3600; // 1 hour
//   const currentTimestamp = Math.floor(Date.now() / 1000);
//   const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;
//
//   const token = RtcTokenBuilder.buildTokenWithUid(
//     APP_ID,
//     APP_CERTIFICATE,
//     channelName,
//     uid,
//     agoraRole,
//     privilegeExpiredTs
//   );
//
//   return res.json({ token });
// });
//
// app.listen(3000, () => {
//   console.log('Token server running on port 3000');
// });
//
// */