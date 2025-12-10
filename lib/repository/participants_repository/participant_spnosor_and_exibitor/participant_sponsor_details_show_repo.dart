// lib/repository/participants_repository/participant_sponsor_details_show_repo.dart

import 'package:flutter/material.dart';
import 'package:al_sharq_conference/data/network/base_api_service.dart';
import 'package:al_sharq_conference/utils/api_constants.dart';
import '../../../data/response_models/participant_response_model/sponsor_and_exibitors/participant_sponsor_detail_showmodel.dart';

class ParticipantSponsorDetailsShowRepo {
  final _apiService = NetworkApiServices();

  Future<ParticipantSponsorDetailsShowModel> getSponsorDetails(
      int sponsorId,
      BuildContext context
      ) async {
    final response = await _apiService.getGetApiServices(
      context,
      ApiConstants.getSponsorDetails(sponsorId),
    );
    return ParticipantSponsorDetailsShowModel.fromJson(response);
  }
}