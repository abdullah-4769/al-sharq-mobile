import 'package:al_sharq_conference/utils/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:al_sharq_conference/data/response_models/registration_team_model/participant_response_model.dart';

class ParticipantRepository {
  final Dio _dio = Dio();

  Future<ParticipantResponse> getParticipants({
    int page = 1,
    int limit = 10,
    String search = '',
    // Remove filter parameter if not supported by API
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.participants,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search.isNotEmpty) 'search': search,
          // Remove filter parameter if API doesn't support it
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ParticipantResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load participants');
      }
    } catch (e) {
      rethrow;
    }
  }
}