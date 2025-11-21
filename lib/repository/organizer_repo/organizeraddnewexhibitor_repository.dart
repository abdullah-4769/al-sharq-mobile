import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/request_models/organizer/organizeraddnewexhibitor_model.dart';
import '../../utils/api_constants.dart';

class OrganizerAddNewExhibitorRepository {
  Future<OrganizerAddNewExhibitorResponseModel> addNewExhibitor(
      OrganizerAddNewExhibitorRequestModel exhibitorData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/exhibiteros'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(exhibitorData.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return OrganizerAddNewExhibitorResponseModel.fromJson(responseData);
      } else {
        throw Exception('Failed to add exhibitor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add exhibitor: $e');
    }
  }
}