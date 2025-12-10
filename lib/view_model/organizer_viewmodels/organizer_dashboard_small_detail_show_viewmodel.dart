import 'package:get/get.dart';
import 'package:al_sharq_conference/data/response_models/organizer_response_models/organizer_dashboard_small_detail_show_model.dart';
import 'package:flutter/material.dart';
import '../../repository/organizer_repo/organizer_dashboard_small_detail_show_repo.dart';

class OrganizerDashboardSmallDetailShowViewModel extends GetxController {
  final _repo = OrganizerDashboardSmallDetailShowRepo();

  var dashboardData = Rx<OrganizerDashboardSmallDetailShowModel?>(null);
  var isLoading = false.obs;
  var error = ''.obs;
// Add these methods to your OrganizerDashboardSmallDetailShowViewModel class
  List<OrganizerDashboardSmallDetailShowRecentUser> get displayedRecentUsers {
    final allUsers = dashboardData.value?.recentUsers ?? [];
    // Return only first 4 users for display
    return allUsers.take(4).toList();
  }

  List<OrganizerDashboardSmallDetailShowRecentUser> searchUsers(String query) {
    final allUsers = dashboardData.value?.recentUsers ?? [];
    if (query.isEmpty) return allUsers;

    return allUsers.where((user) {
      final name = user.name.toLowerCase();
      final email = user.email?.toLowerCase() ?? '';
      final organization = user.organization?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) ||
          email.contains(searchQuery) ||
          organization.contains(searchQuery);
    }).toList();
  }

  int get totalRecentUsersCount => dashboardData.value?.recentUsers.length ?? 0;
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