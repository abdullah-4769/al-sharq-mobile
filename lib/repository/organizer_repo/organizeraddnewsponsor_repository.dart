import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/request_models/organizer/organizeraddnewsponsor_model.dart';
import '../../utils/api_constants.dart';


class OrganizerAddNewSponsorRepository {
  Future<OrganizerAddNewSponsorResponseModel> addNewSponsor(
      OrganizerAddNewSponsorRequestModel sponsorData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/sponsors'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(sponsorData.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return OrganizerAddNewSponsorResponseModel.fromJson(responseData);
      } else {
        throw Exception('Failed to add sponsor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add sponsor: $e');
    }
  }
}