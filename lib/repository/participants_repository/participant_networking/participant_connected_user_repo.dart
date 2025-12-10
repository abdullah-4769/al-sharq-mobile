// lib/repository/participants_repository/participant_connected_users_repo.dart

import 'package:flutter/material.dart';
import 'package:al_sharq_conference/data/network/base_api_service.dart';
import 'package:al_sharq_conference/utils/api_constants.dart';
import '../../../data/response_models/participant_response_model/participant_networking/participant_connected_usermodel.dart';

class ParticipantConnectedUsersRepo {
  final _apiService = NetworkApiServices();

  Future<List<ParticipantConnectedUsersModel>> getConnectedUsers(
      int userId,
      BuildContext context
      ) async {
    final response = await _apiService.getGetApiServices(
      context,
      ApiConstants.getConnectedUsers(userId),
    );

    final List<dynamic> responseList = response;
    return responseList
        .map((item) => ParticipantConnectedUsersModel.fromJson(item))
        .toList();
  }
}