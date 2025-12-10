import 'package:al_sharq_conference/utils/api_constants.dart';
import 'package:dio/dio.dart';

import '../../data/response_models/exhibitor_models/exhibitor_dashboard_model.dart';

class ExhibitorSessionsRepository {
  final Dio _dio = Dio();

  Future<ExhibitorSessionsResponse> getExhibitorSessions(int exhibitorId) async {
    try {
      final url = ApiConstants.getExhibitorSessionsDashboard(exhibitorId);

      final response = await _dio.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ExhibitorSessionsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load sessions');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
