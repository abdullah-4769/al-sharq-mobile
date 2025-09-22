import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/view/home_page/quick_access_item.dart';
import 'package:al_sharq_conference/view/networking_view/networking_view.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../images/images.dart';
import '../conference_schedule_view/conference_schedule_view.dart';
import '../forum_chat/forum_chat.dart';
import '../live_chat_session_view/live_chat_session_view.dart';
import '../my_agenda_view/my_agenda_view.dart';
import '../seesion_details_view/session_detail_view.dart';
import '../speakers_view/speaker_view.dart';
import '../sponser_exhibitors/sponser_exhibitors_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomAppDrawer(),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Latest Update Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.campaign_outlined, color: Colors.white, size: 24),
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
                              text: 'Keynote starts at 10:30 AM – Hall A',
                              color: AppColors.whiteColor,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: AppColors.whiteColor, size: 22),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Today's Schedule Section
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SessionDetailsScreen()));
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

                // Schedule Item
                Container(
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
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LiveSessionScreen()));
                        },
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
                          children: const [
                            Text(
                              'Opening Keynote',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '10:30 AM - 11:30 AM • Hall A',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: AppColors.primaryColor, size: 22),
                    ],
                  ),
                ),
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
                      title: 'Sponsors',
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
                    QuickAccessItem(
                      imagePath: Images.forums,
                      title: 'Forums',
                      subtitle: 'Discussions',
                      iconBackgroundColor: Colors.teal.shade100,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForumChatScreen()));
                      },
                    ),
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
                _buildSupportItem(
                  icon: Icons.qr_code,
                  title: 'QR Code Pass',
                  subtitle: 'Entry & check-in',
                  color: Colors.grey.shade100,
                  iconColor: Colors.grey.shade700,
                ),
                const SizedBox(height: 12),
                _buildSupportItem(
                  icon: Icons.map,
                  title: 'Venue Maps',
                  subtitle: 'Navigation & locations',
                  color: Colors.red.shade50,
                  iconColor: Colors.red,
                ),
                const SizedBox(height: 12),
                _buildSupportItem(
                  icon: Icons.help,
                  title: 'FAQ & Support',
                  subtitle: 'Help & guidance',
                  color: Colors.orange.shade50,
                  iconColor: Colors.orange,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
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