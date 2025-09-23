import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/images/images.dart';
import 'package:al_sharq_conference/participants_view/conference_schedule_view/conference_schedule_view.dart';
import 'package:al_sharq_conference/participants_view/home_page/home_view.dart';
import 'package:al_sharq_conference/participants_view/my_agenda_view/my_agenda_view.dart';
import 'package:al_sharq_conference/participants_view/qr_code_scanner/qr_code_scanner_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart'; // Correct import for SVG

class CustomAppDrawer extends StatelessWidget {
  const CustomAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Enhanced Header
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                 AppColors.primaryColor,
                 AppColors.primaryColor,

                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    AppText(
                      text: 'Adnan Qasim',

                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      text: 'adnan@gmail.com',

                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Enhanced Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildEnhancedListTile(
                  icon: Icons.home_outlined,
                  title: "Home",
                  color: Colors.blue,
                  onTap: () => Get.to(HomeView()),
                ),
                _buildEnhancedListTile(
                  icon: Icons.schedule_outlined,
                  title: "Conference Schedule",
                  color: Colors.orange,
                  onTap: () => Get.to(ConferenceScheduleScreen()),
                ),
                _buildEnhancedListTile(
                  icon: Icons.event_note_outlined,
                  title: "My Agenda",
                  color: Colors.green,
                  onTap: () =>Get.to(MyAgendaScreen()),
                ),
                _buildEnhancedListTile(
                  icon: Icons.qr_code_scanner_outlined,
                  title: "Scan QR Code",
                  color: Colors.purple,
                  onTap: () => Get.to(QRPassScreen()),
                ),

                // Divider
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                _buildEnhancedListTile(
                  icon: Icons.settings_outlined,
                  title: "Settings",
                  color: Colors.grey,
                  onTap: () => Navigator.pop(context),
                ),
                _buildEnhancedListTile(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  color: Colors.teal,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Enhanced Footer with SVG - Fixed Implementation
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade100, Colors.grey.shade200],
              ),
            ),
            child: Stack(
              children: [
                // SVG Background - Corrected approach
                Positioned.fill(
                  child: ClipRRect(
                    child: Image(image: AssetImage(Images.alsharqLogo)),
                    // child: SvgPicture.asset(
                    //   "assets/al sharq guidelines-3 copy.svg",
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),

                // Overlay content
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedListTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: AppText(
          text: title,

          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        trailing: Icon(
          Icons.arrow_forward,
          size: 16,
          color: AppColors.primaryColor,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
        hoverColor: color.withOpacity(0.05),
        splashColor: color.withOpacity(0.1),
      ),
    );
  }
}
