import 'package:al_sharq_conference/participants_view/forum_chat/chat_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../data/response_models/speaker_response_models/speaker_sessions_detail_show_model.dart';
import '../../images/images.dart';
import '../../participants_view/seesion_details_view/session_detail_view.dart';
import '../../view_model/login_view_model.dart';
import '../../view_model/speaker_viewmodels/speaker_dashboard_show_viewmodel.dart';
import '../../view_model/speaker_viewmodels/speaker_sessions_detail_show_viewmodel.dart'; // Add this import
import '../speaker_dashboard_view/speaker_dashboard_show_view.dart';
import '../sponser_exhibitor/sponser_exhibitor_speaker.dart';
import '../../utils/shared_preference.dart';
import '../../participants_view/seesion_details_view/session_detail.dart'; // Add this import

// Main Conference Dashboard Screen
class SpeakerConferenceDashboardScreen extends StatefulWidget {
  const SpeakerConferenceDashboardScreen({super.key});

  @override
  _SpeakerConferenceDashboardScreenState createState() =>
      _SpeakerConferenceDashboardScreenState();
}

class _SpeakerConferenceDashboardScreenState extends State<SpeakerConferenceDashboardScreen> {
  TextEditingController _searchController = TextEditingController();
  final SpeakerDashboardShowViewModel _speakerViewModel = Get.put(SpeakerDashboardShowViewModel());
  final SpeakerSessionsDetailShowViewModel _sessionsViewModel = Get.put(SpeakerSessionsDetailShowViewModel()); // Add this
  final LoginViewModel _loginViewModel = Get.find<LoginViewModel>();

