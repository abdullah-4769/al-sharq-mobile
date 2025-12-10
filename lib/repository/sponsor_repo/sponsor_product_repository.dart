import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/request_models/sponsor/sponsor_product_model.dart';
import '../../data/response/api_response.dart';

class SponsorProductRepository {
  static const String baseUrl = 'http://138.68.104.206:3000/sponsor-related/products';

  Future<ApiResponse<List<SponsorProduct>>> getSponsorProducts(int sponsorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sponsor/$sponsorId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200   || response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        final products = data.map((item) => SponsorProduct.fromJson(item)).toList();
        return ApiResponse.completed(products);
      } else {
        return ApiResponse.error('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  Future<ApiResponse<SponsorProduct>> addSponsorProduct(SponsorProductCreate product) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getHeaders(),
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse.completed(SponsorProduct.fromJson(data));
      } else {
        return ApiResponse.error('Failed to add product: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  Future<ApiResponse<SponsorProduct>> updateSponsorProduct(int productId, SponsorProductCreate product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$productId'),
        headers: await _getHeaders(),
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode ==  200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ApiResponse.completed(SponsorProduct.fromJson(data));
      } else {
        return ApiResponse.error('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  Future<ApiResponse<bool>> deleteSponsorProduct(int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$productId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200  || response.statusCode == 201) {
        return ApiResponse.completed(true);
      } else {
        return ApiResponse.error('Failed to delete product: ${response.statusCode}');
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