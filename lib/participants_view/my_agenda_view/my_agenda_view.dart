import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/app_colors/session_card.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart'
    hide AppColors;
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/form_label.dart';
import 'package:al_sharq_conference/participants_view/conference_schedule_view/conference_schedule_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/shared_preference.dart';
import '../../view_model/participant_viewmodel/all_bookmark_sessions_viewmodel.dart';

import '../seesion_details_view/session_detail.dart';
import '../seesion_details_view/session_detail_view.dart';

class MyAgendaScreen extends StatefulWidget {
  const MyAgendaScreen({super.key});

  @override
  State<MyAgendaScreen> createState() => _MyAgendaScreenState();
}

class _MyAgendaScreenState extends State<MyAgendaScreen> {
  TextEditingController _searchController = TextEditingController();
  final AllBookmarkedSessionsViewModel viewModel = Get.put(AllBookmarkedSessionsViewModel());

  int? _currentUserId;
  int? _currentEventId;

  @override
  void initState() {
    super.initState();
    _getUserDataAndFetchSessions();
  }

  Future<void> _getUserDataAndFetchSessions() async {
    await _getUserData();

    if (_currentUserId != null && _currentEventId != null) {
      viewModel.fetchBookmarkedSessions(_currentUserId!, _currentEventId!);
    }
  }

  Future<void> _getUserData() async {
    try {
      _currentUserId = await SharedPrefsHelper.getUserId();
      _currentEventId = await SharedPrefsHelper.getLatestEventId();
      print('=== Retrieved user ID: $_currentUserId, event ID: $_currentEventId ===');
    } catch (e) {
      print('=== Error getting user data: $e ===');
    }
  }

  void _navigateToSessionDetails(int sessionId) {
    print('=== Navigating to session details for ID: $sessionId ===');
    Get.to(() => SessionDetailsScreen(sessionId: sessionId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: AppText(
          text: 'My Agenda',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
        ),
      ),

      body: Obx(() {
        if (viewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: 'Error loading sessions',
                  fontSize: 16,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Retry',
                  onPressed: _getUserDataAndFetchSessions,
                  backgroundColor: AppColors.primaryColor,
                  textColor: AppColors.whiteColor,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search and Filter Row
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: CustomTextField(
                        hintText: "Search",
                        controller: _searchController,
                        suffixIcon: Icons.search,
                        onChanged: (value) {
                          viewModel.searchSessions(value);
                        },
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
                        child: const Icon(Icons.tune, color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Dynamic Session List by Date
                if (viewModel.filteredSessions.isEmpty && viewModel.searchQuery.value.isNotEmpty)
                  _buildNoResults()
                else if (viewModel.filteredSessions.isEmpty)
                  _buildEmptyState()
                else
                  ..._buildSessionList(),

                const SizedBox(height: 32),

                // Browse More Sessions Card
                _buildBrowseMoreSessionsCard(),

                const SizedBox(height: 20),
              ],
            ),
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
            text: 'No sessions found',
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
            Icons.bookmark_border,
            size: 64,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 16),
          AppText(
            text: 'No Bookmarked Sessions',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Bookmark sessions from the conference schedule to see them here',
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

    viewModel.sessionsByDate.forEach((date, sessions) {
      widgets.addAll([
        // Date Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: date,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            AppText(
              text: '${sessions.length} sessions',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Session Cards for this date
        // In the _buildSessionList() method, update the SessionCard usage:

        ...sessions.map(
              (session) => SessionCard(
            title: session.sessionTitle,
            speaker: session.speakers.isNotEmpty ? session.speakers.first.fullName : 'Speaker TBA',
            speakerRole: session.speakers.isNotEmpty
                ? (session.speakers.first.bio.length > 20
                ? '${session.speakers.first.bio.substring(0, 20)}...'
                : session.speakers.first.bio)
                : 'Role TBA',
            description: session.sessionDescription,
            time: session.formattedTime, // Use formattedTime instead of time
            duration: session.durationInMinutes, // Use durationInMinutes instead of duration
            room: session.location, // Use location instead of room
            sessionType: session.category,
            isBookmarked: session.bookmarked, // Use bookmarked instead of isBookmarked
            onBookmarkTap: () {
              // Since we can't unbookmark, show info message
              Get.snackbar(
                'Info',
                'Bookmarked sessions cannot be unbookmarked',
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            },
            onViewDetails: () {
              _navigateToSessionDetails(session.sessionId);
            },
          ),
        ).toList(),
        const SizedBox(height: 24),
      ]);
    });

    return widgets;
  }

  Widget _buildBrowseMoreSessionsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 48,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 16),
          AppText(
            text: 'Discover More Sessions',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Browse the full conference schedule to add more sessions to your agenda.',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Browse All Sessions',
            onPressed: () {
              // Navigate to conference schedule

              Get.to(()=> ConferenceScheduleScreen());
            },
            backgroundColor: AppColors.primaryColor,
            textColor: AppColors.whiteColor,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}