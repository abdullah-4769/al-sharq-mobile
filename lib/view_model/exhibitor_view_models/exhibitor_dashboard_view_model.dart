// exhibitor_sessions_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_colors/app_colors.dart';
import '../../data/response_models/exhibitor_models/exhibitor_dashboard_model.dart';
import '../../repository/exhibitor_repo/dashboard_repo.dart';

class ExhibitorSessionsViewModel extends GetxController {
  final ExhibitorSessionsRepository _repository;

  ExhibitorSessionsViewModel({ExhibitorSessionsRepository? repository})
      : _repository = repository ?? ExhibitorSessionsRepository();

  final isLoading = false.obs;
  final error = ''.obs;
  final sessionsResponse = Rxn<ExhibitorSessionsResponse>();

  final totalSessions = 0.obs;
  final ongoingSessions = 0.obs;
  final scheduledSessions = 0.obs;

  RxList<Sessions> allSessions = <Sessions>[].obs;
  RxList<Sessions> todaySessions = <Sessions>[].obs;
  RxList<Sessions> upcomingSessions = <Sessions>[].obs;

  // Fetch sessions for a specific exhibitor
  Future<void> fetchExhibitorSessions(int exhibitorId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _repository.getExhibitorSessions(exhibitorId);
      sessionsResponse.value = response;

      // Update statistics safely (null-aware)
      totalSessions.value = response.total ?? 0;
      ongoingSessions.value = response.ongoing ?? 0;
      scheduledSessions.value = response.scheduled ?? 0;

      // Populate sessions (ensure not null)
      allSessions.assignAll(response.sessions ?? <Sessions>[]);

      // Separate sessions by date and sort
      _separateSessionsByDate();

      debugPrint('✅ Exhibitor sessions loaded: ${response.total} total');
    } catch (e) {
      error.value = e.toString();
      debugPrint('❌ Error loading sessions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Separate sessions by date
  void _separateSessionsByDate() {
    todaySessions.clear();
    upcomingSessions.clear();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var session in allSessions) {
      final s = session.startTime;
      if (s == null) continue;
      final sessionDate = DateTime(s.year, s.month, s.day);

      if (sessionDate == today) {
        todaySessions.add(session);
      } else if (sessionDate.isAfter(today)) {
        upcomingSessions.add(session);
      }
    }

    // Sort by start time null-safe
    int compareByStart(Sessions a, Sessions b) {
      final aStart = a.startTime;
      final bStart = b.startTime;
      if (aStart == null && bStart == null) return 0;
      if (aStart == null) return 1;
      if (bStart == null) return -1;
      return aStart.compareTo(bStart);
    }

    todaySessions.sort(compareByStart);
    upcomingSessions.sort(compareByStart);
  }

  // Get sessions for a specific date
  List<Sessions> getSessionsByDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return allSessions.where((session) {
      final s = session.startTime;
      if (s == null) return false;
      final sessionDate = DateTime(s.year, s.month, s.day);
      return sessionDate == targetDate;
    }).toList()
      ..sort((a, b) {
        if (a.startTime == null && b.startTime == null) return 0;
        if (a.startTime == null) return 1;
        if (b.startTime == null) return -1;
        return a.startTime!.compareTo(b.startTime!);
      });
  }

  // Get color based on category
  Color getCategoryColor(String? category) {
    if (category == null) return AppColors.darkgrey;
    switch (category.toLowerCase()) {
      case 'workshop':
        return AppColors.lightBlue;
      case 'keynote':
        return AppColors.primaryColor;
      case 'panel':
        return AppColors.warningColor;
      case 'general discussion':
        return Colors.green;
      default:
        return AppColors.darkgrey;
    }
  }

  // Refresh sessions
  Future<void> refreshSessions(int exhibitorId) async {
    await fetchExhibitorSessions(exhibitorId);
  }
}
