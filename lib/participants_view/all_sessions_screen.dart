// lib/participants_view/all_sessions_view/all_sessions_screen.dart
import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/participants_view/seesion_details_view/session_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../data/response_models/participant_response_model/session_model.dart';
import '../../utils/shared_preference.dart';
import '../../view_model/participant_viewmodel/event_session_viewmodel.dart';
import '../registration_team/session_card_with_scan.dart';

class AllSessionsScreen extends StatefulWidget {
  const AllSessionsScreen({super.key});

  @override
  State<AllSessionsScreen> createState() => _AllSessionsScreenState();
}

class _AllSessionsScreenState extends State<AllSessionsScreen> {
  TextEditingController searchController = TextEditingController();
  final EventSessionsViewModel sessionsController = Get.find<EventSessionsViewModel>();

  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool? _isRegistrationTeam;

  @override
  void initState() {
    super.initState();
    _checkUserRole();

    // Fetch sessions when screen loads if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sessionsController.allSessions.isEmpty) {
        sessionsController.fetchEventSessions(context);
      }
    });
  }

  Future<void> _checkUserRole() async {
    final role = await SharedPrefsHelper.getUserRole();
    setState(() {
      _isRegistrationTeam = role == 'registrationteam' || role == 'organization';
    });
  }

  void _navigateToSessionDetails(int sessionId) {
    Get.to(() => SessionDetailsScreen(sessionId: sessionId));
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  // Filter sessions based on search query and selected filter
  List<SessionModel> get _filteredSessions {
    List<SessionModel> allSessions = sessionsController.allSessions;

    // Apply filter
    List<SessionModel> filtered = [];

    switch (_selectedFilter) {
      case 'live':
        filtered = allSessions.where((session) => session.isCurrentlyLive).toList();
        break;
      case 'upcoming':
        filtered = allSessions.where((session) => session.isUpcoming).toList();
        break;
      case 'past':
        filtered = allSessions.where((session) => session.isPast).toList();
        break;
      case 'today':
        filtered = allSessions.where((session) => session.isToday).toList();
        break;
      default: // 'all'
        filtered = allSessions;
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((session) =>
      session.sessionTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (session.sessionDescription?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          session.speakers.any((speaker) =>
              speaker.fullName.toLowerCase().contains(_searchQuery.toLowerCase())
          ) ||
          (session.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (session.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }

    // Sort sessions by date (past first, then today, then future)
    filtered.sort((a, b) {
      if (a.isPast && !b.isPast) return -1;
      if (!a.isPast && b.isPast) return 1;
      if (a.isCurrentlyLive && !b.isCurrentlyLive) return -1;
      if (!a.isCurrentlyLive && b.isCurrentlyLive) return 1;
      if (a.isUpcomingToday && !b.isUpcomingToday) return -1;
      if (!a.isUpcomingToday && b.isUpcomingToday) return 1;
      return a.startDateTime.compareTo(b.startDateTime);
    });

    return filtered;
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
          text: "All Sessions",
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
                  text: "Loading all sessions...",
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        final filteredSessions = _filteredSessions;

        // Count sessions by status
        final liveCount = sessions.where((s) => s.isCurrentlyLive).length;
        final upcomingCount = sessions.where((s) => s.isUpcoming).length;
        final pastCount = sessions.where((s) => s.isPast).length;
        final todayCount = sessions.where((s) => s.isToday).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              CustomTextField(
                hintText: "Search sessions, speakers, topics...",
                controller: searchController,
                suffixIcon: Icons.search,
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 16),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', 'all', sessions.length),
                    const SizedBox(width: 8),
                    _buildFilterChip('Live', 'live', liveCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Today', 'today', todayCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Upcoming', 'upcoming', upcomingCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('Past', 'past', pastCount),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Results Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: "${filteredSessions.length} session${filteredSessions.length == 1 ? '' : 's'}",
                    fontSize: 14,
                    color: AppColors.darkgrey,
                    fontWeight: FontWeight.w500,
                  ),
                  if (_selectedFilter != 'all')
                    GestureDetector(
                      onTap: () => _onFilterChanged('all'),
                      child: Row(
                        children: [
                          AppText(
                            text: "Clear filter",
                            fontSize: 13,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.clear, size: 16, color: AppColors.primaryColor),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Session List
              if (filteredSessions.isEmpty && _searchQuery.isNotEmpty)
                _buildNoResults()
              else if (filteredSessions.isEmpty)
                _buildEmptyState()
              else
                _buildSessionList(filteredSessions),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primaryColor : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => _onFilterChanged(value),
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          width: 1,
        ),
      ),
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
            text: 'Try adjusting your search or filter',
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
            text: 'No Sessions Available',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Check back later for conference sessions',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(List<SessionModel> sessions) {
    // Group sessions by date
    Map<String, List<SessionModel>> groupedByDate = {};

    for (var session in sessions) {
      final dateKey = _getFormattedDate(session);
      if (!groupedByDate.containsKey(dateKey)) {
        groupedByDate[dateKey] = [];
      }
      groupedByDate[dateKey]!.add(session);
    }

    // Sort dates
    final dates = groupedByDate.keys.toList();
    dates.sort((a, b) {
      if (a == 'Today') return -1;
      if (b == 'Today') return 1;
      return a.compareTo(b);
    });

    List<Widget> widgets = [];

    for (final date in dates) {
      final dateSessions = groupedByDate[date]!;

      widgets.addAll([
        // Date Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: date == 'Today' ? Colors.blue.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: date == 'Today' ? Colors.blue.shade100 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  text: date,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: date == 'Today' ? Colors.blue.shade800 : Colors.black87,
                ),
              ),
              AppText(
                text: "${dateSessions.length} session${dateSessions.length == 1 ? '' : 's'}",
                fontSize: 13,
                color: date == 'Today' ? Colors.blue.shade600 : AppColors.darkgrey,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Session Cards for this date
        ...dateSessions.map((session) => _buildSessionCard(session)).toList(),
        const SizedBox(height: 24),
      ]);
    }

    return Column(
      children: widgets,
    );
  }

// Update the _buildSessionCard method in AllSessionsScreen to be like this:
  Widget _buildSessionCard(SessionModel session) {
    // Check if user is registration team and show scan button
    final bool shouldShowScanButton = _isRegistrationTeam ?? false;

    // For registration team, we need to show scan button for ALL sessions
    // but only for upcoming or today sessions (not past sessions)
    final bool isScanEligible = !session.isPast &&
        (session.isToday || session.isUpcoming || session.isCurrentlyLive);

    return SessionCardWithScan(
      session: session,
      onViewDetails: () => _navigateToSessionDetails(session.sessionId),
      showScanButton: shouldShowScanButton && isScanEligible,
    );
  }

  String _getFormattedDate(SessionModel session) {
    final startDate = session.startDateTime;
    final now = DateTime.now();

    if (session.isToday) {
      return 'Today';
    }

    final dateFormat = DateFormat('MMM dd, yyyy');
    return dateFormat.format(startDate);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}







// // lib/participants_view/all_sessions_view/all_sessions_screen.dart
// import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
// import 'package:al_sharq_conference/participants_view/seesion_details_view/session_detail_view.dart';
// import 'package:flutter/material.dart';
// import 'package:al_sharq_conference/app_colors/app_colors.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../custom_widgets/app_text.dart';
// import '../../custom_widgets/custom_button.dart';
// import '../../custom_widgets/custom_text_field.dart';
// import '../../data/response_models/participant_response_model/session_model.dart';
// import '../../utils/shared_preference.dart';
// import '../../view_model/participant_viewmodel/event_session_viewmodel.dart';
//
// class AllSessionsScreen extends StatefulWidget {
//   const AllSessionsScreen({super.key});
//
//   @override
//   State<AllSessionsScreen> createState() => _AllSessionsScreenState();
// }
//
// class _AllSessionsScreenState extends State<AllSessionsScreen> {
//   TextEditingController searchController = TextEditingController();
//   final EventSessionsViewModel sessionsController = Get.find<EventSessionsViewModel>();
//
//   String _searchQuery = '';
//   String _selectedFilter = 'all'; // 'all', 'live', 'upcoming', 'past', 'today'
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Fetch sessions when screen loads if not already loaded
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (sessionsController.allSessions.isEmpty) {
//         sessionsController.fetchEventSessions(context);
//       }
//     });
//   }
//
//   void _navigateToSessionDetails(int sessionId) {
//     Get.to(() => SessionDetailsScreen(sessionId: sessionId));
//   }
//
//   void _onSearchChanged(String query) {
//     setState(() {
//       _searchQuery = query;
//     });
//   }
//
//   void _onFilterChanged(String filter) {
//     setState(() {
//       _selectedFilter = filter;
//     });
//   }
//
//   // Filter sessions based on search query and selected filter
//   List<SessionModel> get _filteredSessions {
//     List<SessionModel> allSessions = sessionsController.allSessions;
//
//     // Apply filter
//     List<SessionModel> filtered = [];
//
//     switch (_selectedFilter) {
//       case 'live':
//         filtered = allSessions.where((session) => session.isCurrentlyLive).toList();
//         break;
//       case 'upcoming':
//         filtered = allSessions.where((session) => session.isUpcoming).toList();
//         break;
//       case 'past':
//         filtered = allSessions.where((session) => session.isPast).toList();
//         break;
//       case 'today':
//         filtered = allSessions.where((session) => session.isToday).toList();
//         break;
//       default: // 'all'
//         filtered = allSessions;
//     }
//
//     // Apply search query
//     if (_searchQuery.isNotEmpty) {
//       filtered = filtered.where((session) =>
//       session.sessionTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           (session.sessionDescription?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
//           session.speakers.any((speaker) =>
//               speaker.fullName.toLowerCase().contains(_searchQuery.toLowerCase())
//           ) ||
//           (session.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
//           (session.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
//       ).toList();
//     }
//
//     // Sort sessions by date (past first, then today, then future)
//     filtered.sort((a, b) {
//       if (a.isPast && !b.isPast) return -1;
//       if (!a.isPast && b.isPast) return 1;
//       if (a.isCurrentlyLive && !b.isCurrentlyLive) return -1;
//       if (!a.isCurrentlyLive && b.isCurrentlyLive) return 1;
//       if (a.isUpcomingToday && !b.isUpcomingToday) return -1;
//       if (!a.isUpcomingToday && b.isUpcomingToday) return 1;
//       return a.startDateTime.compareTo(b.startDateTime);
//     });
//
//     return filtered;
//   }
//
//   // Get session status text and color
//   Map<String, dynamic> _getSessionStatus(SessionModel session) {
//     if (session.isCurrentlyLive) {
//       return {
//         'text': 'Live Now',
//         'color': Colors.red,
//        // 'icon': Icons.live_tv,
//         'backgroundColor': Colors.red.withOpacity(0.1),
//       };
//     } else if (session.isUpcomingToday) {
//       final minutes = session.minutesUntilStart;
//       String text = 'Upcoming Today';
//       if (minutes != null && minutes > 0) {
//         if (minutes > 60) {
//           text = 'Starts in ${minutes ~/ 60}h ${minutes % 60}m';
//         } else {
//           text = 'Starts in ${minutes}m';
//         }
//       }
//       return {
//         'text': text,
//         'color': Colors.blue,
//         'icon': Icons.access_time,
//         'backgroundColor': Colors.blue.withOpacity(0.1),
//       };
//     } else if (session.isUpcoming) {
//       return {
//         'text': 'Upcoming',
//         'color': Colors.green,
//         'icon': Icons.upcoming,
//         'backgroundColor': Colors.green.withOpacity(0.1),
//       };
//     } else if (session.isPast) {
//       return {
//         'text': 'Completed',
//         'color': Colors.grey,
//         'icon': Icons.check_circle,
//         'backgroundColor': Colors.grey.withOpacity(0.1),
//       };
//     } else {
//       return {
//         'text': 'Scheduled',
//         'color': AppColors.primaryColor,
//         'icon': Icons.calendar_today,
//         'backgroundColor': AppColors.primaryColor.withOpacity(0.1),
//       };
//     }
//   }
//
//   // Get formatted date for display
//   String _getFormattedDate(SessionModel session) {
//     final startDate = session.startDateTime;
//     final now = DateTime.now();
//
//     if (session.isToday) {
//       return 'Today';
//     }
//
//     final dateFormat = DateFormat('MMM dd, yyyy');
//     return dateFormat.format(startDate);
//   }
//
//   // Get tag color based on session type
//   Color _getTagColor(String sessionType) {
//     final type = sessionType.toLowerCase();
//     if (type.contains('keynote')) {
//       return AppColors.darkBlue;
//     } else if (type.contains('panel')) {
//       return Colors.yellow[700]!;
//     } else if (type.contains('workshop')) {
//       return Colors.green;
//     } else if (type.contains('breakout')) {
//       return Colors.orange;
//     } else if (type.contains('networking')) {
//       return Colors.purple;
//     } else if (type.contains('general discussion')) {
//       return Colors.blue;
//     } else {
//       return AppColors.primaryColor;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: const CustomAppDrawer(),
//       backgroundColor: AppColors.whiteColor,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const AppText(
//           text: "All Sessions",
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//         ),
//         centerTitle: true,
//       ),
//       body: Obx(() {
//         final sessions = sessionsController.allSessions;
//         final isLoading = sessionsController.isLoading.value;
//
//         if (isLoading && sessions.isEmpty) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 16),
//                 AppText(
//                   text: "Loading all sessions...",
//                   fontSize: 14,
//                   color: AppColors.darkgrey,
//                 ),
//               ],
//             ),
//           );
//         }
//
//         final filteredSessions = _filteredSessions;
//
//         // Count sessions by status
//         final liveCount = sessions.where((s) => s.isCurrentlyLive).length;
//         final upcomingCount = sessions.where((s) => s.isUpcoming).length;
//         final pastCount = sessions.where((s) => s.isPast).length;
//         final todayCount = sessions.where((s) => s.isToday).length;
//
//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Search Bar
//               CustomTextField(
//                 hintText: "Search sessions, speakers, topics...",
//                 controller: searchController,
//                 suffixIcon: Icons.search,
//                 onChanged: _onSearchChanged,
//               ),
//               const SizedBox(height: 16),
//
//               // Filter Chips
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     _buildFilterChip('All', 'all', sessions.length),
//                     const SizedBox(width: 8),
//                     _buildFilterChip('Live', 'live', liveCount),
//                     const SizedBox(width: 8),
//                     _buildFilterChip('Today', 'today', todayCount),
//                     const SizedBox(width: 8),
//                     _buildFilterChip('Upcoming', 'upcoming', upcomingCount),
//                     const SizedBox(width: 8),
//                     _buildFilterChip('Past', 'past', pastCount),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Results Count
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   AppText(
//                     text: "${filteredSessions.length} session${filteredSessions.length == 1 ? '' : 's'}",
//                     fontSize: 14,
//                     color: AppColors.darkgrey,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   if (_selectedFilter != 'all')
//                     GestureDetector(
//                       onTap: () => _onFilterChanged('all'),
//                       child: Row(
//                         children: [
//                           AppText(
//                             text: "Clear filter",
//                             fontSize: 13,
//                             color: AppColors.primaryColor,
//                           ),
//                           const SizedBox(width: 4),
//                           Icon(Icons.clear, size: 16, color: AppColors.primaryColor),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//
//               // Session List
//               if (filteredSessions.isEmpty && _searchQuery.isNotEmpty)
//                 _buildNoResults()
//               else if (filteredSessions.isEmpty)
//                 _buildEmptyState()
//               else
//                 ..._buildSessionList(filteredSessions),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   Widget _buildFilterChip(String label, String value, int count) {
//     final isSelected = _selectedFilter == value;
//     return FilterChip(
//       label: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(label),
//           const SizedBox(width: 4),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//             decoration: BoxDecoration(
//               color: isSelected ? Colors.white : Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(
//               count.toString(),
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//                 color: isSelected ? AppColors.primaryColor : Colors.grey.shade700,
//               ),
//             ),
//           ),
//         ],
//       ),
//       selected: isSelected,
//       onSelected: (_) => _onFilterChanged(value),
//       backgroundColor: Colors.grey.shade100,
//       selectedColor: AppColors.primaryColor,
//       labelStyle: TextStyle(
//         color: isSelected ? Colors.white : Colors.black87,
//         fontSize: 13,
//         fontWeight: FontWeight.w500,
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//         side: BorderSide(
//           color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
//           width: 1,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNoResults() {
//     return Container(
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         children: [
//           Icon(
//             Icons.search_off,
//             size: 64,
//             color: AppColors.darkgrey,
//           ),
//           const SizedBox(height: 16),
//           AppText(
//             text: 'No sessions found',
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: AppColors.blackColor,
//           ),
//           const SizedBox(height: 8),
//           AppText(
//             text: 'Try adjusting your search or filter',
//             fontSize: 14,
//             color: AppColors.darkgrey,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Container(
//       padding: const EdgeInsets.all(40),
//       child: Column(
//         children: [
//           Icon(
//             Icons.calendar_today,
//             size: 64,
//             color: AppColors.darkgrey,
//           ),
//           const SizedBox(height: 16),
//           AppText(
//             text: 'No Sessions Available',
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: AppColors.blackColor,
//           ),
//           const SizedBox(height: 8),
//           AppText(
//             text: 'Check back later for conference sessions',
//             fontSize: 14,
//             color: AppColors.darkgrey,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<Widget> _buildSessionList(List<SessionModel> sessions) {
//     List<Widget> widgets = [];
//
//     // Group sessions by date
//     Map<String, List<SessionModel>> groupedByDate = {};
//
//     for (var session in sessions) {
//       final dateKey = _getFormattedDate(session);
//       if (!groupedByDate.containsKey(dateKey)) {
//         groupedByDate[dateKey] = [];
//       }
//       groupedByDate[dateKey]!.add(session);
//     }
//
//     // Sort dates
//     final dates = groupedByDate.keys.toList();
//     dates.sort((a, b) {
//       if (a == 'Today') return -1;
//       if (b == 'Today') return 1;
//       return a.compareTo(b);
//     });
//
//     for (final date in dates) {
//       final dateSessions = groupedByDate[date]!;
//
//       widgets.addAll([
//         // Date Header
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//           decoration: BoxDecoration(
//             color: date == 'Today' ? Colors.blue.shade50 : Colors.grey.shade50,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: date == 'Today' ? Colors.blue.shade100 : Colors.grey.shade200,
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: AppText(
//                   text: date,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: date == 'Today' ? Colors.blue.shade800 : Colors.black87,
//                 ),
//               ),
//               AppText(
//                 text: "${dateSessions.length} session${dateSessions.length == 1 ? '' : 's'}",
//                 fontSize: 13,
//                 color: date == 'Today' ? Colors.blue.shade600 : AppColors.darkgrey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 12),
//
//         // Session Cards for this date
//         ...dateSessions.map((session) => _buildSessionCard(session)).toList(),
//         const SizedBox(height: 24),
//       ]);
//     }
//
//     return widgets;
//   }
//
//   // Session Card Widget
//   Widget _buildSessionCard(SessionModel session) {
//     final status = _getSessionStatus(session);
//     final tagColor = _getTagColor(session.category ?? 'Session');
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: session.isCurrentlyLive ? Colors.red.shade300 :
//           session.isPast ? Colors.grey.shade300 : Colors.grey.shade200,
//           width: session.isCurrentlyLive ? 2 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Status Badge
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: status['backgroundColor'],
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: status['color'].withOpacity(0.3)),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   status['icon'],
//                   size: 12,
//                   color: status['color'],
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   status['text'],
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: status['color'],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//
//           // Title
//           AppText(
//             text: session.sessionTitle,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 8),
//
//           // Time and Date
//           Row(
//             children: [
//               Icon(
//                 session.isToday ? Icons.access_time : Icons.calendar_today,
//                 size: 16,
//                 color: AppColors.darkgrey,
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AppText(
//                       text: session.formattedTime,
//                       fontSize: 14,
//                       color: AppColors.darkgrey,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     AppText(
//                       text: _getFormattedDate(session),
//                       fontSize: 12,
//                       color: AppColors.darkgrey.withOpacity(0.7),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: tagColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Text(
//                   session.category ?? 'Session',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w500,
//                     color: tagColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//
//           // Speakers
//           if (session.speakers.isNotEmpty)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 AppText(
//                   text: "Speakers",
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//                 const SizedBox(height: 4),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 4,
//                   children: session.speakers.map((speaker) {
//                     return Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           if (speaker.pic != null)
//                             Container(
//                               width: 20,
//                               height: 20,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 image: DecorationImage(
//                                   image: NetworkImage(speaker.pic!),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             )
//                           else
//                             Container(
//                               width: 20,
//                               height: 20,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.grey.shade300,
//                               ),
//                               child: Icon(
//                                 Icons.person,
//                                 size: 12,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           const SizedBox(width: 6),
//                           Text(
//                             speaker.fullName,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ),
//                 const SizedBox(height: 12),
//               ],
//             ),
//
//           // Location and Duration
//           Wrap(
//             spacing: 16,
//             runSpacing: 8,
//             children: [
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.location_on, size: 14, color: AppColors.darkgrey),
//                   const SizedBox(width: 4),
//                   Text(
//                     session.location ?? 'Online',
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: AppColors.darkgrey,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.timer, size: 14, color: AppColors.darkgrey),
//                   const SizedBox(width: 4),
//                   Text(
//                     session.durationInMinutes,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: AppColors.darkgrey,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           // View Details Button
//           SizedBox(
//             width: double.infinity,
//             child: CustomButton(
//               text: "View Details",
//               onPressed: () => _navigateToSessionDetails(session.sessionId),
//               height: 44,
//               backgroundColor: session.isPast ? Colors.grey : AppColors.primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }
// }