  int? _speakerId;
  String? _userName;
  String? _userImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final isLoggedIn = await SharedPrefsHelper.isUserLoggedIn();
    if (isLoggedIn) {
      // Get user data from shared preferences first
      _userName = await SharedPrefsHelper.getUserName();
      _userImage = await SharedPrefsHelper.getUserImage();

      // Update UI immediately with cached data
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Try to get speaker ID from shared preferences first
      _speakerId = await SharedPrefsHelper.getSpeakerId();

      // If speaker ID is not found in shared preferences, fetch from API
      if (_speakerId == null) {
        final userId = await SharedPrefsHelper.getUserId();
        if (userId != null) {
          await _speakerViewModel.fetchSpeakerProfileByUserId(userId);
          if (_speakerViewModel.speakerProfile != null) {
            _speakerId = _speakerViewModel.speakerProfile!.id;
            // Save speaker ID to shared preferences for future use
            await SharedPrefsHelper.saveSpeakerId(_speakerId!);

            // Also save user image if available from speaker profile
            if (_speakerViewModel.speakerProfile!.user.file != null &&
                _speakerViewModel.speakerProfile!.user.file!.isNotEmpty) {
              await SharedPrefsHelper.setUserImage(_speakerViewModel.speakerProfile!.user.file!);
              if (mounted) {
                setState(() {
                  _userImage = _speakerViewModel.speakerProfile!.user.file;
                });
              }
            }

            // Fetch speaker sessions after getting speaker ID
            if (_speakerId != null) {
              await _sessionsViewModel.fetchSpeakerSessions(_speakerId!);
            }
          }
        }
      } else {
        // If speaker ID exists, fetch the profile
        await _speakerViewModel.fetchSpeakerProfile(_speakerId!);

        // Update user image from speaker profile if available
        if (_speakerViewModel.speakerProfile != null &&
            _speakerViewModel.speakerProfile!.user.file != null &&
            _speakerViewModel.speakerProfile!.user.file!.isNotEmpty) {
          await SharedPrefsHelper.setUserImage(_speakerViewModel.speakerProfile!.user.file!);
          if (mounted) {
            setState(() {
              _userImage = _speakerViewModel.speakerProfile!.user.file;
            });
          }
        }

        // Fetch speaker sessions
        await _sessionsViewModel.fetchSpeakerSessions(_speakerId!);
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      Get.snackbar(
        'Authentication Error',
        'Please login again',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Method to navigate to session details
  void _navigateToSessionDetails(int sessionId) {
    print('=== Navigating to session details for ID: $sessionId ===');
    Get.to(() => SessionDetailsScreen(
      sessionId: sessionId,
      key: ValueKey('session_$sessionId'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: _buildSearchBar(),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: _buildStatsCards(),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: _buildSessionsList(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.whiteColor,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(Images.alsharqLogo)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
      actions: [
        CircleAvatar(
          backgroundColor: AppColors.lightred,
          radius: 22,
          child: IconButton(
            onPressed: () {
              Get.to(ChatListScreen());
            },
            icon: Icon(Icons.chat, color: AppColors.blackColor),
          ),
        ),
        SizedBox(width: 10),
        CircleAvatar(
          backgroundColor: AppColors.lightred,
          radius: 22,
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: AppColors.blackColor),
          ),
        ),
        SizedBox(width: 10),
        // User Avatar with speaker image
        GestureDetector(
          onTap: () {
            Get.to(SpeakerDashboardScreen());
          },
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.mediumGreyColor,
            backgroundImage: _userImage != null && _userImage!.isNotEmpty
                ? NetworkImage(_userImage!)
                : null,
            child: _userImage == null || _userImage!.isEmpty
                ? Image(image: AssetImage(Images.drjohnthan))
                : null,
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.whiteColor,
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: AppColors.darkgrey),
          prefixIcon: Icon(Icons.search, color: AppColors.darkgrey),
          suffixIcon: Icon(Icons.tune, color: AppColors.primaryColor),
          filled: true,
          fillColor: AppColors.lightGreyColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: _buildStatCard('Total Hosted', _sessionsViewModel.totalSessions.toString(), Icons.event)),
            SizedBox(width: 12),
            Expanded(child: _buildStatCard('Ongoing Sessions', _sessionsViewModel.ongoingSessions.toString(), Icons.play_circle_filled, color: AppColors.successColor)),
            SizedBox(width: 12),
            Expanded(child: _buildStatCard('Scheduled Sessions', _sessionsViewModel.scheduledSessions.toString(), Icons.schedule, color: AppColors.warningColor)),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(String title, String count, IconData icon, {Color? color}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (color ?? AppColors.lightBlue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color ?? AppColors.lightBlue,
              size: 20,
            ),
          ),
          SizedBox(height: 12),
          AppText(
            text: count,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          SizedBox(height: 4),
          AppText(
            text: title,
            fontSize: 12,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    return Obx(() {
      if (_sessionsViewModel.isLoading) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        );
      }

      if (_sessionsViewModel.error.isNotEmpty) {
        return Center(
          child: Column(
            children: [
              AppText(
                text: _sessionsViewModel.error,
                color: Colors.red,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_speakerId != null) {
                    _sessionsViewModel.fetchSpeakerSessions(_speakerId!);
                  }
                },
                child: AppText(text: 'Retry'),
              ),
            ],
          ),
        );
      }

      final sessions = _sessionsViewModel.sessions;

      if (sessions.isEmpty) {
        return Center(
          child: AppText(
            text: 'Fetching Sessions...',
            color: Colors.grey,
          ),
        );
      }

      // Group sessions by date
      final Map<String, List<SpeakerSessionModel>> groupedSessions = {};

      for (final session in sessions) {
        try {
          final date = DateTime.parse(session.startTime);
          final dateKey = '${_getWeekday(date)}, ${_getMonth(date)} ${date.day}, ${date.year}';

          if (!groupedSessions.containsKey(dateKey)) {
            groupedSessions[dateKey] = [];
          }
          groupedSessions[dateKey]!.add(session);
        } catch (e) {
          // Skip sessions with invalid dates
        }
      }

      return Column(
        children: groupedSessions.entries.map((entry) {
          return Column(
            children: [
              _buildDateHeader(entry.key),
              ...entry.value.map((session) => _buildSessionCard(session)),
            ],
          );
        }).toList(),
      );
    });
  }

  String _getWeekday(DateTime date) {
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];
  }

  String _getMonth(DateTime date) {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
  }

  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: date,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          AppText(
            text: 'View All',
            fontSize: 14,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SpeakerSessionModel session) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
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
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          SizedBox(height: 8),

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
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: session.speakers.first.name,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackColor,
                    ),
                    AppText(
                      text: session.status,
                      fontSize: 12,
                      color: session.statusColor,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
          ],

          // Description
          AppText(
            text: session.description,
            fontSize: 13,
            color: AppColors.darkgrey,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),

          // Time and type info
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.darkgrey),
              SizedBox(width: 4),
              AppText(
                text: session.formattedTime,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  text: session.category,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Duration and room
          Row(
            children: [
              AppText(
                text: 'Duration',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              Spacer(),
              AppText(
                text: session.duration,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              AppText(
                text: 'Room',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              Spacer(),
              AppText(
                text: session.displayLocation,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
            ],
          ),
          SizedBox(height: 16),

          // Action button
          CustomButton(
            text: session.status == 'Completed' ? 'View Details' :
            session.status == 'Ongoing' ? 'Join Session' : 'View Details',
            onPressed: () {
              _navigateToSessionDetails(session.id);
            },
            backgroundColor: AppColors.primaryColor,
            height: 40,
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

  // Add this method to handle role switching
  void _showSwitchRoleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: AppText(
            text: 'Switch Role',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          content: AppText(
            text: 'Do you want to switch to Participant view? You can switch back anytime.',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: AppText(
                text: 'Cancel',
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _loginViewModel.switchRole('participant');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: AppText(
                text: 'Switch',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}