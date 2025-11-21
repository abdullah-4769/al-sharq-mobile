// lib/view_model/participant_viewmodel/participant_sponsor_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/response_models/participant_response_model/sponsor_and_exibitors/participant_and _exibitors_response_model.dart';
import '../../../repository/participants_repository/participant_spnosor_and_exibitor/participant_exibitor_repo.dart';
import '../../../utils/shared_preference.dart';

class ParticipantSponsorViewModel extends GetxController {
  final ParticipantSponsorRepo _repo = ParticipantSponsorRepo();

  final Rx<ParticipantSponsorExhibitorResponseModel?> _sponsorsExhibitorsData =
  Rx<ParticipantSponsorExhibitorResponseModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedTab = 0.obs; // 0: All, 1: Gold Sponsors, 2: Silver Sponsors

  // Getters
  List<ParticipantSponsorModel> get allSponsors =>
      _sponsorsExhibitorsData.value?.sponsors ?? [];

  List<ParticipantExhibitorModel> get allExhibitors =>
      _sponsorsExhibitorsData.value?.exhibitors ?? [];

  // Filtered sponsors based on category and search
  List<ParticipantSponsorModel> get filteredSponsors {
    List<ParticipantSponsorModel> sponsors = allSponsors;

    // Filter by category based on selected tab
    if (selectedTab.value == 1) {
      sponsors = sponsors.where((sponsor) => sponsor.category.toLowerCase() == 'gold').toList();
    } else if (selectedTab.value == 2) {
      sponsors = sponsors.where((sponsor) => sponsor.category.toLowerCase() == 'silver').toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      sponsors = sponsors.where((sponsor) =>
      sponsor.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          sponsor.description.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    return sponsors;
  }

  // Filtered exhibitors based on search
  List<ParticipantExhibitorModel> get filteredExhibitors {
    List<ParticipantExhibitorModel> exhibitors = allExhibitors;

    if (searchQuery.value.isNotEmpty) {
      exhibitors = exhibitors.where((exhibitor) =>
      exhibitor.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          exhibitor.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          exhibitor.location.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    return exhibitors;
  }

  // Get gold sponsors
  List<ParticipantSponsorModel> get goldSponsors =>
      allSponsors.where((sponsor) => sponsor.category.toLowerCase() == 'gold').toList();

  // Get silver sponsors
  List<ParticipantSponsorModel> get silverSponsors =>
      allSponsors.where((sponsor) => sponsor.category.toLowerCase() == 'silver').toList();

  Future<void> fetchSponsorsAndExhibitors(BuildContext context) async {
    try {
      print('=== Fetching sponsors and exhibitors ===');
      isLoading.value = true;
      errorMessage.value = '';

      final eventId = await SharedPrefsHelper.getLatestEventId();
      if (eventId == null) {
        throw Exception('No event ID found. Please login again.');
      }

      final data = await _repo.getSponsorsAndExhibitors(eventId, context);
      _sponsorsExhibitorsData.value = data;

      print('=== Successfully loaded ${data.sponsors.length} sponsors and ${data.exhibitors.length} exhibitors ===');
    } catch (e) {
      errorMessage.value = 'Failed to load sponsors and exhibitors: $e';
      print('=== Error loading sponsors and exhibitors: $e ===');

      Get.snackbar(
        'Error',
        'Failed to load sponsors and exhibitors: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) {
    searchQuery.value = query;
    print('=== Search completed. Found ${filteredSponsors.length} sponsors and ${filteredExhibitors.length} exhibitors for query: "$query" ===');
  }

  void changeTab(int tabIndex) {
    selectedTab.value = tabIndex;
    print('=== Tab changed to: $tabIndex ===');
  }

  void clearData() {
    _sponsorsExhibitorsData.value = null;
    errorMessage.value = '';
    searchQuery.value = '';
    selectedTab.value = 0;
  }
}