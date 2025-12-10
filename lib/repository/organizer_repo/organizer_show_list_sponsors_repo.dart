import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/response_models/organizer_response_models/organizer_show_list_sponsors_model.dart';

class OrganizerShowListSponsorsRepo {
  static const String baseUrl = 'http://138.68.104.206:3000';

  Future<List<OrganizerShowListSponsorsModel>> getSponsorsList() async {
    try {
      print('📤 Sending get sponsors list request');

      final response = await http.get(
        Uri.parse('$baseUrl/sponsors/event/short-info'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData
            .map((item) => OrganizerShowListSponsorsModel.fromJson(item))
            .toList();
      } else {
        final errorBody = json.decode(response.body);
        throw Exception('Failed to load sponsors: ${errorBody['message'] ?? response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    }
    // on TimeoutException catch (e) {
    //   throw Exception('Request timeout: $e');
  //  0
  //}
  catch (e) {
      throw Exception('Failed to load sponsors: $e');
    }
  }
}