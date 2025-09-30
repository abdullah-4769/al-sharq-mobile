import 'package:al_sharq_conference/participants_view/forum_chat/chat_list_view.dart';
import 'package:al_sharq_conference/sponser_view/sponser_exhibitor/sponser_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../images/images.dart';

class SponserSession {
  final String title;
  final String speaker;
  final String speakerRole;
  final String description;
  final String time;
  final String duration;
  final String room;
  final String type;
  final bool isBookmarked;
  final Color typeColor;
  final String status; // "Completed", "Ongoing", "Upcoming"

  SponserSession({
    required this.title,
    required this.speaker,
    required this.speakerRole,
    required this.description,
    required this.time,
    required this.duration,
    required this.room,
    required this.type,
    this.isBookmarked = false,
    required this.typeColor,
    required this.status,
  });
}

// Main Conference Dashboard Screen
class SponserDashboardScreen extends StatefulWidget {
  const SponserDashboardScreen({super.key});

  @override
  _SponserDashboardScreenState createState() =>
      _SponserDashboardScreenState();
}

class _SponserDashboardScreenState extends State<SponserDashboardScreen> {
  TextEditingController _searchController = TextEditingController();

  // Sample data
  final List<SponserSession> todaySessions = [
    SponserSession(
      title: 'Digital Transformation in MENA',
      speaker: 'Dr. Sarah Hassan',
      speakerRole: 'Tech Innovation Expert',
      description: 'Exploring the role of diplomacy and collaboration in shaping future policies',
      time: '2:00 PM - 3:30 PM',
      duration: '90 minutes',
      room: 'Hall B',
      type: 'Keynote',
      typeColor: AppColors.lightBlue,
      status: 'Completed',
      isBookmarked: true,
    ),
    SponserSession(
      title: 'The Future of Regional Cooperation',
      speaker: 'Prof. Omar Khalil',
      speakerRole: 'Policy Analyst',
      description: 'Exploring the role of diplomacy and collaboration in shaping future policies',
      time: '10:00 AM - 11:30 AM',
      duration: '90 minutes',
      room: 'Hall B',
      type: 'Panel',
      typeColor: AppColors.warningColor,
      status: 'In 30 minutes',
      isBookmarked: true,
    ),
  ];

  final List<SponserSession> tomorrowSessions = [
    SponserSession(
      title: 'Digital Transformation in MENA',
      speaker: 'Dr. Sarah Hassan',
      speakerRole: 'Tech Innovation Expert',
      description: 'Exploring the role of diplomacy and collaboration in shaping future policies',
      time: '2:00 PM - 3:30 PM',
      duration: '90 minutes',
      room: 'Hall B',
      type: 'Keynote',
      typeColor: AppColors.lightBlue,
      status: 'Upcoming',
      isBookmarked: false,
    ),
    SponserSession(
      title: 'The Future of Regional Cooperation',
      speaker: 'Prof. Omar Khalil',
      speakerRole: 'Policy Analyst',
      description: 'Exploring the role of diplomacy and collaboration in shaping future policies',
      time: '10:00 AM - 11:30 AM',
      duration: '90 minutes',
      room: 'Hall B',
      type: 'Panel',
      typeColor: AppColors.warningColor,
      status: 'Upcoming',
      isBookmarked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildSponsorsCard(),
            _buildStatsCards(),
            _buildSessionsList(),
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
        SizedBox(width: 10,),
        CircleAvatar(
          backgroundColor: AppColors.lightred,

          radius: 22,

          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: AppColors.blackColor),
          ),
        ),
        SizedBox(width: 10,),

        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.mediumGreyColor,
          child: Image(image: AssetImage(Images.drjohnthan)),
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

  Widget _buildSponsorsCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xffFFF9E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
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
            child: Icon(Icons.star, color: AppColors.whiteColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: AppText(
              text: 'Sponsors',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppColors.primaryColor, size: 16),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Hosted', '24', Icons.event)),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard('Ongoing', '5', Icons.play_circle_filled, color: AppColors.successColor)),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard('Scheduled', '12', Icons.schedule, color: AppColors.warningColor)),
        ],
      ),
    );
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
    return Column(
      children: [
        // Today's Sessions
        _buildDateHeader('Monday, Feb 10, 2025'),
        ...todaySessions.map((session) => _buildSessionCard(session)),

        // Tomorrow's Sessions
        _buildDateHeader('Tuesday, Feb 11, 2025'),
        ...tomorrowSessions.map((session) => _buildSessionCard(session)),
      ],
    );
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

  Widget _buildSessionCard(SponserSession session) {
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
          // Header with title and bookmark
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
              Icon(
                session.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: session.isBookmarked ? AppColors.primaryColor : AppColors.darkgrey,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 8),

          // Speaker info
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryColor,
                child: AppText(
                  text: session.speaker.split(' ').map((e) => e[0]).join(''),
                  fontSize: 10,
                  color: AppColors.whiteColor,
                ),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: session.speaker,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blackColor,
                  ),
                  AppText(
                    text: session.status,
                    fontSize: 12,
                    color: session.status == 'Completed' ? AppColors.successColor : AppColors.warningColor,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),

          // Description
          AppText(
            text: session.description,
            fontSize: 13,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 12),

          // Time and type info
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.darkgrey),
              SizedBox(width: 4),
              AppText(
                text: session.time,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: session.typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  text: session.type,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: session.typeColor == AppColors.lightBlue ? AppColors.darkBlue : Colors.orange,
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
                text: session.room,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
            ],
          ),
          SizedBox(height: 16),

          // Action button
          CustomButton(
            text: session.status == 'Completed' ? 'View Details' :
            session.status.contains('minutes') ? 'Join Session' : 'View Details',
            onPressed: () {
              Get.to(SponsorDetailScreen());
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
}