import 'package:get/get.dart';
import '../../data/request_models/organizer/organizer_create_event_venue_model.dart';
import '../../repository/organizer_repo/organizer_create_event_venue_repo.dart';
import 'package:flutter/material.dart';
class OrganizerCreateEventVenueViewModel extends GetxController {
  final _repo = OrganizerCreateEventVenueRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var success = false.obs;
  var eventData = OrganizerCreateEventVenueModel(
    id: 0,
    title: '',
    description: '',
    location: '',
    googleMapLink: '',
    joinToken: '',
    mapstatus: false,
    sponsors: [],
    exhibitors: [],
  ).obs;

  Future<bool> createEvent(Map<String, dynamic> data) async {
    try {
      print('🚀 Starting createEvent...');
      isLoading.value = true;
      error.value = '';
      success.value = false;

      final response = await _repo.createEvent(data);
      eventData.value = response;
      success.value = true;

      print('✅ Event created successfully - ID: ${response.id}');
      return true;
    } catch (e) {
      error.value = e.toString();
      print('❌ Error in createEvent: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateEvent(int eventId, Map<String, dynamic> data) async {
    try {
      print('🚀 Starting updateEvent for ID: $eventId');
      isLoading.value = true;
      error.value = '';
      success.value = false;

      final response = await _repo.updateEvent(eventId, data);
      eventData.value = response;
      success.value = true;

      print('✅ Event updated successfully - ID: ${response.id}');
      return true;
    } catch (e) {
      error.value = e.toString();
      print('❌ Error in updateEvent: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getEvent(int eventId) async {
    try {
      print('🚀 Starting getEvent for ID: $eventId');
      isLoading.value = true;
      error.value = '';

      final response = await _repo.getEvent(eventId);
      eventData.value = response;

      print('✅ Event fetched successfully - ID: ${response.id}');
    } catch (e) {
      error.value = e.toString();
      print('❌ Error in getEvent: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Clean up any resources if needed
    super.onClose();
  }
}