// lib/view_model/participant_viewmodel/all_bookmarked_sessions_viewmodel.dart

import 'package:get/get.dart';
import '../../data/response_models/participant_response_model/all_bookmark_sessions_responsemodel.dart';
import '../../repository/participants_repository/all_bookmark_session_repo.dart';

class AllBookmarkedSessionsViewModel extends GetxController {
  final AllBookmarkedSessionsRepo _repo = AllBookmarkedSessionsRepo();

  final RxList<BookmarkedSession> _allSessions = <BookmarkedSession>[].obs;
  final RxList<BookmarkedSession> _filteredSessions = <BookmarkedSession>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Group sessions by date
  final RxMap<String, List<BookmarkedSession>> _sessionsByDate = <String, List<BookmarkedSession>>{}.obs;

  List<BookmarkedSession> get allSessions => _allSessions;
  List<BookmarkedSession> get filteredSessions => _filteredSessions;
  Map<String, List<BookmarkedSession>> get sessionsByDate => _sessionsByDate;
  List<String> get dates => _sessionsByDate.keys.toList();
// // Add this method to your AllBookmarkedSessionsViewModel class
//   void updateFilteredSessions(List<BookmarkedSession> filteredSessions) {
//     this.filteredSessions.assignAll(filteredSessions);
//     _groupSessionsByDate(filteredSessions);
//   }
  Future<void> fetchBookmarkedSessions(int userId, int eventId) async {
    try {
      print('=== Fetching bookmarked sessions for user: $userId, event: $eventId ===');
      isLoading.value = true;
      errorMessage.value = '';

      final sessions = await _repo.getBookmarkedSessions(
        userId: userId,
        eventId: eventId,
      );

      _allSessions.assignAll(sessions);
      _filteredSessions.assignAll(sessions);
      _groupSessionsByDate(sessions);

      print('=== Successfully loaded ${sessions.length} bookmarked sessions ===');
    } catch (e) {
      errorMessage.value = 'Failed to load bookmarked sessions: $e';
      print('=== Error loading bookmarked sessions: $e ===');
    } finally {
      isLoading.value = false;
    }
  }

  void searchSessions(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      _filteredSessions.assignAll(_allSessions);
    } else {
      final filtered = _allSessions.where((session) =>
      session.sessionTitle.toLowerCase().contains(query.toLowerCase()) ||
          session.sessionDescription.toLowerCase().contains(query.toLowerCase()) ||
          session.speakers.any((speaker) =>
              speaker.fullName.toLowerCase().contains(query.toLowerCase())
          ) ||
          session.category.toLowerCase().contains(query.toLowerCase()) ||
          session.location.toLowerCase().contains(query.toLowerCase())
      ).toList();

      _filteredSessions.assignAll(filtered);
    }

    _groupSessionsByDate(_filteredSessions);
    print('=== Search completed. Found ${_filteredSessions.length} sessions for query: "$query" ===');
  }

  void _groupSessionsByDate(List<BookmarkedSession> sessions) {
    _sessionsByDate.clear();

    for (final session in sessions) {
      final dateKey = session.formattedDate;
      if (!_sessionsByDate.containsKey(dateKey)) {
        _sessionsByDate[dateKey] = [];
      }
      _sessionsByDate[dateKey]!.add(session);
    }

    // Sort dates chronologically using startTime
    final sortedDates = _sessionsByDate.keys.toList()
      ..sort((a, b) {
        try {
          final sessionA = sessions.firstWhere((s) => s.formattedDate == a);
          final sessionB = sessions.firstWhere((s) => s.formattedDate == b);
          final dateA = DateTime.parse(sessionA.startTime);
          final dateB = DateTime.parse(sessionB.startTime);
          return dateA.compareTo(dateB);
        } catch (e) {
          print('=== Error sorting dates: $e ===');
          return a.compareTo(b);
        }
      });
    final sortedMap = <String, List<BookmarkedSession>>{};
    for (final date in sortedDates) {
      sortedMap[date] = _sessionsByDate[date]!;
    }

    _sessionsByDate.assignAll(sortedMap);
  }

  void clearSessions() {
    _allSessions.clear();
    _filteredSessions.clear();
    _sessionsByDate.clear();
    errorMessage.value = '';
    searchQuery.value = '';
  }
}