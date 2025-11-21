import 'package:get/get.dart';
import 'package:al_sharq_conference/data/response_models/organizer_response_models/organizer_dashboard_small_detail_show_model.dart';
import 'package:flutter/material.dart';
import '../../repository/organizer_repo/organizer_dashboard_small_detail_show_repo.dart';

class OrganizerDashboardSmallDetailShowViewModel extends GetxController {
  final _repo = OrganizerDashboardSmallDetailShowRepo();

  var dashboardData = Rx<OrganizerDashboardSmallDetailShowModel?>(null);
  var isLoading = false.obs;
  var error = ''.obs;

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      error.value = '';

      final data = await _repo.getDashboardData();
      dashboardData.value = data;

    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods to check if we have data
  bool get hasData => dashboardData.value != null;

  // Get formatted numbers for display
  String get formattedTotalRegistrations =>
      dashboardData.value?.countTotalRegistration.toString() ?? '0';

  String get formattedTotalCheckins =>
      dashboardData.value?.totalCheckin.toString() ?? '0';

  String get formattedActiveSessions =>
      dashboardData.value?.totalActiveSession.toString() ?? '0';

  String get formattedTotalSpeakers =>
      dashboardData.value?.totalSpeaker.toString() ?? '0';

  String get formattedTotalSponsors =>
      dashboardData.value?.totalSponsor.toString() ?? '0';

  String get formattedTotalExhibitors =>
      dashboardData.value?.totalExhibitor.toString() ?? '0';

  // Get recent users
  List<OrganizerDashboardSmallDetailShowRecentUser> get recentUsers =>
      dashboardData.value?.recentUsers ?? [];

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }
}