import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/request_models/sponsor/sponsor_representative_model.dart';
import '../../data/response/api_response.dart';

class SponsorRepresentativeRepository {
  static const String baseUrl = 'http://138.68.104.206:3000/sponsor-related-representatives';

  Future<ApiResponse<List<SponsorRepresentative>>> getSponsorRepresentatives(int sponsorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sponsor/$sponsorId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final representatives = data.map((item) => SponsorRepresentative.fromJson(item)).toList();
        return ApiResponse.completed(representatives);
      } else {
        return ApiResponse.error('Failed to load representatives: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  Future<ApiResponse<SponsorRepresentative>> addSponsorRepresentative(SponsorRepresentativeCreate representative) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
        body: jsonEncode(representative.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse.completed(SponsorRepresentative.fromJson(data));
      } else {
        return ApiResponse.error('Failed to add representative: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  Future<ApiResponse<bool>> deleteSponsorRepresentative(int representativeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$representativeId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.completed(true);
      } else {
        return ApiResponse.error('Failed to delete representative: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}