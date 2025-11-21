import 'package:get/get.dart';
import 'package:al_sharq_conference/repository/organizer_repo/organizervenueshowrepo.dart';
import '../../data/response_models/organizer_response_models/organizer_venue_show_model.dart';
import 'package:flutter/material.dart';
class OrganizerVenueShowViewModel extends GetxController {
  final _repo = OrganizerVenueShowRepo();

  var isLoading = false.obs;
  var error = ''.obs;
  var venueData = OrganizerVenueShowModel(
    totalSessions: 0,
    liveSessions: 0,
    scheduledSessions: 0,
    events: [],
  ).obs;

  Future<void> getVenueSummary() async {
    try {
      print('🚀 OrganizerVenueShowViewModel: Starting getVenueSummary...');
      isLoading.value = true;
      error.value = '';

      final data = await _repo.getVenueSummary();
      venueData.value = data;

      print('✅ OrganizerVenueShowViewModel: Successfully loaded venue summary');
      print('📊 Total Events: ${data.events.length}');
      print('📊 Total Sessions: ${data.totalSessions}');
      print('📊 Live Sessions: ${data.liveSessions}');
      print('📊 Scheduled Sessions: ${data.scheduledSessions}');

      for (var event in data.events) {
        print('🎯 Event: ${event.name} (ID: ${event.id})');
        print('   - Description: ${event.description}');
        print('   - Location: ${event.location}');
        print('   - Total Sessions: ${event.totalSessions}');
        print('   - Sponsors: ${event.sponsors.length}');
        print('   - Exhibitors: ${event.exhibitors.length}');
      }

      Get.snackbar(
        'Success',
        'Venue data loaded successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

    } catch (e) {
      error.value = e.toString();
      print('❌ OrganizerVenueShowViewModel: Error in getVenueSummary: $e');

      Get.snackbar(
        'Error',
        'Failed to load venue data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
      print('🏁 OrganizerVenueShowViewModel: getVenueSummary completed');
    }
  }
}