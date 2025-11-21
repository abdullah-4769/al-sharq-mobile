// lib/repository/event_sessions_repository.dart
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/data/network/base_api_service.dart';
import 'package:al_sharq_conference/utils/api_constants.dart';
import '../../data/response_models/participant_response_model/event_session_response_model.dart';

class EventSessionsRepository {
  final _apiService = NetworkApiServices();

  Future<EventSessionsResponseModel> getEventSessions(int eventId, BuildContext context) async {
    final response = await _apiService.getGetApiServices(
      context, // Context is required for your API service
      ApiConstants.getEventSessions(eventId),
    );
    return EventSessionsResponseModel.fromJson(response);
  }
}