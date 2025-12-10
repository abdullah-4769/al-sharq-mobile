// lib/view_model/dashboard_view_model.dart
import 'package:get/get.dart';
import '../repository/dashboard_repository.dart';
import '../data/response_models/dashboard_response_model.dart';

class DashboardViewModel extends GetxController {
  final DashboardRepository _repository = DashboardRepository();

  // Make these Rx variables
  final dashboardData = Rxn<DashboardResponseModel>();
  final isLoading = false.obs;
  final error = ''.obs;
  final lastUpdated = 'Just now'.obs;

  @override
  void onInit() {
    super.onInit();
    // Optional: Fetch data when viewmodel is initialized
    // fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      error.value = '';
      dashboardData.value = null; // Clear old data

      print('DEBUG: Starting to fetch dashboard data...');
      final response = await _repository.getDashboardData();
      print('DEBUG: Dashboard data received from repository');

      dashboardData.value = response;
      lastUpdated.value = 'Just now';
      print('DEBUG: Dashboard data loaded successfully into ViewModel');

    } catch (e) {
      error.value = e.toString();
      print('DEBUG: ViewModel error: $e');
    } finally {
      isLoading.value = false;
      print('DEBUG: isLoading set to false');
    }
  }

  void refreshData() {
    fetchDashboardData();
  }

  void clearError() {
    error.value = '';
  }

  // Calculate total checked in today
  int getCheckedInToday() {
    if (dashboardData.value == null || dashboardData.value!.dailyAttendance.isEmpty) {
      return 0;
    }

    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayAttendance = dashboardData.value!.dailyAttendance.firstWhere(
          (attendance) => attendance.date == today,
      orElse: () => DailyAttendance(date: today, count: 0),
    );

    return todayAttendance.count;
  }

  // Calculate total participants (sum of all attendance)
  int getTotalParticipants() {
    if (dashboardData.value == null || dashboardData.value!.dailyAttendance.isEmpty) {
      return 0;
    }

    return dashboardData.value!.dailyAttendance.fold(
        0,
            (sum, attendance) => sum + attendance.count
    );
  }

  // Get attendance data for charts
  List<double> getAttendanceChartData() {
    if (dashboardData.value == null || dashboardData.value!.dailyAttendance.isEmpty) {
      return List.filled(7, 0.0);
    }

    return dashboardData.value!.dailyAttendance
        .take(7) // Take only first 7 days
        .map((attendance) => attendance.count.toDouble())
        .toList();
  }

  // Get day labels for charts
  List<String> getDayLabels() {
    if (dashboardData.value == null || dashboardData.value!.dailyAttendance.isEmpty) {
      return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    }

    // Take only first 7 days and format them
    return dashboardData.value!.dailyAttendance
        .take(7)
        .map((attendance) {
      try {
        final date = DateTime.parse(attendance.date);
        return _getDayAbbreviation(date.weekday);
      } catch (e) {
        return 'Day';
      }
    })
        .toList();
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case DateTime.sunday: return 'Sun';
      case DateTime.monday: return 'Mon';
      case DateTime.tuesday: return 'Tue';
      case DateTime.wednesday: return 'Wed';
      case DateTime.thursday: return 'Thu';
      case DateTime.friday: return 'Fri';
      case DateTime.saturday: return 'Sat';
      default: return 'Day';
    }
  }

  @override
  void onClose() {
    // Clean up if needed
    super.onClose();
  }
}