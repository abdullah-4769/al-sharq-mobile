import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

import '../add_new_session/add_new_session.dart';

class OrganizerManageSessionsScreen extends StatefulWidget {
  const OrganizerManageSessionsScreen({super.key});

  @override
  State<OrganizerManageSessionsScreen> createState() => _OrganizerManageSessionsScreenState();
}

class _OrganizerManageSessionsScreenState extends State<OrganizerManageSessionsScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<SessionData> sessions = [
    SessionData(
      title: 'Digital Transformation in MENA',
      speaker: 'Dr. Sarah Hassan',
      time: '2:00 PM - 3:00 PM',
      date: 'Feb 15, 2025',
      duration: '90 minutes',
      room: 'Hall B',
      status: 'Upcoming',
      statusColor: Colors.blue,
    ),
    SessionData(
      title: 'The Future of Regional Cooperation',
      speaker: 'Prof. Omar Khalid',
      time: '10:00 AM - 11:30 AM',
      date: 'Feb 15, 2025',
      duration: '90 minutes',
      room: 'Hall B',
      status: 'Panel',
      statusColor: Colors.orange,
    ),
    SessionData(
      title: 'Digital Transformation in MENA',
      speaker: 'Dr. Sarah Hassan',
      time: '2:00 PM - 3:00 PM',
      date: 'Feb 15, 2025',
      duration: '90 minutes',
      room: 'Hall B',
      status: 'Keynote',
      statusColor: Colors.blue,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText(
          text: 'Manage Sessions',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: 'Search',
                    controller: searchController,
                    suffixIcon: Icons.search,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.tune, color: AppColors.primaryColor),
              ],
            ),
          ),

          // Stats Bar
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildStatChip('All', '24', Colors.blue, true),
                const SizedBox(width: 12),
                _buildStatChip('Upcoming', '5', Colors.green, false),
                const SizedBox(width: 12),
                _buildStatChip('Completed', '12', Colors.orange, false),
              ],
            ),
          ),

          // Add New Session Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Create New Session',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddNewSessionScreen()),
                );
              },
              backgroundColor: AppColors.primaryColor,
              height: 48,
            ),
          ),

          // Date Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const AppText(
              text: 'Monday, Feb 15, 2025',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkgrey,
            ),
          ),

          // View All Link
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const AppText(
                    text: 'View All',
                    fontSize: 14,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Sessions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _buildSessionCard(session);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String count, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : AppColors.mediumGreyColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? color : AppColors.darkgrey,
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              text: count,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(SessionData session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  text: session.title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Icon(Icons.bookmark_border, color: AppColors.primaryColor, size: 20),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryColor,
                child: AppText(
                  text: session.speaker.split(' ').map((e) => e[0]).join(''),
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                text: session.speaker,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: session.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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

          const AppText(
            text: 'Exploring the role of diplomacy and collaboration in shaping future policies',
            fontSize: 12,
            color: AppColors.darkgrey,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.access_time, size: 12, color: AppColors.darkgrey),
                  AppText(text: session.time, fontSize: 10, color: AppColors.darkgrey),
                ],
              ),
              const AppText(text: 'Duration', fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black),
              AppText(text: session.duration, fontSize: 10, color: AppColors.darkgrey),
              const AppText(text: 'Room', fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black),
              AppText(text: session.room, fontSize: 10, color: AppColors.darkgrey),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const AppText(
                    text: 'Edit',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.darkgrey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const AppText(
                    text: 'Delete',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkgrey,
                  ),
                ),
              ),
            ],
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

class SessionData {
  final String title;
  final String speaker;
  final String time;
  final String date;
  final String duration;
  final String room;
  final String status;
  final Color statusColor;

  SessionData({
    required this.title,
    required this.speaker,
    required this.time,
    required this.date,
    required this.duration,
    required this.room,
    required this.status,
    required this.statusColor,
  });
}
