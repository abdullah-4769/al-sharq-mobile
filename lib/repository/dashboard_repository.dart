// lib/repository/dashboard_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:al_sharq_conference/utils/shared_preference.dart';
import '../data/response_models/dashboard_response_model.dart';

class DashboardRepository {
  static const String baseUrl = 'https://apiconnect.sharqforum.org';
// In DashboardRepository - ensure proper error handling
  Future<DashboardResponseModel> getDashboardData() async {
    try {
      final token = await SharedPrefsHelper.getAuthToken();

      if (token == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/weekly-attendance'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('DEBUG: Dashboard API Response: ${response.statusCode}');
      print('DEBUG: Dashboard API Body: ${response.body}');

      if (response.statusCode == 200  || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Ensure the response has the expected structure
        if (responseData['dailyAttendance'] == null) {
          responseData['dailyAttendance'] = [];
        }
        if (responseData['topSessions'] == null) {
          responseData['topSessions'] = [];
        }

        return DashboardResponseModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        throw Exception('Failed to load dashboard data: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error in getDashboardData: $e');
      rethrow;
    }
  }
}