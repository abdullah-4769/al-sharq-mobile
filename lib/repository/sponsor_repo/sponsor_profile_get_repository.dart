import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/response/api_response.dart';
import '../../data/response_models/sponsor_respone_model/sponsor_profile_get_model.dart';
import '../../utils/api_constants.dart';
import '../../utils/shared_preference.dart';


class SponsorProfileGetRepository {
  Future<ApiResponse<SponsorProfileGetModel>> getSponsorProfile() async {
    try {
      final sponsorId = await SharedPrefsHelper.getSponsorId();

      if (sponsorId == null) {
        return ApiResponse.error('Sponsor ID not found. Please login again.');
      }

      final url = '${ApiConstants.sponsorBaseUrl}/sponsors/$sponsorId';
      debugPrint('🔄 Fetching sponsor profile from: $url');

      final response = await _fetchSponsorProfile(url);

      final profileData = SponsorProfileGetModel.fromJson(response);
      return ApiResponse.completed(profileData);

    } catch (e) {
      debugPrint('❌ Repository Error: $e');
      return ApiResponse.error(e.toString());
    }
  }

  Future<dynamic> _fetchSponsorProfile(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      debugPrint('🔑 Using token: ${token != null ? 'Available' : 'Not available'}');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      debugPrint('📡 Response Status: ${response.statusCode}');
      debugPrint('📦 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ HTTP Error: $e');
      rethrow;
    }
  }
}