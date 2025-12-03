import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/participants_view/seesion_details_view/session_detail.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/images/images.dart';
import '../../../app_colors/session_card.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/response_models/participant_response_model/event_session_response_model.dart';
import '../../data/response_models/participant_response_model/session_model.dart';
import '../../data/response_models/speaker_response_models/speaker_sessions_detail_show_model.dart';
import '../../speaker_view/manage_session_speaker/manage_session_speaker.dart';
import '../../view_model/participant_viewmodel/make_session_bookmark_viewmodel.dart';
import '../../view_model/participant_viewmodel/session_detail_show_viewmodel.dart';
import '../../view_model/participant_viewmodel/event_session_viewmodel.dart';
import '../../view_model/participant_viewmodel/sessionss_register_bookmark_status_viewmodel.dart';

import '../../utils/shared_preference.dart';
import '../../view_model/speaker_viewmodels/speaker_dashboard_show_viewmodel.dart';
import '../../view_model/speaker_viewmodels/speaker_sessions_detail_show_viewmodel.dart';
import '../conference_schedule_view/conference_schedule_view.dart';
import '../form_create/create_new_form_screen.dart';
import '../forum_chat/forum_list_view.dart';
import '../registartion_and_join_dialogues/participant_join_session_dialogue.dart';
import '../registartion_and_join_dialogues/participant_session_registration_dilaogue.dart';

class SessionDetailsScreen extends StatefulWidget {
  final int sessionId;

  const SessionDetailsScreen({super.key, required this.sessionId});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  bool isBookmarked = false;
  late final SessionDetailShowViewModel controller;
  late final EventSessionsViewModel sessionsController;
  late final SessionRegisterBookmarkStatusViewModel statusController;
  late final MakeSessionBookmarkedViewModel bookmarkController;

  int? _currentUserId;
  int? _currentEventId;

  @override
  void initState() {
    super.initState();
    print('=== SessionDetailsScreen initState called with sessionId: ${widget.sessionId} ===');

    // Initialize sessionsController first
    sessionsController = Get.find<EventSessionsViewModel>();

    // Create new controller instances with unique tags based on sessionId
    controller = Get.put(SessionDetailShowViewModel(), tag: 'session_${widget.sessionId}');
    statusController = Get.put(SessionRegisterBookmarkStatusViewModel(), tag: 'status_${widget.sessionId}');
    bookmarkController = Get.put(MakeSessionBookmarkedViewModel(), tag: 'bookmark_${widget.sessionId}');

    // Get user ID and fetch data
    _getUserDataAndFetch();
  }

