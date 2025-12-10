// lib/repository/participants_repository/participant_connection_request_handle_repo.dart

import 'package:flutter/material.dart';
import 'package:al_sharq_conference/data/network/base_api_service.dart';
import 'package:al_sharq_conference/utils/api_constants.dart';
import '../../../data/request_models/participant_Request_models/Participant_networking/participant_connection_request_handle_model.dart';

class ParticipantConnectionRequestHandleRepo {
  final _apiService = NetworkApiServices();

  Future<ParticipantConnectionRequestHandleModel> handleConnectionRequest(
      int requestId,
      String status,
      BuildContext context,
      ) async {
    // Use PATCH method since API requires PATCH
    final response = await _apiService.patchApiResponse(
      context,
      ApiConstants.handleConnectionRequest(requestId),
      {'status': status},
    );
    return ParticipantConnectionRequestHandleModel.fromJson(response);
  }
}