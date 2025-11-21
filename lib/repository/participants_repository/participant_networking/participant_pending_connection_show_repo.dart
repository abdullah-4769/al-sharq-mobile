// lib/repository/participants_repository/participant_pending_connection_show_repo.dart

import 'package:flutter/material.dart';
import 'package:al_sharq_conference/data/network/base_api_service.dart';
import 'package:al_sharq_conference/utils/api_constants.dart';
import '../../../data/response_models/participant_response_model/participant_networking/participant_pending_connection_show_user_model.dart';

class ParticipantPendingConnectionShowRepo {
  final _apiService = NetworkApiServices();

  Future<List<ParticipantPendingConnectionShowModel>> getPendingConnections(
      int userId,
      BuildContext context
      ) async {
    final response = await _apiService.getGetApiServices(
      context,
      ApiConstants.getPendingConnections(userId),
    );

    final List<dynamic> responseList = response;
    return responseList
        .map((item) => ParticipantPendingConnectionShowModel.fromJson(item))
        .toList();
  }
}