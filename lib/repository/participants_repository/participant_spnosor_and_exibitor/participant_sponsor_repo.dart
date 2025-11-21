// lib/repository/participants_repository/participant_exhibitor_repo.dart

import 'package:flutter/material.dart';
import 'package:al_sharq_conference/data/network/base_api_service.dart';
import 'package:al_sharq_conference/utils/api_constants.dart';
import '../../../data/response_models/participant_response_model/sponsor_and_exibitors/participant_and _exibitors_response_model.dart';

class ParticipantExhibitorRepo {
  final _apiService = NetworkApiServices();

  Future<ParticipantSponsorExhibitorResponseModel> getSponsorsAndExhibitors(
      int eventId,
      BuildContext context
      ) async {
    final response = await _apiService.getGetApiServices(
      context,
      ApiConstants.getSponsorsAndExhibitors(eventId),
    );
    return ParticipantSponsorExhibitorResponseModel.fromJson(response);
  }
}