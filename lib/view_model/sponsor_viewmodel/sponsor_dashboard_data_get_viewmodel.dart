import 'package:get/get.dart';
import '../../data/response/api_response.dart';
import '../../data/response_models/sponsor_respone_model/sponsor_dashboard_data_get_model.dart';
import '../../repository/sponsor_repo/sponsor_dashboard_data_get_repository.dart';


class SponsorDashboardDataViewModel extends GetxController {
  final _repo = SponsorDashboardDataRepository();

  final rxRequestStatus = Status.LOADING.obs;
  final sponsorDashboardData = Rx<ApiResponse<SponsorDashboardDataModel>?>(null);
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final hasInitialLoad = false.obs; // Add this to track initial load

  @override
  void onInit() {
    super.onInit();
    fetchSponsorDashboardData();
  }

  Future<void> fetchSponsorDashboardData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      rxRequestStatus.value = Status.LOADING;
      sponsorDashboardData.value = ApiResponse.loading();

      final response = await _repo.getSponsorDashboardData();

      if (response.status == Status.COMPLETED) {
        sponsorDashboardData.value = response;
        rxRequestStatus.value = Status.COMPLETED;
        hasInitialLoad.value = true; // Mark initial load as complete
      } else {
        sponsorDashboardData.value = ApiResponse.error(response.message);
        rxRequestStatus.value = Status.ERROR;
        errorMessage.value = response.message ?? 'Unknown error occurred';
        hasInitialLoad.value = true;
      }
    } catch (e) {
      sponsorDashboardData.value = ApiResponse.error(e.toString());
      rxRequestStatus.value = Status.ERROR;
      errorMessage.value = e.toString();
      hasInitialLoad.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data when coming back to screen
  Future<void> refreshData() async {
    await fetchSponsorDashboardData();
  }

  // Getters for computed values
  int get totalSessions => sponsorDashboardData.value?.data?.total ?? 0;
  int get ongoingSessions => sponsorDashboardData.value?.data?.ongoing ?? 0;
  int get scheduledSessions => sponsorDashboardData.value?.data?.scheduled ?? 0;
  List<SponsorSession> get sessions => sponsorDashboardData.value?.data?.sessions ?? [];

  // Filter sessions by status
  List<SponsorSession> get liveSessions => sessions.where((session) => session.isLive).toList();
  List<SponsorSession> get completedSessions => sessions.where((session) => session.isCompleted).toList();
  List<SponsorSession> get scheduledSessionsList => sessions.where((session) => session.isScheduled).toList();

  // Group sessions by date
  Map<String, List<SponsorSession>> get sessionsByDate {
    final Map<String, List<SponsorSession>> grouped = {};

    for (final session in sessions) {
      final dateKey = '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(session);
    }

    return grouped;
  }

  // Get formatted date for display
  String getFormattedDate(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length == 3) {
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return '${_getWeekday(date.weekday)}, ${_getMonth(date.month)} ${date.day}, ${date.year}';
    }
    return dateKey;
  }

  String _getWeekday(int weekday) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // Check if data is available - FIXED LOGIC
  bool get hasData => sponsorDashboardData.value?.status == Status.COMPLETED && sessions.isNotEmpty;

  // Check if we're still loading for the first time
  bool get isLoadingData => !hasInitialLoad.value && isLoading.value;

  // Check if there's an error
  bool get hasError => sponsorDashboardData.value?.status == Status.ERROR;

  // Check if we have no data after loading
  bool get hasNoData => hasInitialLoad.value && sponsorDashboardData.value?.status == Status.COMPLETED && sessions.isEmpty;
}