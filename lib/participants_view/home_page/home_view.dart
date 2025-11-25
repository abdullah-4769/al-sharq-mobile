import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/participants_view/forum_chat/chat_list_view.dart';
import 'package:al_sharq_conference/participants_view/home_page/quick_access_item.dart';
import 'package:al_sharq_conference/participants_view/networking_view/networking_view.dart';
import 'package:al_sharq_conference/participants_view/venue_map/venue_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../data/response_models/participant_response_model/event_session_response_model.dart';
import '../../images/images.dart';
import '../../view_model/participant_viewmodel/event_session_viewmodel.dart';
import '../../view_model/participant_viewmodel/participant_profile/participant_profile_get_viewmodel.dart';
import '../../view_model/profile_visibility_view_model.dart';
import '../conference_schedule_view/conference_schedule_view.dart';
import '../faq_view/faq_view.dart';
import '../forum_chat/forum_chat.dart';
import '../forum_chat/forum_list_view.dart';
import '../forum_chat/join_forum_view.dart';
import '../live_chat_session_view/live_chat_session_view.dart';
import '../my_agenda_view/my_agenda_view.dart';
import '../profile_screen/profile_screen_participant.dart';
import '../qr_code_scanner/qr_code_scanner_view.dart';
import '../seesion_details_view/session_detail_view.dart';
import '../speakers_view/speaker_view.dart';
import '../sponser_exhibitors/sponser_exhibitors_view.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  final EventSessionsViewModel _sessionsViewModel = Get.put(EventSessionsViewModel());
  late AnimationController _animationController;
  late ProfileVisibilityViewModel _profileVisibilityViewModel = Get.put(ProfileVisibilityViewModel());

  bool isVisible = false;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Load sessions data
    _loadSessions();
    _loadProfile();
    _profileVisibilityViewModel = Get.put(ProfileVisibilityViewModel());

  }

  void _loadSessions() {
    _sessionsViewModel.fetchEventSessions(context);
  }
  void _loadProfile() {
    final profileViewModel = Get.put(ParticipantProfileGetViewModel());
    profileViewModel.fetchProfile();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomAppDrawer(),
      appBar:
      AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Image(
          image: AssetImage(Images.alsharqLogo),
          height: 30,
          width: 120,
        ),
        centerTitle: true,
        actions: [
          // Notification Icon
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightred,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              Positioned(
                right: 10,
                top: 8,
                child: Icon(
                  Icons.circle,
                  size: 10,
                  color: AppColors.secondaryIndicoColor,
                ),
              ),
            ],
          ),

          // Profile Avatar with Navigation
          // Profile Avatar with Navigation and Real Image
          GestureDetector(
            onTap: () {
              Get.to(() => const ProfileScreen());
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Obx(() {
                  // Get profile data from your ViewModel
                  final profileViewModel = Get.find<ParticipantProfileGetViewModel>();
                  final profile = profileViewModel.profile;

                  // Show loading indicator while fetching
                  if (profileViewModel.isLoading) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    );
                  }

                  // Show profile image if available
                  if (profile?.file != null && profile!.file!.isNotEmpty) {
                    return Image.network(
                      profile.file!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails to load
                        return Container(
                          color: Colors.brown,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        );
                      },
                    );
                  }

                  // Fallback to icon if no profile image
                  return Container(
                    color: Colors.brown,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      // AppBar(
      //   actions: [
      //     Row(
      //       children: [
      //         Image(
      //           image: AssetImage(Images.alsharqLogo),
      //           height: 30,
      //           width: 150,
      //         ),
      //         const SizedBox(width: 30),
      //         Stack(
      //           children: [
      //             Container(
      //               width: 40,
      //               height: 40,
      //               decoration: BoxDecoration(
      //                 color: AppColors.lightred,
      //                 shape: BoxShape.circle,
      //               ),
      //               child: Icon(
      //                 Icons.notifications,
      //                 color: AppColors.primaryColor,
      //                 size: 20,
      //               ),
      //             ),
      //             Positioned(
      //               left: 26,
      //               child: Icon(
      //                 Icons.circle,
      //                 size: 14,
      //                 color: AppColors.secondaryIndicoColor,
      //               ),
      //             ),
      //           ],
      //         ),
      //         const SizedBox(width: 12),
      //         Container(
      //           width: 40,
      //           height: 40,
      //           decoration: const BoxDecoration(shape: BoxShape.circle),
      //           child: ClipRRect(
      //             borderRadius: BorderRadius.circular(20),
      //             child: Container(
      //               color: Colors.brown,
      //               child: const Icon(
      //                 Icons.person,
      //                 color: Colors.white,
      //                 size: 20,
      //               ),
      //             ),
      //           ),
      //         ),
      //         const SizedBox(width: 20),
      //       ],
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Latest Update Card with Live Session
                Obx(() => _buildLatestUpdateCard()),
                const SizedBox(height: 24),

                // Today's Schedule Section
                Obx(() => _buildTodaysScheduleSection()),
                const SizedBox(height: 14),

                // Quick Access Section
                const AppText(
                  text: 'Quick Access',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                const SizedBox(height: 12),

                // Quick Access Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: [
                    QuickAccessItem(
                      imagePath: Images.myAgenda,
                      title: 'My Agenda',
                      subtitle: 'Personal schedule',
                      iconBackgroundColor: Colors.green.shade100,
                      onTap: () {
                        Get.to(MyAgendaScreen());
                      },
                    ),
                    QuickAccessItem(
                      imagePath: Images.schedule,
                      title: 'Schedule',
                      subtitle: 'Full program',
                      iconBackgroundColor: Colors.blue.shade100,
                      onTap: (){
                        Get.to(ConferenceScheduleScreen());
                      },
                    ),
                    QuickAccessItem(
                      imagePath: Images.speaker,
                      title: 'Speakers',
                      subtitle: 'Expert profiles',
                      iconBackgroundColor: Colors.pink.shade100,
                      onTap: (){
                        Get.to(SpeakersScreen());
                      },
                    ),
                    QuickAccessItem(
                      onTap: (){
                        Get.to(SponsorsExhibitorsScreen());
                      },
                      imagePath: Images.sponser,
                      title: 'Partners',
                      subtitle: 'Partners & exhibits',
                      iconBackgroundColor: Colors.orange.shade100,
                    ),
                    QuickAccessItem(
                      imagePath: Images.networking,
                      title: 'Networking',
                      subtitle: 'Connect & chat',
                      iconBackgroundColor: Colors.purple.shade100,
                      onTap: (){
                        Get.to(NetworkingScreen());
                      },
                    ),
                    // QuickAccessItem(
                    //     imagePath: Images.forums,
                    //     title: 'Forums',
                    //     subtitle: 'Discussions',
                    //     iconBackgroundColor: Colors.teal.shade100,
                    //     onTap: () {
                    //       Get.to(ForumsListScreen());
                    //     }
                    // ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tools & Support Section
                const AppText(
                  text: 'Tools & Support',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                const SizedBox(height: 16),

                // Tools & Support Items
                InkWell(
                  onTap: (){
                    Get.to(QRPassScreen());
                  },
                  child: _buildSupportItem(
                    icon: Icons.qr_code,
                    title: 'QR Code Pass',
                    subtitle: 'Entry & check-in',
                    color: Colors.grey.shade100,
                    iconColor: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 10.h,),
                _buildProfileVisibilityItem(_profileVisibilityViewModel),


                // const SizedBox(height: 12),
                // InkWell(
                //   onTap: (){
                //     Get.to(VenueMapsScreen());
                //   },
                //   child: _buildSupportItem(
                //     icon: Icons.map,
                //     title: 'Venue Maps',
                //     subtitle: 'Navigation & locations',
                //     color: Colors.red.shade50,
                //     iconColor: Colors.red,
                //   ),
                // ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: (){
                    Get.to(FAQSupportScreen());
                  },
                  child: _buildSupportItem(
                    icon: Icons.help,
                    title: 'FAQ & Support',
                    subtitle: 'Help & guidance',
                    color: Colors.orange.shade50,
                    iconColor: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestUpdateCard() {
    if (_sessionsViewModel.isLoading.value) {
      return _buildLoadingCard();
    }

    final allSessions = _sessionsViewModel.allSessions;

    // Find live sessions (isLive: true)
    final liveSessions = allSessions.where((session) => session.isLive == true).toList();

    if (liveSessions.isEmpty) {
      // If no live sessions, show the first upcoming session or a default message
      final nonLiveSessions = allSessions.where((session) => session.isLive == false).toList();
      if (nonLiveSessions.isNotEmpty) {
        final nextSession = nonLiveSessions.first;
        return _buildSessionCard(
          session: nextSession,
          isLive: false,
          title: 'Next Session',
          onTap: () => _navigateToSessionDetails(nextSession.sessionId),
        );
      }

      return _buildDefaultUpdateCard();
    }

    // Show the first live session
    final liveSession = liveSessions.first;
    return _buildSessionCard(
      session: liveSession,
      isLive: true,
      title: 'Live Now',
      onTap: () => _navigateToSessionDetails(liveSession.sessionId),
    );
  }
  Widget _buildTodaysScheduleSection() {
    if (_sessionsViewModel.isLoading.value) {
      return _buildLoadingSchedule();
    }

    final allSessions = _sessionsViewModel.allSessions;

    // DEBUG: Print all sessions to see what we're working with
    print('=== DEBUG: All Sessions Count: ${allSessions.length} ===');
    for (var session in allSessions) {
      print('Session ${session.sessionId}: isLive=${session.isLive}, title="${session.sessionTitle}"');
    }

    // Filter sessions that are not live (isLive: false)
    final nonLiveSessions = allSessions.where((session) => session.isLive == false).toList();

    // DEBUG: Print non-live sessions
    print('=== DEBUG: Non-live Sessions Count: ${nonLiveSessions.length} ===');
    for (var session in nonLiveSessions) {
      print('Non-live Session ${session.sessionId}: title="${session.sessionTitle}"');
    }

    if (nonLiveSessions.isEmpty) {
      print('=== DEBUG: No non-live sessions found, showing default message ===');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                text: "Today's Schedule",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              InkWell(
                onTap: () {
                  Get.to(() => ConferenceScheduleScreen());
                },
                child: const AppText(
                  text: 'View All',
                  fontSize: 14,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNoSessionsItem(),
        ],
      );
    }

    // Get the first non-live session
    final nextNonLiveSession = nonLiveSessions.first;
    print('=== DEBUG: Selected Session for Today\'s Schedule: ${nextNonLiveSession.sessionId} - "${nextNonLiveSession.sessionTitle}" ===');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              text: "Today's Schedule",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            InkWell(
              onTap: () {
                Get.to(() => ConferenceScheduleScreen());
              },
              child: const AppText(
                text: 'View All',
                fontSize: 14,
                color: AppColors.blackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildScheduleItem(nextNonLiveSession),
      ],
    );
  }

  Widget _buildNoSessionsItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightred,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.schedule, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No upcoming sessions',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Check back later for scheduled sessions',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard({
    required SessionModel session,
    required bool isLive,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Blinking Live Indicator (only for live sessions)
          if (isLive) _buildBlinkingLiveIndicator(),
          if (!isLive) _buildUpcomingIndicator(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  color: AppColors.whiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                AppText(
                  text: session.sessionTitle,
                  color: AppColors.whiteColor,
                  fontSize: 12,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                AppText(
                  text: '${session.formattedTime} • ${session.location}',
                  color: AppColors.whiteColor.withOpacity(0.8),
                  fontSize: 10,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward, color: AppColors.whiteColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(SessionModel session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightred,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _navigateToSessionDetails(session.sessionId),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.sessionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${session.formattedTime} • ${session.location}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                if (session.category.isNotEmpty)
                  Text(
                    session.category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black45,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _navigateToSessionDetails(session.sessionId),
            icon: const Icon(Icons.arrow_forward, color: AppColors.primaryColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildBlinkingLiveIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing outer circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(_animationController.value * 0.5),
                shape: BoxShape.circle,
              ),
            ),
            // Inner solid circle
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _buildProfileVisibilityItem(ProfileVisibilityViewModel viewModel) {
    return Obx(
          () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.visibility,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'Profile Visibility',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    text: viewModel.isVisible.value
                        ? 'Your profile is visible'
                        : 'Your profile is hidden',
                    fontSize: 11,
                    color: AppColors.darkgrey,
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: viewModel.isVisible.value,
                onChanged: (value) {
                  viewModel.updateProfileVisibility(value);
                },
                activeColor: AppColors.primaryColor,
                activeTrackColor: AppColors.primaryColor.withOpacity(0.4),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildUpcomingIndicator() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.schedule,
        color: Colors.orange,
        size: 16,
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Loading...',
                  color: AppColors.whiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                AppText(
                  text: 'Fetching latest updates',
                  color: AppColors.whiteColor,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText(
              text: "Today's Schedule",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightred,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultUpdateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Latest Update',
                  color: AppColors.whiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                AppText(
                  text: 'No sessions scheduled for today',
                  color: AppColors.whiteColor,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSessionDetails(int sessionId) {
    // Navigate to session details screen with sessionId
    Get.to(() => SessionDetailsScreen(sessionId: sessionId));
    print('Navigating to session details for ID: $sessionId');
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                AppText(
                  text: subtitle,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, color: AppColors.primaryColor, size: 22),
        ],
      ),
    );
  }
}


