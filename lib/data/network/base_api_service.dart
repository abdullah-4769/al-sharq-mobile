import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

abstract class BaseApiServices {
  Future<dynamic> getGetApiServices(BuildContext context, String url);

  Future<dynamic> getPostApiServices(String url, dynamic data);
}

class NetworkApiServices extends BaseApiServices {
  @override
  Future<dynamic> getGetApiServices(BuildContext context, String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      debugPrint('Fetching with token: $token from URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10), onTimeout: () {
        debugPrint('API request timed out for $url');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request Timed Out')),
        );
        throw TimeoutException('Request Timed Out');
      });

      debugPrint('HTTP Status: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: HTTP ${response.statusCode}')),
        );
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('NetworkApiServices Error: $e');
      if (e is TimeoutException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request Timed Out')),
        );
      }
      rethrow;
    }
  }

  @override
  Future<dynamic> getPostApiServices(String url, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      debugPrint('Posting to $url with data: $data and token: $token');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Request Timed Out');
      });

      debugPrint('HTTP Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('NetworkApiServices POST Error: $e');
      rethrow;
    }
  }
}