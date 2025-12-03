import 'package:dio/dio.dart';
import 'package:al_sharq_conference/data/response_models/participant_detail_response_model.dart';

import '../utils/api_constants.dart';

class ParticipantDetailRepository {
  final Dio _dio = Dio();

  Future<ParticipantDetailResponse> getParticipantById(int userId) async {
    try {
      final response = await _dio.get(
        ApiConstants.participantById(userId),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ParticipantDetailResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load participant details');
      }
    } catch (e) {
      rethrow;
    }
  }
}