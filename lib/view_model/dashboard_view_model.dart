// lib/view_model/dashboard_view_model.dart
import 'package:get/get.dart';
import '../repository/dashboard_repository.dart';
import '../data/response_models/dashboard_response_model.dart';

class DashboardViewModel extends GetxController {
  final DashboardRepository _repository = DashboardRepository();

  final Rx<DashboardResponseModel?> _dashboardData = Rx<DashboardResponseModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _lastUpdated = 'Just now'.obs;

  DashboardResponseModel? get dashboardData => _dashboardData.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  String get lastUpdated => _lastUpdated.value;

  Future<void> fetchDashboardData() async {
    _isLoading.value = true;
    _error.value = '';
    update();

    try {
      _dashboardData.value = await _repository.getDashboardData();
      _lastUpdated.value = 'Just now';
    } catch (e) {
      _error.value = e.toString();
      print('DEBUG: ViewModel error: $e');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  void refreshData() {
    fetchDashboardData();
  }

  void clearError() {
    _error.value = '';
    update();
  }

  // Calculate total checked in today
  int getCheckedInToday() {
    final data = _dashboardData.value;
    if (data == null || data.dailyAttendance.isEmpty) return 0;

    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayAttendance = data.dailyAttendance.firstWhere(
          (attendance) => attendance.date == today,
      orElse: () => DailyAttendance(date: today, count: 0),
    );

    return todayAttendance.count;
  }

  // Calculate total participants (sum of all attendance)
  int getTotalParticipants() {
    final data = _dashboardData.value;
    if (data == null || data.dailyAttendance.isEmpty) return 0;

    return data.dailyAttendance.fold(0, (sum, attendance) => sum + attendance.count);
  }

  // Get attendance data for charts - FIXED NULL SAFETY
  List<double> getAttendanceChartData() {
    final data = _dashboardData.value;
    if (data == null || data.dailyAttendance.isEmpty) {
      return List.filled(7, 0.0);
    }

    return data.dailyAttendance.map((attendance) => attendance.count.toDouble()).toList();
  }

  // Get day labels for charts - FIXED NULL SAFETY
  List<String> getDayLabels() {
    final data = _dashboardData.value;
    if (data == null || data.dailyAttendance.isEmpty) {
      return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    }

    // Extract day names from dates
    return data.dailyAttendance.map((attendance) {
      final date = DateTime.parse(attendance.date);
      return _getDayAbbreviation(date.weekday);
    }).toList();
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return 'Sun';
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return 'Day';
    }
  }
}