import 'package:al_sharq_conference/organizer_view/organizer_dashboard/organizer_profile_screen.dart';
import 'package:al_sharq_conference/organizer_view/organizer_dashboard/participant_detail_screen.dart';
import 'package:al_sharq_conference/organizer_view/organizer_dashboard/view_all_participants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/images/images.dart';
import '../../data/response_models/organizer_response_models/organizer_dashboard_small_detail_show_model.dart';
import '../../view_model/organizer_viewmodels/organizer_dashboard_small_detail_show_viewmodel.dart';
import '../../view_model/participant_viewmodel/participant_profile/participant_profile_get_viewmodel.dart';
import '../manage_announcement/manage_announcement.dart';
import '../manage_exhibitors/organizer_manage_exhibitors_screen.dart';
import '../manage_participants/manage_participants_view.dart';
import '../manage_session/manage_session_view.dart';
import '../manage_speaker/manage_speaker_view.dart';
import '../manage_faqs/manage_faqs_view.dart';
import '../manager_sponser/manage_sponser.dart';
import '../organizer_venue_map/organizer_venue_map.dart';
import '../report_view/report_view.dart';
import '../qrcode_scanner/qrcode_scanner.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  final TextEditingController searchController = TextEditingController();
  final OrganizerDashboardSmallDetailShowViewModel _dashboardViewModel =
  Get.put(OrganizerDashboardSmallDetailShowViewModel());
  final ParticipantProfileGetViewModel _profileViewModel = Get.put(ParticipantProfileGetViewModel());

  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    // Fetch profile data when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  // Soft refresh method - fetches data silently without showing loading indicators
  void _refreshData() {
    print('=== Refreshing dashboard data ===');
    _profileViewModel.fetchProfile();
    _dashboardViewModel.fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    // Refresh data on every build except the first one (which is handled in initState)
    if (!_isFirstBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshData();
      });
    } else {
      _isFirstBuild = false;
    }
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: AppColors.lightGreyColor,
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
          GestureDetector(
            onTap: () {
              Get.to(() => const OrganizerProfileScreen());
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
                  final profile = _profileViewModel.profile;

                  if (_profileViewModel.isLoading) {
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
                        // Fallback to default avatar if image fails to load
                        return _buildDefaultAvatar();
                      },
                    );
                  }

                  // Default avatar if no profile image
                  return _buildDefaultAvatar();
                }),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (_dashboardViewModel.isLoading.value && _dashboardViewModel.dashboardData.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 16),
                AppText(
                  text: 'Loading dashboard...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        if (_dashboardViewModel.error.isNotEmpty && _dashboardViewModel.dashboardData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: _dashboardViewModel.error.value,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _dashboardViewModel.fetchDashboardData,
                  child: const AppText(text: 'Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              CustomTextField(
                hintText: 'Search',
                controller: searchController,
                suffixIcon: Icons.tune,
                suffixIconColor: AppColors.primaryColor,
              ),

              const SizedBox(height: 20),

              // Stats Cards Row 1
              Row(
                children: [
                  Expanded(child: _buildStatCard(
                      'Total Registrations',
                      _dashboardViewModel.formattedTotalRegistrations,
                      Icons.person,
                      Colors.blue
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                      'Checked In',
                      _dashboardViewModel.formattedTotalCheckins,
                      Icons.check_circle,
                      Colors.green
                  )),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _buildStatCard(
                      'Active Sessions',
                      _dashboardViewModel.formattedActiveSessions,
                      Icons.play_circle,
                      Colors.red
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                      'Speakers',
                      _dashboardViewModel.formattedTotalSpeakers,
                      Icons.mic,
                      Colors.green
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                      'Sponsors',
                      _dashboardViewModel.formattedTotalSponsors,
                      Icons.business,
                      Colors.orange
                  )),
                ],
              ),

              const SizedBox(height: 12),

              // Exhibitor card and Participants count card
              Row(
                children: [
                  Expanded(child: _buildStatCard(
                      'Exhibitors',
                      _dashboardViewModel.formattedTotalExhibitors,
                      Icons.explore,
                      Colors.purple
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard(
                      'Recent Participants',
                      _dashboardViewModel.recentUsers.length.toString(),
                      Icons.people_alt,
                      Colors.blue
                  )),
                ],
              ),

              const SizedBox(height: 20),

              // // Today's Schedule
              // _buildSectionHeader("Today's Schedule", 'View All'),
              // const SizedBox(height: 12),
              // _buildScheduleCard(
              //   'Opening Keynote',
              //   'Future of Digital MENA',
              //   '9:00 AM',
              //   Colors.red,
              // ),

              const SizedBox(height: 20),

              // Quick Access
              const AppText(
                text: 'Quick Access',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: InkWell(
                      onTap: (){
                        Get.to(() => ManageParticipantsScreen());
                      },
                      child: _buildQuickAccessCard('Manage Participants', Icons.people, Colors.blue))),
                  const SizedBox(width: 12),
                  Expanded(child: InkWell(
                      onTap: (){
                        Get.to(() => OrganizerManageSessionsScreen());
                      },
                      child: _buildQuickAccessCard('Manage Sessions', Icons.event_note, Colors.blue))),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: InkWell(
                      onTap: (){
                        Get.to(() => OrganizerShowAllSpeakerScreen());
                      },
                      child: _buildQuickAccessCard('Manage Speakers', Icons.mic, Colors.yellow))),
                  const SizedBox(width: 12),
                  Expanded(child: InkWell(
                      onTap: (){
                        Get.to(() => ManageSponsorsScreen());
                      },
                      child: _buildQuickAccessCard('Sponsors', Icons.business, Colors.orange))),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: InkWell(
                      onTap: (){
                        Get.to(() => OrganizerVenueMapsScreen());
                      },
                      child: _buildQuickAccessCard('Venue Maps', Icons.map, Colors.red))),
                  const SizedBox(width: 12),
                  Expanded(child: InkWell(
                      onTap: () => Get.to(() => ManageAnnouncementsScreen()),
                      child: _buildQuickAccessCard('Announcement', Icons.campaign, Colors.red))),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: InkWell(
                      onTap: (){
                        Get.to(() => OrganizerManageExhibitorsScreen());
                      },
                      child: _buildQuickAccessCard('Exhibitors', Icons.shower_sharp, Colors.red))),

                ],
              ),

              const SizedBox(height: 20),

              // Tools & Support
              const AppText(
                text: 'Tools & Support',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 12),

              InkWell(
                  onTap: (){
                    Get.to(() => QRScannerScreen());
                  },
                  child: _buildToolCard(Icons.qr_code, 'QR Scanner', 'Manage check-ins', Colors.grey)),
              InkWell(
                  onTap: (){
                    Get.to(() => ReportScreen());
                  },
                  child: _buildToolCard(Icons.report, 'Reports', 'Generate reports', Colors.teal)),
              InkWell(
                  onTap: (){
                    Get.to(() => ManageFAQsScreen());
                  },
                  child: _buildToolCard(Icons.help, 'Manage FAQ', 'Help & Support', Colors.orange)),

              const SizedBox(height: 20),

              // Recent Participants
              _buildSectionHeader(
                'Recent Participants',
                'View All',
                onTap: () {
                  Get.to(() => ViewAllParticipantsScreen());
                },
              ),
              const SizedBox(height: 12),

              // Display recent users from API
              if (_dashboardViewModel.recentUsers.isNotEmpty)
                ..._dashboardViewModel.recentUsers.map((user) =>
                    _buildParticipantCard(user)
                ).toList()
              else
                const AppText(
                  text: 'No recent participants',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.download, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    const AppText(
                      text: 'Export Report',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    const Spacer(),
                    const AppText(
                      text: 'Download CSV',
                      fontSize: 12,
                      color: AppColors.darkgrey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.brown,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          AppText(
            text: title,
            fontSize: 12,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 4),
          AppText(
            text: value,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: title,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          AppText(
            text: action,
            fontSize: 14,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
  Widget _buildScheduleCard(String title, String subtitle, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                AppText(
                  text: subtitle,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),
          AppText(
            text: time,
            fontSize: 12,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          AppText(
            text: title,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                AppText(
                  text: subtitle,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.darkgrey),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(OrganizerDashboardSmallDetailShowRecentUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryColor,
            child: AppText(
              text: user.name.isNotEmpty ? user.name[0] : 'U',
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: user.name,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                AppText(
                  text: user.organization ?? 'Participant',
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Get.to(() => ParticipantDetailScreen(user: user));
            },
            child: const AppText(
              text: 'View Details',
              fontSize: 12,
              color: AppColors.primaryColor,
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









// import 'package:al_sharq_conference/organizer_view/organizer_dashboard/organizer_profile_screen.dart';
// import 'package:al_sharq_conference/organizer_view/organizer_dashboard/participant_detail_screen.dart';
// import 'package:al_sharq_conference/organizer_view/organizer_dashboard/view_all_participants.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
// import 'package:al_sharq_conference/app_colors/app_colors.dart';
// import 'package:al_sharq_conference/custom_widgets/app_text.dart';
// import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
// import 'package:al_sharq_conference/images/images.dart';
// import '../../data/response_models/organizer_response_models/organizer_dashboard_small_detail_show_model.dart';
// import '../../view_model/organizer_viewmodels/organizer_dashboard_small_detail_show_viewmodel.dart';
// import '../../view_model/participant_viewmodel/participant_profile/participant_profile_get_viewmodel.dart';
// import '../manage_announcement/manage_announcement.dart';
// import '../manage_exhibitors/organizer_manage_exhibitors_screen.dart';
// import '../manage_participants/manage_participants_view.dart';
// import '../manage_session/manage_session_view.dart';
// import '../manage_speaker/manage_speaker_view.dart';
// import '../manage_faqs/manage_faqs_view.dart';
// import '../manager_sponser/manage_sponser.dart';
// import '../organizer_venue_map/organizer_venue_map.dart';
// import '../report_view/report_view.dart';
// import '../qrcode_scanner/qrcode_scanner.dart';
//
// class OrganizerDashboard extends StatefulWidget {
//   const OrganizerDashboard({super.key});
//
//   @override
//   State<OrganizerDashboard> createState() => _OrganizerDashboardState();
// }
//
// class _OrganizerDashboardState extends State<OrganizerDashboard> {
//   final TextEditingController searchController = TextEditingController();
//   final OrganizerDashboardSmallDetailShowViewModel _dashboardViewModel =
//   Get.put(OrganizerDashboardSmallDetailShowViewModel());
//   final ParticipantProfileGetViewModel _profileViewModel = Get.put(ParticipantProfileGetViewModel());
//
//   @override
//   void initState() {
//     super.initState();
//     // Fetch profile data when dashboard loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _profileViewModel.fetchProfile();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: CustomAppDrawer(),
//       backgroundColor: AppColors.lightGreyColor,
//       appBar:
//       AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.menu, color: Colors.black),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         title: Image(
//           image: AssetImage(Images.alsharqLogo),
//           height: 30,
//           width: 120,
//         ),
//         centerTitle: true,
//         actions: [
//           // Notification Icon
//           Stack(
//             children: [
//               Container(
//                 margin: const EdgeInsets.only(right: 8),
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: AppColors.lightred,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.notifications,
//                   color: AppColors.primaryColor,
//                   size: 20,
//                 ),
//               ),
//               Positioned(
//                 right: 10,
//                 top: 8,
//                 child: Icon(
//                   Icons.circle,
//                   size: 10,
//                   color: AppColors.secondaryIndicoColor,
//                 ),
//               ),
//             ],
//           ),
//
//           // Profile Avatar with Navigation
//           GestureDetector(
//             onTap: () {
//               Get.to(() => const OrganizerProfileScreen());
//             },
//             child: Container(
//               margin: const EdgeInsets.only(right: 16),
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: AppColors.primaryColor,
//                   width: 2,
//                 ),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: Obx(() {
//                   final profile = _profileViewModel.profile;
//
//                   if (_profileViewModel.isLoading) {
//                     return Container(
//                       color: Colors.grey.shade200,
//                       child: const Center(
//                         child: SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: AppColors.primaryColor,
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//
//                   if (profile?.file != null && profile!.file!.isNotEmpty) {
//                     return Image.network(
//                       profile.file!,
//                       width: 40,
//                       height: 40,
//                       fit: BoxFit.cover,
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Container(
//                           color: Colors.grey.shade200,
//                           child: Center(
//                             child: SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(
//                                 value: loadingProgress.expectedTotalBytes != null
//                                     ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                     : null,
//                                 strokeWidth: 2,
//                                 color: AppColors.primaryColor,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                       errorBuilder: (context, error, stackTrace) {
//                         // Fallback to default avatar if image fails to load
//                         return _buildDefaultAvatar();
//                       },
//                     );
//                   }
//
//                   // Default avatar if no profile image
//                   return _buildDefaultAvatar();
//                 }),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (_dashboardViewModel.isLoading.value && _dashboardViewModel.dashboardData.value == null) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(
//                   color: AppColors.primaryColor,
//                 ),
//                 SizedBox(height: 16),
//                 AppText(
//                   text: 'Loading dashboard...',
//                   fontSize: 14,
//                   color: AppColors.darkgrey,
//                 ),
//               ],
//             ),
//           );
//         }
//
//         if (_dashboardViewModel.error.isNotEmpty && _dashboardViewModel.dashboardData.value == null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 AppText(
//                   text: _dashboardViewModel.error.value,
//                   color: Colors.red,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _dashboardViewModel.fetchDashboardData,
//                   child: const AppText(text: 'Retry'),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Search Bar
//               CustomTextField(
//                 hintText: 'Search',
//                 controller: searchController,
//                 suffixIcon: Icons.tune,
//                 suffixIconColor: AppColors.primaryColor,
//               ),
//
//               const SizedBox(height: 20),
//
//               // Stats Cards Row 1
//               Row(
//                 children: [
//                   Expanded(child: _buildStatCard(
//                       'Total Registrations',
//                       _dashboardViewModel.formattedTotalRegistrations,
//                       Icons.person,
//                       Colors.blue
//                   )),
//                   const SizedBox(width: 12),
//                   Expanded(child: _buildStatCard(
//                       'Checked In',
//                       _dashboardViewModel.formattedTotalCheckins,
//                       Icons.check_circle,
//                       Colors.green
//                   )),
//                 ],
//               ),
//
//               const SizedBox(height: 12),
//
//               Row(
//                 children: [
//                   Expanded(child: _buildStatCard(
//                       'Active Sessions',
//                       _dashboardViewModel.formattedActiveSessions,
//                       Icons.play_circle,
//                       Colors.red
//                   )),
//                   const SizedBox(width: 12),
//                   Expanded(child: _buildStatCard(
//                       'Speakers',
//                       _dashboardViewModel.formattedTotalSpeakers,
//                       Icons.mic,
//                       Colors.green
//                   )),
//                   const SizedBox(width: 12),
//                   Expanded(child: _buildStatCard(
//                       'Sponsors',
//                       _dashboardViewModel.formattedTotalSponsors,
//                       Icons.business,
//                       Colors.orange
//                   )),
//                 ],
//               ),
//
//               const SizedBox(height: 12),
//
//               // Exhibitor card and Participants count card
//               Row(
//                 children: [
//                   Expanded(child: _buildStatCard(
//                       'Exhibitors',
//                       _dashboardViewModel.formattedTotalExhibitors,
//                       Icons.explore,
//                       Colors.purple
//                   )),
//                   const SizedBox(width: 12),
//                   Expanded(child: _buildStatCard(
//                       'Recent Participants',
//                       _dashboardViewModel.recentUsers.length.toString(),
//                       Icons.people_alt,
//                       Colors.blue
//                   )),
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//
//               // // Today's Schedule
//               // _buildSectionHeader("Today's Schedule", 'View All'),
//               // const SizedBox(height: 12),
//               // _buildScheduleCard(
//               //   'Opening Keynote',
//               //   'Future of Digital MENA',
//               //   '9:00 AM',
//               //   Colors.red,
//               // ),
//
//               const SizedBox(height: 20),
//
//               // Quick Access
//               const AppText(
//                 text: 'Quick Access',
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//               const SizedBox(height: 12),
//
//               Row(
//                 children: [
//                   Expanded(child: InkWell(
//                       onTap: (){
//                         Get.to(() => ManageParticipantsScreen());
//                       },
//                       child: _buildQuickAccessCard('Manage Participants', Icons.people, Colors.blue))),
//                   const SizedBox(width: 12),
//                   Expanded(child: InkWell(
//                       onTap: (){
//                         Get.to(() => OrganizerManageSessionsScreen());
//                       },
//                       child: _buildQuickAccessCard('Manage Sessions', Icons.event_note, Colors.blue))),
//                 ],
//               ),
//
//               const SizedBox(height: 12),
//
//               Row(
//                 children: [
//                   Expanded(child: InkWell(
//                       onTap: (){
//                         Get.to(() => OrganizerShowAllSpeakerScreen());
//                       },
//                       child: _buildQuickAccessCard('Manage Speakers', Icons.mic, Colors.yellow))),
//                   const SizedBox(width: 12),
//                   Expanded(child: InkWell(
//                       onTap: (){
//                         Get.to(() => ManageSponsorsScreen());
//                       },
//                       child: _buildQuickAccessCard('Sponsors', Icons.business, Colors.orange))),
//                 ],
//               ),
//
//               const SizedBox(height: 12),
//
//               Row(
//                 children: [
//                   Expanded(child: InkWell(
//                       onTap: (){
//                         Get.to(() => OrganizerVenueMapsScreen());
//                       },
//                       child: _buildQuickAccessCard('Venue Maps', Icons.map, Colors.red))),
//                   const SizedBox(width: 12),
//                   Expanded(child: InkWell(
//                       onTap: () => Get.to(() => ManageAnnouncementsScreen()),
//                       child: _buildQuickAccessCard('Announcement', Icons.campaign, Colors.red))),
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(child: InkWell(
//                       onTap: (){
//                         Get.to(() => OrganizerManageExhibitorsScreen());
//                       },
//                       child: _buildQuickAccessCard('Exhibitors', Icons.shower_sharp, Colors.red))),
//
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//
//               // Tools & Support
//               const AppText(
//                 text: 'Tools & Support',
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//               const SizedBox(height: 12),
//
//               InkWell(
//                   onTap: (){
//                     Get.to(() => QRScannerScreen());
//                   },
//                   child: _buildToolCard(Icons.qr_code, 'QR Scanner', 'Manage check-ins', Colors.grey)),
//               InkWell(
//                   onTap: (){
//                     Get.to(() => ReportScreen());
//                   },
//                   child: _buildToolCard(Icons.report, 'Reports', 'Generate reports', Colors.teal)),
//               InkWell(
//                   onTap: (){
//                     Get.to(() => ManageFAQsScreen());
//                   },
//                   child: _buildToolCard(Icons.help, 'Manage FAQ', 'Help & Support', Colors.orange)),
//
//               const SizedBox(height: 20),
//
//               // Recent Participants
//               _buildSectionHeader(
//                 'Recent Participants',
//                 'View All',
//                 onTap: () {
//                   Get.to(() => ViewAllParticipantsScreen());
//                 },
//               ),
//               const SizedBox(height: 12),
//
//               // Display recent users from API
//               if (_dashboardViewModel.recentUsers.isNotEmpty)
//                 ..._dashboardViewModel.recentUsers.map((user) =>
//                     _buildParticipantCard(user)
//                 ).toList()
//               else
//                 const AppText(
//                   text: 'No recent participants',
//                   fontSize: 14,
//                   color: AppColors.darkgrey,
//                 ),
//
//               const SizedBox(height: 16),
//
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppColors.whiteColor,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.download, color: AppColors.primaryColor),
//                     const SizedBox(width: 8),
//                     const AppText(
//                       text: 'Export Report',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black,
//                     ),
//                     const Spacer(),
//                     const AppText(
//                       text: 'Download CSV',
//                       fontSize: 12,
//                       color: AppColors.darkgrey,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildDefaultAvatar() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.brown,
//         shape: BoxShape.circle,
//       ),
//       child: const Center(
//         child: Icon(
//           Icons.person,
//           color: Colors.white,
//           size: 20,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.whiteColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 24),
//           const SizedBox(height: 8),
//           AppText(
//             text: title,
//             fontSize: 12,
//             color: AppColors.darkgrey,
//           ),
//           const SizedBox(height: 4),
//           AppText(
//             text: value,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title, String action, {VoidCallback? onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           AppText(
//             text: title,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//           AppText(
//             text: action,
//             fontSize: 14,
//             color: AppColors.primaryColor,
//           ),
//         ],
//       ),
//     );
//   }
//   Widget _buildScheduleCard(String title, String subtitle, String time, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.whiteColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 4,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 AppText(
//                   text: title,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                 ),
//                 AppText(
//                   text: subtitle,
//                   fontSize: 12,
//                   color: AppColors.darkgrey,
//                 ),
//               ],
//             ),
//           ),
//           AppText(
//             text: time,
//             fontSize: 12,
//             color: AppColors.darkgrey,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildQuickAccessCard(String title, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.whiteColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 32),
//           const SizedBox(height: 8),
//           AppText(
//             text: title,
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             color: Colors.black,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildToolCard(IconData icon, String title, String subtitle, Color color) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.whiteColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 24),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 AppText(
//                   text: title,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black,
//                 ),
//                 AppText(
//                   text: subtitle,
//                   fontSize: 12,
//                   color: AppColors.darkgrey,
//                 ),
//               ],
//             ),
//           ),
//           const Icon(Icons.chevron_right, color: AppColors.darkgrey),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildParticipantCard(OrganizerDashboardSmallDetailShowRecentUser user) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.whiteColor,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 16,
//             backgroundColor: AppColors.primaryColor,
//             child: AppText(
//               text: user.name.isNotEmpty ? user.name[0] : 'U',
//               fontSize: 14,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 AppText(
//                   text: user.name,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black,
//                 ),
//                 AppText(
//                   text: user.organization ?? 'Participant',
//                   fontSize: 12,
//                   color: AppColors.darkgrey,
//                 ),
//               ],
//             ),
//           ),
//           InkWell(
//             onTap: () {
//               Get.to(() => ParticipantDetailScreen(user: user));
//             },
//             child: const AppText(
//               text: 'View Details',
//               fontSize: 12,
//               color: AppColors.primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }
// }