// Session Card Widget
// Main My Agenda Screen
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/app_colors/session_card.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart'
    hide AppColors;
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/form_label.dart';
import 'package:flutter/material.dart';

class MyAgendaScreen extends StatefulWidget {
  const MyAgendaScreen({super.key});

  @override
  State<MyAgendaScreen> createState() => _MyAgendaScreenState();
}

class _MyAgendaScreenState extends State<MyAgendaScreen> {
  TextEditingController _searchController = TextEditingController();
  final List<SessionData> sessions = [
    SessionData(
      title: 'Digital Transformation in MENA',
      speaker: 'Dr. Sarah Hassan',
      speakerRole: '2 more',
      description:
          'Exploring the role of diplomacy and collaboration in shaping future policies.',
      time: '2:00 PM - 3:30 PM',
      duration: '90 minutes',
      room: 'Hall B',
      sessionType: 'Keynote',
      isBookmarked: true,
    ),
    SessionData(
      title: 'The Future of Regional Cooperation',
      speaker: 'Prof. Omar Khalil',
      speakerRole: '',
      description:
          'Exploring the role of diplomacy and collaboration in shaping future policies.',
      time: '10:00 AM - 11:30 AM',
      duration: '90 minutes',
      room: 'Hall B',
      sessionType: 'Panel',
      isBookmarked: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        // 👇 leading hata do
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: AppColors.blackColor),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: AppText(
          text: 'My Agenda',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: CustomTextField(
                      hintText: "Search",
                      controller: _searchController,
                      suffixIcon: Icons.search,
                    ),
                  ),
                  SizedBox(width: 10),
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: 'Monday, Feb 10, 2025',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                  AppText(
                    text: 'View All',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blackColor,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Session Cards for Monday
              ...sessions.map(
                (session) => SessionCard(
                  title: session.title,
                  speaker: session.speaker,
                  speakerRole: session.speakerRole,
                  description: session.description,
                  time: session.time,
                  duration: session.duration,
                  room: session.room,
                  sessionType: session.sessionType,
                  isBookmarked: session.isBookmarked,
                  onBookmarkTap: () {
                    setState(() {
                      session.isBookmarked = !session.isBookmarked;
                    });
                  },
                  onViewDetails: () {
                    // Handle view details
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Date Header for Tuesday
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: 'Tuesday, Feb 11, 2025',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                  AppText(
                    text: 'View All',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Session Cards for Tuesday (duplicate for demo)
              ...sessions.map(
                (session) => SessionCard(
                  title: session.title,
                  speaker: session.speaker,
                  speakerRole: session.speakerRole,
                  description: session.description,
                  time: session.time,
                  duration: session.duration,
                  room: session.room,
                  sessionType: session.sessionType,
                  isBookmarked: session.isBookmarked,
                  onBookmarkTap: () {
                    setState(() {
                      session.isBookmarked = !session.isBookmarked;
                    });
                  },
                  onViewDetails: () {
                    // Handle view details
                  },
                ),
              ),

              const SizedBox(height: 32),

              Container(
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
                      text:
                          'Browse the full conference schedule to add more sessions to your agenda.',
                      fontSize: 14,
                      color: AppColors.darkgrey,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Browse All Sessions',
                      onPressed: () {
                        // Handle browse all sessions
                      },
                      backgroundColor: AppColors.primaryColor,
                      textColor: AppColors.whiteColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Session Data Model
class SessionData {
  String title;
  String speaker;
  String speakerRole;
  String description;
  String time;
  String duration;
  String room;
  String sessionType;
  bool isBookmarked;

  SessionData({
    required this.title,
    required this.speaker,
    required this.speakerRole,
    required this.description,
    required this.time,
    required this.duration,
    required this.room,
    required this.sessionType,
    required this.isBookmarked,
  });
}
