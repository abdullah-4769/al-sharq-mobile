import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/participants_view/my_agenda_view/my_agenda_view.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../data/response_models/participant_response_model/event_session_response_model.dart';
import '../../data/response_models/participant_response_model/session_model.dart';
import '../../utils/shared_preference.dart';
import '../../view_model/participant_viewmodel/event_session_viewmodel.dart';
import '../../view_model/participant_viewmodel/all_bookmark_sessions_viewmodel.dart';
import '../seesion_details_view/session_detail.dart';
import '../seesion_details_view/session_detail_view.dart';

class ConferenceScheduleScreen extends StatefulWidget {
  const ConferenceScheduleScreen({super.key});

  @override
  State<ConferenceScheduleScreen> createState() => _ConferenceScheduleScreenState();
}

class _ConferenceScheduleScreenState extends State<ConferenceScheduleScreen> {
  TextEditingController searchController = TextEditingController();
  final EventSessionsViewModel sessionsController = Get.find<EventSessionsViewModel>();
  final AllBookmarkedSessionsViewModel bookmarkViewModel = Get.put(AllBookmarkedSessionsViewModel());

  int? _currentUserId;
  int? _currentEventId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _getUserData();

    // Fetch sessions when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sessionsController.allSessions.isEmpty) {
        sessionsController.fetchEventSessions(context);
      }
    });
  }

  Future<void> _getUserData() async {
    try {
      _currentUserId = await SharedPrefsHelper.getUserId();
      _currentEventId = await SharedPrefsHelper.getLatestEventId();
      print('=== Retrieved user ID: $_currentUserId, event ID: $_currentEventId ===');

      // Fetch bookmarked sessions count
      if (_currentUserId != null && _currentEventId != null) {
        bookmarkViewModel.fetchBookmarkedSessions(_currentUserId!, _currentEventId!);
      }
    } catch (e) {
      print('=== Error getting user data: $e ===');
    }
  }

  void _navigateToSessionDetails(int sessionId) {
    print('=== Navigating to session details for ID: $sessionId ===');
    Get.to(() => SessionDetailsScreen(sessionId: sessionId));
  }

  void _navigateToMyAgenda() {
    Get.to(() => MyAgendaScreen());
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Filter sessions based on search query AND exclude past sessions
  List<SessionModel> get _filteredSessions {
    final allSessions = sessionsController.allSessions;

    // First, filter out past sessions (show only current and future)
    List<SessionModel> currentAndFutureSessions = allSessions
        .where((session) => session.isCurrentOrFuture)  // Use the new property
        .toList();

    if (_searchQuery.isEmpty) {
      return currentAndFutureSessions;
    }

    // Then apply search filter
    return currentAndFutureSessions.where((session) =>
    session.sessionTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (session.sessionDescription?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
        session.speakers.any((speaker) =>
            speaker.fullName.toLowerCase().contains(_searchQuery.toLowerCase())
        ) ||
        (session.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
        (session.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  // Get upcoming sessions count (excluding past)
  int get _upcomingSessionsCount {
    return sessionsController.allSessions
        .where((session) => session.isCurrentOrFuture)
        .length;
  }

  // Group sessions by date (only current and future)
  Map<String, List<SessionModel>> get _sessionsByDate {
    final Map<String, List<SessionModel>> grouped = {};

    for (final session in _filteredSessions) {
      final dateKey = _getFormattedDate(session);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(session);
    }

    // Sort dates chronologically
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) {
        try {
          final sessionA = _filteredSessions.firstWhere((s) => _getFormattedDate(s) == a);
          final sessionB = _filteredSessions.firstWhere((s) => _getFormattedDate(s) == b);
          return _getSessionDate(sessionA).compareTo(_getSessionDate(sessionB));
        } catch (e) {
          return a.compareTo(b);
        }
      });

    final sortedMap = <String, List<SessionModel>>{};
    for (final date in sortedDates) {
      // Sort sessions within each date by time
      final sessions = grouped[date]!;
      sessions.sort((a, b) => _getSessionDate(a).compareTo(_getSessionDate(b)));
      sortedMap[date] = sessions;
    }

    return sortedMap;
  }

  // Helper method to get formatted date from session
  String _getFormattedDate(SessionModel session) {
    try {
      final times = session.duration.split(' - ');
      if (times.isNotEmpty) {
        final date = DateTime.parse(times[0]);
        return '${_getWeekday(date)}, ${_getMonth(date)} ${date.day}, ${date.year}';
      }
      return 'Date TBD';
    } catch (e) {
      return 'Date TBD';
    }
  }

  // Helper method to get session date for sorting
  DateTime _getSessionDate(SessionModel session) {
    try {
      final times = session.duration.split(' - ');
      if (times.isNotEmpty) {
        return DateTime.parse(times[0]);
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  // Helper method to get formatted time
  String _getFormattedTime(SessionModel session) {
    try {
      final times = session.duration.split(' - ');
      if (times.length >= 2) {
        final start = DateTime.parse(times[0]);
        final end = DateTime.parse(times[1]);
        return '${_formatTime(start)} - ${_formatTime(end)}';
      }
      return 'TBD';
    } catch (e) {
      return 'TBD';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : hour;
    return '$displayHour:$minute $period';
  }

  // Helper method to get duration in minutes
  String _getDurationInMinutes(SessionModel session) {
    try {
      final times = session.duration.split(' - ');
      if (times.length >= 2) {
        final start = DateTime.parse(times[0]);
        final end = DateTime.parse(times[1]);
        final difference = end.difference(start);
        final minutes = difference.inMinutes;
        return '$minutes minutes';
      }
      return 'TBD';
    } catch (e) {
      return 'TBD';
    }
  }

  String _getWeekday(DateTime date) {
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];
  }

  String _getMonth(DateTime date) {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
  }

  // Get tag color based on session type
  Color _getTagColor(String sessionType) {
    final type = sessionType.toLowerCase();
    if (type.contains('keynote')) {
      return AppColors.darkBlue;
    } else if (type.contains('panel')) {
      return Colors.yellow[700]!;
    } else if (type.contains('workshop')) {
      return Colors.green;
    } else if (type.contains('breakout')) {
      return Colors.orange;
    } else if (type.contains('networking')) {
      return Colors.purple;
    } else {
      return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppText(
          text: "Conference Schedule",
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final sessions = sessionsController.allSessions;
        final isLoading = sessionsController.isLoading.value;

        if (isLoading && sessions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                AppText(
                  text: "Loading conference schedule...",
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        // Calculate past sessions count for info
        final pastSessionsCount = sessions.where((s) => s.isPast).length;
        final upcomingSessionsCount = _upcomingSessionsCount;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: CustomTextField(
                      hintText: "Search sessions, speakers, topics...",
                      controller: searchController,
                      suffixIcon: Icons.search,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(Icons.tune, color: AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // My Agenda Card with dynamic count
              GestureDetector(
                onTap: _navigateToMyAgenda,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              text: "My Agenda",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Obx(() {
                              if (bookmarkViewModel.isLoading.value) {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AppText(
                                      text: "Loading your agenda...",
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ],
                                );
                              } else {
                                return AppText(
                                  text: "${bookmarkViewModel.allSessions.length} sessions bookmarked",
                                  fontSize: 14,
                                  color: Colors.white,
                                );
                              }
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _navigateToMyAgenda,
                        child: const Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              // Show info about past sessions if any
              if (pastSessionsCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '$pastSessionsCount past session${pastSessionsCount == 1 ? '' : 's'} hidden',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Schedule Header with count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    text: "Upcoming Sessions",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  AppText(
                    text: "$upcomingSessionsCount sessions",
                    fontSize: 14,
                    color: AppColors.darkgrey,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dynamic Session List
              if (_filteredSessions.isEmpty && _searchQuery.isNotEmpty)
                _buildNoResults()
              else if (_filteredSessions.isEmpty)
                _buildEmptyState()
              else
                ..._buildSessionList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNoResults() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 16),
          AppText(
            text: 'No upcoming sessions found',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Try adjusting your search terms',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 16),
          AppText(
            text: 'No Upcoming Sessions',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'All sessions have been completed',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSessionList() {
    List<Widget> widgets = [];

    _sessionsByDate.forEach((date, sessions) {
      widgets.addAll([
        // Date Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  text: date,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
              AppText(
                text: "${sessions.length} session${sessions.length == 1 ? '' : 's'}",
                fontSize: 13,
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Session Cards for this date
        ...sessions.map((session) => _buildSessionCard(session)).toList(),
        const SizedBox(height: 24),
      ]);
    });

    return widgets;
  }

  // Session Card Widget
  Widget _buildSessionCard(SessionModel session) {
    final tagColor = _getTagColor(session.category ?? 'Session');
    final isLive = session.isCurrentlyLive; // Use calculated live status
    final isUpcoming = session.isUpcomingToday; // Check if upcoming today

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLive ? Colors.red.shade300 : AppColors.mediumGreyColor,
          width: isLive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Status Indicators
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: session.sessionTitle,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isLive) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                     // Icon(Icons.live_tv, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      AppText(
                        text: "LIVE NOW",
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ] else if (isUpcoming) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      AppText(
                        text: "UPCOMING",
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),

          // Speaker(s)
          AppText(
            text: session.speakers.isNotEmpty
                ? session.speakers.map((speaker) => speaker.fullName).join(', ')
                : 'Speaker TBA',
            fontSize: 14,
            color: AppColors.darkgrey,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Time + Tag
          Row(
            children: [
              Icon(
                session.isToday ? Icons.access_time : Icons.calendar_today,
                size: 16,
                color: AppColors.darkgrey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: _getFormattedTime(session),
                      fontSize: 14,
                      color: AppColors.darkgrey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (session.minutesUntilStart != null && session.minutesUntilStart! > 0)
                      AppText(
                        text: session.minutesUntilStart! > 60
                            ? 'Starts in ${session.minutesUntilStart! ~/ 60}h ${session.minutesUntilStart! % 60}m'
                            : 'Starts in ${session.minutesUntilStart}m',
                        fontSize: 12,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AppText(
                  text: session.category ?? 'Session',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: tagColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Duration + Room
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppText(
                    text: "Duration:",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(width: 4),
                  AppText(
                    text: _getDurationInMinutes(session),
                    fontSize: 14,
                    color: AppColors.darkgrey,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppText(
                    text: "Location:",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(width: 4),
                  AppText(
                    text: session.location ?? 'TBD',
                    fontSize: 14,
                    color: AppColors.darkgrey,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // View Details Button
          CustomButton(
            text: "View Details",
            onPressed: () => _navigateToSessionDetails(session.sessionId),
            height: 44,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}