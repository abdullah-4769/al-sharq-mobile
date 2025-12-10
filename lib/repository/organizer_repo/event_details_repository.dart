// lib/repository/organizer_repository/event_details_repository.dart

import 'package:flutter/material.dart';
import 'package:al_sharq_conference/data/network/base_api_service.dart';
import 'package:al_sharq_conference/data/response_models/organizer_response_models/event_details_model.dart';
import 'package:al_sharq_conference/utils/api_constants.dart';

class EventDetailsRepository {
  final _apiService = NetworkApiServices();

  Future<EventDetailsModel> getEventDetails(BuildContext context, int eventId) async {
    final response = await _apiService.getGetApiServices(
      context, // Add context parameter
      ApiConstants.getEventDetails(eventId),
    );
    return EventDetailsModel.fromJson(response);
  }
}