import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/organizer_view/manage_faqs/manage_faqs_view.dart';
import 'package:al_sharq_conference/organizer_view/manager_sponser/manage_sponser.dart';
import 'package:al_sharq_conference/organizer_view/organizer_venue_map/organizer_venue_map.dart';
import 'package:al_sharq_conference/organizer_view/report_view/report_view.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../images/images.dart';
import '../manage_announcement/manage_announcement.dart';
import '../manage_session/manage_session_view.dart';
import '../manage_speaker/manage_speaker_view.dart';
import '../qrcode_scanner/qrcode_scanner.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        actions: [
          Row(
            children: [
              Image(
                image: AssetImage(Images.alsharqLogo),
                height: 30,
                width: 150,
              ),
              const SizedBox(width: 30),
              Stack(
                children: [
                  Container(
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
                    left: 26,
                    child: Icon(
                      Icons.circle,
                      size: 14,
                      color: AppColors.secondaryIndicoColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.brown,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                Expanded(child: _buildStatCard('Total Registrations', '1,250', Icons.person, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Checked In', '830', Icons.check_circle, Colors.green)),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildStatCard('Sessions', '24', Icons.event, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Speakers', '5', Icons.mic, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Sponsors', '12', Icons.business, Colors.orange)),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildStatCard('Active Sessions', '5', Icons.play_circle, Colors.red)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Live Speakers', '205', Icons.record_voice_over, Colors.orange)),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildStatCard('Total Sponsors', '455', Icons.star, Colors.yellow)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Total Participants', '1,850', Icons.group, Colors.orange)),
              ],
            ),

            const SizedBox(height: 20),

            // Today's Schedule
            _buildSectionHeader("Today's Schedule", 'View All'),
            const SizedBox(height: 12),
            _buildScheduleCard(
              'Opening Keynote',
              'Future of Digital MENA',
              '9:00 AM',
              Colors.red,
            ),

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
                    Get.to(ManageSponsorsScreen());
                  },
                    child: _buildQuickAccessCard('Manage Participants', Icons.people, Colors.blue))),
                const SizedBox(width: 12),
                Expanded(child: InkWell(
                  onTap: (){
                    Get.to(OrganizerManageSessionsScreen());
                  },
                    child: _buildQuickAccessCard('Manage Sessions', Icons.event_note, Colors.blue))),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: InkWell(
                  onTap: (){
                    Get.to(OrganizerManageSpeakersScreen());
                  },
                    child: _buildQuickAccessCard('Manage Speakers', Icons.mic, Colors.yellow))),
                const SizedBox(width: 12),
                Expanded(child: InkWell(
                    onTap: (){
                      Get.to(ManageSponsorsScreen());
                    },
                    child: _buildQuickAccessCard('Sponsors', Icons.business, Colors.orange))),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: InkWell(
                    onTap: (){
                      Get.to(OrganizerVenueMapsScreen());
                    },
                    child: _buildQuickAccessCard('Venue Maps', Icons.map, Colors.red))),
                const SizedBox(width: 12),
                Expanded(child: InkWell(
                    onTap: ()=>Get.to(ManageAnnouncementsScreen()),

                    child: _buildQuickAccessCard('Announcement', Icons.campaign, Colors.red))),
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
                Get.to(QRScannerScreen());
              },
                child: _buildToolCard(Icons.qr_code, 'QR Scanner', 'Manage check-ins', Colors.grey)),
            InkWell(
                onTap: (){
                  Get.to(ReportScreen());
                },
                child: _buildToolCard(Icons.report, 'Reports', 'Generate reports', Colors.teal)),
            InkWell(
              onTap: (){
                Get.to(ManageFAQsScreen());
              },
                child: _buildToolCard(Icons.help, 'Manage FAQ', 'Help & Support', Colors.orange)),

            const SizedBox(height: 20),

            // Recent Participants
            const AppText(
              text: 'Recent Participants',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 12),

            _buildParticipantCard('Ahmed Al-Rashid', 'Tech Solutions Rep.'),
            _buildParticipantCard('Sarah Mitchell', 'Innovation Labs'),

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

  Widget _buildSectionHeader(String title, String action) {
    return Row(
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

  Widget _buildParticipantCard(String name, String role) {
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
              text: name[0],
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
                  text: name,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                AppText(
                  text: role,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),
          const AppText(
            text: 'View Details',
            fontSize: 12,
            color: AppColors.primaryColor,
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