  Future<void> _getUserDataAndFetch() async {
    await _getUserData();

    // Fetch session details and status when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('=== Fetching session details for ID: ${widget.sessionId} ===');
      controller.fetchSessionDetails(widget.sessionId);

      if (_currentUserId != null) {
        print('=== Fetching session status for user: $_currentUserId ===');
        statusController.fetchSessionStatus(widget.sessionId, _currentUserId!);
      } else {
        print('=== User ID not found, skipping session status fetch ===');
      }
    });
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

  @override
  void dispose() {
    print('=== Disposing SessionDetailsScreen for sessionId: ${widget.sessionId} ===');
    statusController.clearStatus();
    bookmarkController.clearMessages();

    // Delete the controller instances with their tags
    Get.delete<SessionDetailShowViewModel>(tag: 'session_${widget.sessionId}');
    Get.delete<SessionRegisterBookmarkStatusViewModel>(tag: 'status_${widget.sessionId}');
    Get.delete<MakeSessionBookmarkedViewModel>(tag: 'bookmark_${widget.sessionId}');

    super.dispose();
  }

  // Handle bookmark tap
  void _handleBookmarkTap() async {
    if (_currentUserId == null || _currentEventId == null) {
      Get.snackbar(
        'Error',
        'User data not found. Please login again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // If already bookmarked, show message that it cannot be unbookmarked
    if (statusController.isBookmarked) {
      Get.snackbar(
        'Info',
        'Session is already bookmarked.',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    // Bookmark the session
    final success = await bookmarkController.bookmarkSession(
      userId: _currentUserId!,
      sessionId: widget.sessionId,
      eventId: _currentEventId!,
    );

    if (success) {
      // Refresh the session status to update the UI
      statusController.fetchSessionStatus(widget.sessionId, _currentUserId!);

      Get.snackbar(
        'Success',
        'Session bookmarked successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to bookmark session',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Calculate duration in minutes from start and end time
  String _calculateDuration(String startTime, String endTime) {
    if (startTime.isEmpty || endTime.isEmpty) return 'TBD';

    try {
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);
      final difference = end.difference(start);
      final minutes = difference.inMinutes;
      return '$minutes minutes';
    } catch (e) {
      return 'TBD';
    }
  }

  // Get related sessions (all sessions except the current one)
  List<SessionModel> get _relatedSessions {
    final allSessions = sessionsController.allSessions;
    // Filter out the current session and take up to 3 related sessions
    final related = allSessions
        .where((session) => session.sessionId != widget.sessionId)
        .take(3)
        .toList();
    print('=== Found ${related.length} related sessions for session ${widget.sessionId} ===');
    for (var session in related) {
      print('Related session: ${session.sessionId} - ${session.sessionTitle}');
    }
    return related;
  }

// Replace your current _navigateToRelatedSession method with this:

  void _navigateToRelatedSession(int sessionId) {
    print('=== Navigating to session details for ID: $sessionId ===');

    // Remove the current screen from the navigation stack first
    Get.back();

    // Then navigate to the new session with a slight delay to ensure proper rebuild
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.to(
            () => SessionDetailsScreen(
          sessionId: sessionId,
          key: ValueKey('session_$sessionId'),
        ),
        preventDuplicates: false, // Allow navigation to same screen type
      );
    });
  }
  // Helper method to get speaker image with proper fallbacks
  ImageProvider _getSpeakerImage(dynamic speaker) {
    try {
      // Debug print to see what properties are available
      print('=== Speaker object type: ${speaker.runtimeType} ===');
      print('=== Speaker user file: ${speaker.user?.file} ===');
      print('=== Speaker user photo: ${speaker.user?.photo} ===');

      // The file is in speaker.user.file (from user profile)
      if (speaker.user?.file != null && speaker.user!.file!.isNotEmpty) {
        print('=== Using speaker.user.file: ${speaker.user!.file} ===');
        return NetworkImage(speaker.user!.file!);
      }

      // Then try speaker.user.photo (from user profile)
      if (speaker.user?.photo != null && speaker.user!.photo!.isNotEmpty) {
        print('=== Using speaker.user.photo: ${speaker.user!.photo} ===');
        return NetworkImage(speaker.user!.photo!);
      }

      // Try direct properties that might exist (though they shouldn't in your model)
      if (speaker.file != null && speaker.file!.isNotEmpty) {
        print('=== Using speaker.file: ${speaker.file} ===');
        return NetworkImage(speaker.file!);
      }

      if (speaker.photo != null && speaker.photo!.isNotEmpty) {
        print('=== Using speaker.photo: ${speaker.photo} ===');
        return NetworkImage(speaker.photo!);
      }

      // Fallback to default image
      print('=== Using fallback default image ===');
      return AssetImage(Images.drjohnthan);
    } catch (e) {
      print('=== Error getting speaker image: $e ===');
      // Fallback to default image in case of any error
      return AssetImage(Images.drjohnthan);
    }
  }
  @override
  Widget build(BuildContext context) {
    print('=== SessionDetailsScreen build called with sessionId: ${widget.sessionId} ===');

    return Scaffold(
      drawer: const CustomAppDrawer(),
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppText(
          text: 'Session Details',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        print('=== Obx builder called, isLoading: ${controller.isLoading.value}, error: ${controller.errorMessage.value} ===');

        if (controller.isLoading.value) {
          print('=== Showing loading indicator ===');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                AppText(
                  text: 'Loading session details...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          print('=== Showing error: ${controller.errorMessage.value} ===');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: controller.errorMessage.value,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.fetchSessionDetails(widget.sessionId);
                  },
                  child: const AppText(text: 'Retry'),
                ),
              ],
            ),
          );
        }

        final session = controller.sessionDetails.value;
        final relatedSessions = _relatedSessions;

        print('=== Rendering session details for: ${session.title} (ID: ${session.id}) ===');

        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Session Details Card with Bookmark Status
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGreyColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge and Bookmark status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.lightPurpleColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: AppText(
                              text: session.category.isNotEmpty ? session.category : 'Session',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkPurpleColor,
                            ),
                          ),
                          // Bookmark icon - Always show, but change color based on status and make it clickable
                          Obx(() {
                            if (statusController.isLoading.value) {
                              return const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }
                            return GestureDetector(
                              onTap: _handleBookmarkTap,
                              child: Icon(
                                statusController.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: statusController.isBookmarked
                                    ? AppColors.primaryColor
                                    : AppColors.darkgrey,
                                size: 24,
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title and details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: session.title,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on, color: AppColors.primaryColor, size: 16),
                                  const SizedBox(width: 4),
                                  AppText(
                                    text: session.location,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.blackColor,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time_filled, color: AppColors.primaryColor, size: 16),
                                  const SizedBox(width: 4),
                                  AppText(
                                    text: _calculateDuration(session.startTime, session.endTime),
                                    fontSize: 12,
                                    color: AppColors.blackColor,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.group, color: AppColors.primaryColor, size: 16),
                                  const SizedBox(width: 4),
                                  AppText(
                                    text: '${session.capacity} capacity',
                                    fontSize: 12,
                                    color: AppColors.blackColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AppText(
                        text: session.description,
                        fontSize: 12,
                        color: AppColors.blackColor,
                      ),
                    ],
                  ),
                ),

                // Session Form Section
                GestureDetector(
                  onTap: () {
                    print('=== Navigating to forums list for session: ${widget.sessionId} ===');
                    Get.to(() => ForumsListScreen(sessionId: widget.sessionId));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 24),
                    child: IntrinsicHeight(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightred,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightGreyColor),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                color: AppColors.lightred2,
                                image: DecorationImage(
                                  image: AssetImage(Images.session),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: "Session Discussions",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryColor,
                                  ),
                                  const SizedBox(height: 4),
                                  AppText(
                                    text: "Join the discussion with other attendees, ask questions, and share insights about this session.",
                                    fontSize: 13,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryColor),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Speakers Section
                if (session.speakers.isNotEmpty) ...[
                  ...session.speakers.map((speaker) =>
                      Container(
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            const SizedBox(height: 16),
                            IntrinsicHeight(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.lightGreyColor),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const AppText(
                                                text: 'Speakers',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              Container(
                                                height: 30,
                                                width: 130,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(20),
                                                  color: AppColors.lightBlue,
                                                ),
                                                child: Center(
                                                  child: AppText(
                                                    text: speaker.featured ? "Featured Speaker" : "Speaker",
                                                    color: AppColors.darkBlue,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.grey[300],
                                            backgroundImage: _getSpeakerImage(speaker),
                                          ),
                                          const SizedBox(height: 8),
                                          AppText(
                                            text: speaker.user.name,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(height: 4),
                                          if (speaker.designations.isNotEmpty)
                                            AppText(
                                              text: speaker.designations.join(", "),
                                              fontSize: 12,
                                              color: AppColors.blackColor,
                                            ),
                                          if (speaker.user.organization != null && speaker.user.organization!.isNotEmpty)
                                            AppText(
                                              text: speaker.user.organization!,
                                              fontSize: 12,
                                              color: AppColors.blackColor,
                                            ),
                                          const SizedBox(height: 8),
                                          AppText(
                                            text: speaker.bio,
                                            fontSize: 12,
                                            color: AppColors.blackColor,
                                          ),
                                          const SizedBox(height: 8),
                                          // Expertise tags
                                          if (speaker.expertise.isNotEmpty)
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: speaker.expertise.take(3).map((expertise) =>
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primaryColor.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: AppText(
                                                      text: expertise,
                                                      fontSize: 10,
                                                      color: AppColors.primaryColor,
                                                    ),
                                                  ),
                                              ).toList(),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ).toList(),
                ],

                const SizedBox(height: 24),

                // Session Details with dynamic data
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Session Details",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),

                      if (session.tags.isNotEmpty) ...[
                        const Text(
                          "Key Topics",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        // Make tags selectable
                        Column(
                          children: session.tags.map((tag) => GestureDetector(
                            onTap: () {
                              _navigateToCreateForum(tag);
                            },
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.lightGreyColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: AppText(
                                      text: tag,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.darkgrey),
                                ],
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Registration Status
                      const Text(
                        "Registration",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        session.registrationRequired
                            ? "Registration required • ${session.registrationCount} registered out of ${session.capacity} capacity"
                            : "No registration required",
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),

                      // Session Status
                      const Text(
                        "Session Status",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        session.isActive ? "Active" : "Inactive",
                        style: TextStyle(
                            fontSize: 14,
                            color: session.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
// Who's Attending Section - Only show if registration is required
                if (session.registrationRequired) ...[
                  const SizedBox(height: 24),
                  const Text(
                    "Who's Attending",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with count and capacity
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Session Attendance",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${session.registrationCount}/${session.capacity}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (session.registrationCount > 0) ...[
                          // Animated counter with pulse effect
                          Row(
                            children: [
                              // Animated avatar stack
                              _buildAnimatedAvatarStack(session.registrationCount),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Animated counter
                                    _buildAnimatedCounter(session.registrationCount),
                                    const SizedBox(height: 4),
                                    // Progress text
                                    Text(
                                      _getAttendanceMessage(session.registrationCount, session.capacity),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Progress bar for visual representation
                          const SizedBox(height: 16),
                          _buildAttendanceProgressBar(session.registrationCount, session.capacity),
                        ] else ...[
                          // Empty state with animation
                          _buildEmptyAttendanceState(),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  // Show message when no registration required
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Colors.blue[600], size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Open Session",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "No registration required. Join the session anytime!",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Only show the main action button
                Obx(() {
                  if (statusController.isLoading.value) {
                    return Center(
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 8),
                          AppText(
                            text: 'Checking session status...',
                            fontSize: 12,
                            color: AppColors.darkgrey,
                          ),
                        ],
                      ),
                    );
                  }

                  final isRegistered = statusController.isRegistered;
                  final registrationRequired = session.registrationRequired;

                  print('=== Button Status - isRegistered: $isRegistered, registrationRequired: $registrationRequired ===');

                  return FutureBuilder<String?>(
                    future: SharedPrefsHelper.getUserRole(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data == 'speaker') {
                        // Speaker always sees "Join as Host" regardless of registration status
                        return _buildButton(
                          label: "Join as Host",
                          color: AppColors.primaryColor,
                          textColor: Colors.white,
                          onTap: _showJoinSessionDialog,
                        );
                      } else {
                        // Participant logic remains the same
                        if (!registrationRequired || isRegistered) {
                          return _buildButton(
                            label: "Join Session",
                            color: AppColors.primaryColor,
                            textColor: Colors.white,
                            onTap: _showJoinSessionDialog,
                          );
                        } else {
                          return _buildButton(
                            label: "Register for Session",
                            color: AppColors.primaryColor,
                            textColor: Colors.white,
                            onTap: _showRegistrationDialog,
                          );
                        }
                      }
                    },
                  );
                }),
                const SizedBox(height: 24),

                // Related Sessions Section
                if (relatedSessions.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        text: 'Related Sessions',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      GestureDetector(
                        onTap: () {
                          print('=== View All related sessions tapped ===');
                          Get.to(() => ConferenceScheduleScreen());
                        },
                        child: const AppText(
                          text: 'View All',
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dynamic related session cards
                  ...relatedSessions.map((relatedSession) {
                    print('=== Rendering related session card for ID: ${relatedSession.sessionId} ===');
                    return SessionCard(
                      title: relatedSession.sessionTitle,
                      speaker: relatedSession.speakers.isNotEmpty
                          ? relatedSession.speakers.first.fullName
                          : 'Speaker TBA',
                      speakerRole: relatedSession.speakers.isNotEmpty
                          ? relatedSession.speakers.first.bio.length > 20
                          ? '${relatedSession.speakers.first.bio.substring(0, 20)}...'
                          : relatedSession.speakers.first.bio
                          : 'Role TBA',
                      description: relatedSession.sessionDescription,
                      time: relatedSession.formattedTime,
                      duration: _calculateDurationFromModel(relatedSession),
                      room: relatedSession.displayLocation,
                      sessionType: relatedSession.category,
                      isBookmarked: false,
                      onBookmarkTap: () {
                        print('=== Bookmark tapped for session ${relatedSession.sessionId} ===');
                      },
                      onViewDetails: () {
                        print('=== View Details tapped for session ${relatedSession.sessionId} ===');
                        _navigateToRelatedSession(relatedSession.sessionId);
                      },
                    );
                  }).toList(),
                ],

                // ============ SPEAKER SPECIFIC: Other Sessions Section ============
                // Only show this section if user role is speaker
                FutureBuilder<String?>(
                  future: SharedPrefsHelper.getUserRole(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == 'speaker') {
                      final speakerSessionsViewModel = Get.find<SpeakerSessionsDetailShowViewModel>();

                      return Obx(() {
                        if (speakerSessionsViewModel.isLoading) {
                          return Center(
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 8),
                                AppText(
                                  text: 'Loading your sessions...',
                                  fontSize: 12,
                                  color: AppColors.darkgrey,
                                ),
                              ],
                            ),
                          );
                        }

                        if (speakerSessionsViewModel.error.isNotEmpty) {
                          return Container(
                            margin: const EdgeInsets.only(top: 24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                AppText(
                                  text: 'My Other Sessions',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                const SizedBox(height: 12),
                                AppText(
                                  text: 'Failed to load sessions: ${speakerSessionsViewModel.error}',
                                  fontSize: 14,
                                  color: Colors.red,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    final speakerId = Get.find<SpeakerDashboardShowViewModel>().speakerProfile?.id;
                                    if (speakerId != null) {
                                      speakerSessionsViewModel.fetchSpeakerSessions(speakerId);
                                    }
                                  },
                                  child: AppText(text: 'Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        final allSessions = speakerSessionsViewModel.sessions;
                        // Filter out the current session and take remaining sessions
                        final otherSessions = allSessions
                            .where((session) => session.id != widget.sessionId)
                            .toList();

                        if (otherSessions.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const AppText(
                                  text: 'My Other Sessions',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigate back to speaker dashboard
                                    Get.until((route) => route.isFirst);
                                    Get.to(() => SpeakerConferenceDashboardScreen());
                                  },
                                  child: const AppText(
                                    text: 'View All',
                                    fontSize: 14,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Other sessions cards
                            ...otherSessions.map((session) => _buildSpeakerSessionCard(session)).toList(),
                          ],
                        );
                      });
                    }

                    // If not speaker, return empty container
                    return const SizedBox.shrink();
                  },
                ),
                // ============ END SPEAKER SPECIFIC SECTION ============

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }
// Animated avatar stack with limited avatars
  Widget _buildAnimatedAvatarStack(int count) {
    return SizedBox(
      width: 60,
      height: 40,
      child: Stack(
        children: [
          // Base background circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_alt_rounded,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),

          // Floating count badge with animation
          Positioned(
            right: 0,
            top: 0,
            child: ScaleTransition(
              scale: Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: AlwaysStoppedAnimation(1.0),
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Animated counter with counting animation
  Widget _buildAnimatedCounter(int count) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 1500),
      tween: IntTween(begin: 0, end: count),
      builder: (context, value, child) {
        return RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: '$value',
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' attendees',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Progress bar for attendance visualization
  Widget _buildAttendanceProgressBar(int registered, int capacity) {
    final percentage = capacity > 0 ? registered / capacity : 0.0;

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 2000),
      tween: Tween<double>(begin: 0.0, end: percentage),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Column(
          children: [
            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  // Background
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Progress
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: MediaQuery.of(context).size.width * 0.8 * value,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Percentage text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(value * 100).toStringAsFixed(1)}% filled',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${capacity - registered} spots left',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

// Empty state with animation
  Widget _buildEmptyAttendanceState() {
    return Column(
      children: [
        ScaleTransition(
          scale: Tween(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: AlwaysStoppedAnimation(1.0),
              curve: Curves.elasticOut,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Be the first to join!",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "No one has registered yet. Don't miss out!",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

// Helper method to get appropriate attendance message
  String _getAttendanceMessage(int registered, int capacity) {
    final percentage = capacity > 0 ? registered / capacity : 0.0;

    if (percentage == 0) {
      return "Session is empty. Be the first to join!";
    } else if (percentage < 0.3) {
      return "Great time to join - plenty of spots available!";
    } else if (percentage < 0.7) {
      return "Filling up fast! Join now to secure your spot.";
    } else if (percentage < 1.0) {
      return "Almost full! Limited spots remaining.";
    } else {
      return "Session is fully booked!";
    }
  }
  // Helper method to build speaker session card
  Widget _buildSpeakerSessionCard(SpeakerSessionModel session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText(
                  text: session.title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: session.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  text: session.status,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: session.statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Speaker info
          if (session.speakers.isNotEmpty) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primaryColor,
                  backgroundImage: session.speakers.first.file.isNotEmpty
                      ? NetworkImage(session.speakers.first.file)
                      : null,
                  child: session.speakers.first.file.isEmpty
                      ? AppText(
                    text: session.speakers.first.name.split(' ').map((e) => e[0]).join(''),
                    fontSize: 10,
                    color: AppColors.whiteColor,
                  )
                      : null,
                ),
                const SizedBox(width: 8),
                AppText(
                  text: session.speakers.first.name,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Description (truncated)
          AppText(
            text: session.description.length > 100
                ? '${session.description.substring(0, 100)}...'
                : session.description,
            fontSize: 13,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 12),

          // Time and location
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: AppColors.darkgrey),
              const SizedBox(width: 4),
              AppText(
                text: session.formattedTime,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, size: 14, color: AppColors.darkgrey),
              const SizedBox(width: 4),
              AppText(
                text: session.displayLocation,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Duration and category
          Row(
            children: [
              AppText(
                text: 'Duration',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              const Spacer(),
              AppText(
                text: session.duration,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
              const SizedBox(width: 16),
              AppText(
                text: 'Type',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              const Spacer(),
              AppText(
                text: session.category,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to this session's details
                Get.to(() => SessionDetailsScreen(
                  sessionId: session.id,
                  key: ValueKey('session_${session.id}'),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const AppText(
                text: 'View Details',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to calculate duration from SessionModel
  String _calculateDurationFromModel(SessionModel session) {
    try {
      final startTime = session.duration.split(' - ')[0];
      final endTime = session.duration.split(' - ')[1];
      return _calculateDuration(startTime, endTime);
    } catch (e) {
      return 'TBD';
    }
  }

  // Helper method to build tag rows (2 per row)
  List<Widget> _buildTagRows(List<String> tags) {
    List<Widget> rows = [];
    for (int i = 0; i < tags.length; i += 2) {
      List<Widget> rowChildren = [];

      // First tag in row
      if (i < tags.length) {
        rowChildren.add(Expanded(child: _buildChip(tags[i])));
      }

      // Second tag in row (if exists)
      if (i + 1 < tags.length) {
        rowChildren.add(const SizedBox(width: 8));
        rowChildren.add(Expanded(child: _buildChip(tags[i + 1])));
      }

      rows.add(Row(children: rowChildren));
      if (i + 2 < tags.length) {
        rows.add(const SizedBox(height: 8));
      }
    }
    return rows;
  }

  // Helper widget for Chips
  Widget _buildChip(String text) {
    return Chip(
      label: AppText(
        text: text,
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
      backgroundColor: AppColors.lightred,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  // Helper widget for Buttons
  Widget _buildButton({
    required String label,
    IconData? icon,
    required Color color,
    required Color textColor,
    VoidCallback? onTap, // Add this parameter
  }) {
    return GestureDetector(
      onTap: onTap, // Use the onTap callback
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
            ],
            AppText(
              text: label,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }

  // Handle join session
  void _handleJoinSession() {
    print('=== Join Session tapped for session ${widget.sessionId} ===');
    // Add your join session logic here
    Get.snackbar(
      'Success',
      'Joining session...',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

// Handle register session
  void _handleRegisterSession() {
    print('=== Register Session tapped for session ${widget.sessionId} ===');
    // Add your registration logic here
    Get.snackbar(
      'Info',
      'Registration functionality to be implemented',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

// Handle attending
  void _handleAttending() {
    print('=== I\'m Attending tapped for session ${widget.sessionId} ===');
    // Add your attending logic here
    Get.snackbar(
      'Success',
      'Marked as attending!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _showRegistrationDialog() {
    print('=== Showing registration dialog for session: ${widget.sessionId} ===');
    Get.dialog(
      ParticipantSessionRegistrationDialog(
        sessionId: widget.sessionId,
        onRegistrationSuccess: () {
          // Refresh session status after successful registration
          if (_currentUserId != null) {
            print('=== Refreshing session status after registration ===');
            statusController.fetchSessionStatus(widget.sessionId, _currentUserId!);
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  void _showJoinSessionDialog() {
    print('=== Showing join session dialog for session: ${widget.sessionId} ===');
    final session = controller.sessionDetails.value;
    Get.dialog(
      JoinSessionDialog(
        sessionId: widget.sessionId,
        sessionTitle: session.title, // Pass the actual session title
      ),
      barrierDismissible: false,
    );
  }

  void _navigateToCreateForum(String selectedTag) {
    if (_currentUserId == null) {
      Get.snackbar(
        'Error',
        'User not found. Please login again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.to(() => CreateNewForumScreen(
      sessionId: widget.sessionId,
      userId: _currentUserId!,
      selectedTag: selectedTag,
    ));
  }

  @override
  void didUpdateWidget(SessionDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.sessionId != widget.sessionId) {
      print('=== Session ID changed from ${oldWidget.sessionId} to ${widget.sessionId}, refreshing data ===');

      // Clear previous controllers if they exist
      Get.delete<SessionDetailShowViewModel>(tag: 'session_${oldWidget.sessionId}');
      Get.delete<SessionRegisterBookmarkStatusViewModel>(tag: 'status_${oldWidget.sessionId}');
      Get.delete<MakeSessionBookmarkedViewModel>(tag: 'bookmark_${oldWidget.sessionId}');

      // Create new controllers for the new sessionId
      controller = Get.put(SessionDetailShowViewModel(), tag: 'session_${widget.sessionId}');
      statusController = Get.put(SessionRegisterBookmarkStatusViewModel(), tag: 'status_${widget.sessionId}');
      bookmarkController = Get.put(MakeSessionBookmarkedViewModel(), tag: 'bookmark_${widget.sessionId}');

      // Fetch new data
      _getUserDataAndFetch();
    }
  }
}
