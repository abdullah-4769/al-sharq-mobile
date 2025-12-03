// lib/participants_view/today_sessions_view/today_sessions_screen.dart
import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/participants_view/seesion_details_view/session_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:get/get.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../data/response_models/participant_response_model/today_session_model.dart';
import '../../utils/shared_preference.dart';
import '../../view_model/participant_viewmodel/today_session_viewmodel.dart';

class TodaySessionsScreen extends StatefulWidget {
  const TodaySessionsScreen({super.key});

  @override
  State<TodaySessionsScreen> createState() => _TodaySessionsScreenState();
}

class _TodaySessionsScreenState extends State<TodaySessionsScreen> {
  TextEditingController searchController = TextEditingController();
  final TodaySessionViewModel todaySessionViewModel = Get.put(TodaySessionViewModel());

  int? _currentUserId;
  int? _currentEventId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      _currentUserId = await SharedPrefsHelper.getUserId();
      _currentEventId = await SharedPrefsHelper.getLatestEventId();
      print('=== Retrieved user ID: $_currentUserId, event ID: $_currentEventId ===');

      // Fetch registered sessions when screen loads
      if (_currentUserId != null && _currentEventId != null) {
        todaySessionViewModel.fetchRegisteredSessions(_currentUserId!, _currentEventId!);
      }
    } catch (e) {
      print('=== Error getting user data: $e ===');
    }
  }

  void _navigateToSessionDetails(int sessionId) {
    print('=== Navigating to session details for ID: $sessionId ===');
    Get.to(() => SessionDetailsScreen(sessionId: sessionId));
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Get today's date
  DateTime get _todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _todayEnd {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  // Filter sessions based on search query and separate sessions
  Map<String, List<TodaySessionModel>> get _filteredSessions {
    final allSessions = todaySessionViewModel.allSessions;

    // First filter by search query
    List<TodaySessionModel> filtered = allSessions;
    if (_searchQuery.isNotEmpty) {
      filtered = allSessions.where((session) =>
      session.sessionTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (session.sessionDescription?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          session.speakers.any((speaker) =>
              speaker.fullName.toLowerCase().contains(_searchQuery.toLowerCase())
          ) ||
          (session.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (session.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    // Separate sessions into categories
    final liveSessions = filtered.where((session) => session.isCurrentlyLive).toList();

    final todayUpcomingSessions = filtered.where((session) =>
    session.isToday &&
        session.isUpcoming &&
        !session.isCurrentlyLive
    ).toList();

    final pastSessions = filtered.where((session) =>
        DateTime.now().isAfter(session.endTime)
    ).toList();

    final futureSessions = filtered.where((session) =>
    !session.isToday &&
        session.isUpcoming
    ).toList();

    return {
      'live': liveSessions,
      'today': todayUpcomingSessions,
      'past': pastSessions,
      'future': futureSessions,
    };
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
    } else if (type.contains('general discussion')) {
      return Colors.blue;
    } else {
      return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomAppDrawer(),
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppText(
          text: "Sessions",
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final sessions = todaySessionViewModel.allSessions;
        final isLoading = todaySessionViewModel.isLoading.value;
        final error = todaySessionViewModel.errorMessage.value;

        if (error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.errorColor),
                const SizedBox(height: 16),
                AppText(
                  text: 'Failed to load sessions',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
                const SizedBox(height: 8),
                AppText(
                  text: error,
                  fontSize: 14,
                  color: AppColors.darkgrey,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Retry',
                  onPressed: () {
                    if (_currentUserId != null && _currentEventId != null) {
                      todaySessionViewModel.fetchRegisteredSessions(_currentUserId!, _currentEventId!);
                    }
                  },
                  backgroundColor: AppColors.primaryColor,
                  height: 40,
                  width: 120,
                ),
              ],
            ),
          );
        }

        if (isLoading && sessions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                AppText(
                  text: "Loading sessions...",
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        final filteredSessions = _filteredSessions;
        final liveSessions = filteredSessions['live']!;
        final todaySessions = filteredSessions['today']!;
        final futureSessions = filteredSessions['future']!;

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
              const SizedBox(height: 24),

              // Show appropriate content based on search and data
              if (_searchQuery.isNotEmpty && sessions.isEmpty)
                _buildNoResults()
              else if (sessions.isEmpty)
                _buildEmptyState()
              else
                ..._buildSessionSections(liveSessions, todaySessions, futureSessions),
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
          const AppText(
            text: 'No sessions found',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          const AppText(
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
          const AppText(
            text: 'No Sessions Available',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          const AppText(
            text: 'Check back later for conference sessions',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSessionSections(
      List<TodaySessionModel> liveSessions,
      List<TodaySessionModel> todaySessions,
      List<TodaySessionModel> futureSessions,
      ) {
    List<Widget> widgets = [];

    // Live Sessions Section
    if (liveSessions.isNotEmpty) {
      widgets.addAll([
        _buildSectionHeader(
          title: 'Live Now',
          count: liveSessions.length,
          icon: Icons.live_tv,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        ...liveSessions.map((session) => _buildSessionCard(session, isLive: true)).toList(),
        const SizedBox(height: 24),
      ]);
    }

    // Today's Upcoming Sessions
    if (todaySessions.isNotEmpty) {
      widgets.addAll([
        _buildSectionHeader(
          title: 'Upcoming Today',
          count: todaySessions.length,
          icon: Icons.access_time,
          color: AppColors.primaryColor,
        ),
        const SizedBox(height: 16),
        ...todaySessions.map((session) => _buildSessionCard(session, isLive: false)).toList(),
        const SizedBox(height: 24),
      ]);
    }

    // Future Sessions
    if (futureSessions.isNotEmpty) {
      widgets.addAll([
        _buildSectionHeader(
          title: 'Coming Soon',
          count: futureSessions.length,
          icon: Icons.calendar_today,
          color: AppColors.darkBlue,
        ),
        const SizedBox(height: 16),
        ...futureSessions.map((session) => _buildSessionCard(session, isLive: false)).toList(),
      ]);
    }

    // If no sessions in any category but there are sessions
    if (widgets.isEmpty && todaySessionViewModel.allSessions.isNotEmpty) {
      widgets.add(
        const AppText(
          text: 'No sessions match your search',
          fontSize: 16,
          color: AppColors.darkgrey,
          textAlign: TextAlign.center,
        ),
      );
    }

    return widgets;
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
                const SizedBox(height: 4),
                AppText(
                  text: "$count session${count == 1 ? '' : 's'}",
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Session Card Widget
  Widget _buildSessionCard(TodaySessionModel session, {required bool isLive}) {
    final tagColor = _getTagColor(session.category ?? 'Session');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLive ? Colors.red : AppColors.mediumGreyColor,
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
          // Title + Live Indicator
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
                    children: [
                     // Icon(Icons.live_tv, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      AppText(
                        text: "LIVE",
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
                      text: session.formattedTime,
                      fontSize: 14,
                      color: AppColors.darkgrey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (session.timeUntilStart.isNotEmpty)
                      AppText(
                        text: session.timeUntilStart,
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
                  AppText(
                    text: "Duration:",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(width: 4),
                  AppText(
                    text: session.durationInMinutes,
                    fontSize: 14,
                    color: AppColors.darkgrey,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
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
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: "View Details",
              onPressed: () => _navigateToSessionDetails(session.sessionId),
              height: 44,
            ),
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