import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../participants_view/sponser_exhibitors/exhibitor_details_screen.dart';
import '../live_session_speaker/live_session_speaker.dart';


class SpeakerSponsorsExhibitorsScreen extends StatefulWidget {
  const SpeakerSponsorsExhibitorsScreen({super.key});

  @override
  State<SpeakerSponsorsExhibitorsScreen> createState() => _SpeakerSponsorsExhibitorsScreenState();
}

class _SpeakerSponsorsExhibitorsScreenState extends State<SpeakerSponsorsExhibitorsScreen> {
  int selectedTab = 0; // 0: All, 1: Gold Sponsors, 2: Silver Sponsors
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,

        title: const AppText(
          text: 'Sponsors & Exhibitors',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:  Row(
              children: [
                Expanded(
                  flex: 6,
                  child: CustomTextField(
                    hintText: "Search",
                    controller: searchController,
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
          ),

          // Tab Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildTabButton('All', 0),
                const SizedBox(width: 12),
                _buildTabButton('Gold Sponsors', 1),
                const SizedBox(width: 12),
                _buildTabButton('Silver Sponsors', 2),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                // Gold Sponsors Section
                _buildSectionHeader('Gold Sponsors', Icons.star, Colors.orange),
                const SizedBox(height: 16),
                _buildSponsorCard(
                  companyName: 'TechCore Solutions',
                  description: 'Leading provider of enterprise software solutions and digital transformation services',
                  color: Colors.blue,
                  logoText: 'TC',
                ),
                const SizedBox(height: 12),
                _buildSponsorCard(
                  companyName: 'InnovateLab Inc.',
                  description: 'Pioneering AI and machine learning technologies for business and transforming industries',
                  color: Colors.green,
                  logoText: 'IL',
                ),

                const SizedBox(height: 32),

                // Silver Sponsors Section
                _buildSectionHeader('Silver Sponsors', Icons.star_border, Colors.grey),
                const SizedBox(height: 16),
                _buildSponsorCard(
                  companyName: 'DataFlow Systems',
                  description: 'Comprehensive data analytics software solutions and digital transformation services',
                  color: Colors.purple,
                  logoText: 'DF',
                ),
                const SizedBox(height: 12),
                _buildSponsorCard(
                  companyName: 'SecureNet Technologies',
                  description: 'Pioneering AI and machine learning technologies for business transforming industries worldwide',
                  color: AppColors.primaryColor,
                  logoText: 'SN',
                ),

                const SizedBox(height: 32),

                // Exhibitors Section
                _buildSectionHeader('Exhibitors', Icons.business, Colors.blue),
                const SizedBox(height: 16),
                _buildExhibitorCard(
                  companyName: 'CloudTech Solutions',
                  hallNumber: 'Hall B',
                  description: 'Leading provider of enterprise software solutions and digital transformation services',
                  color: Colors.orange,
                  logoText: 'CT',
                ),
                const SizedBox(height: 12),
                _buildExhibitorCard(
                  companyName: 'CloudTech Solutions',
                  hallNumber: 'Hall B',
                  description: 'Leading provider of enterprise software solutions and digital transformation services',
                  color: Colors.teal,
                  logoText: 'CT',
                ),
                const SizedBox(height: 12),
                _buildExhibitorCard(
                  companyName: 'CloudTech Solutions',
                  hallNumber: 'Hall B',
                  description: 'Leading provider of enterprise software solutions and digital transformation services',
                  color: Colors.indigo,
                  logoText: 'CT',
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: AppText(
          text: text,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey[700]!,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        AppText(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ],
    );
  }

  Widget _buildSponsorCard({
    required String companyName,
    required String description,
    required Color color,
    required String logoText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color,
                child: AppText(
                  text: logoText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  text: companyName,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            text: description,
            fontSize: 13,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Learn More',
            onPressed: () {
              Get.to(SpeakerLiveSessionScreen());
            },
            backgroundColor: AppColors.primaryColor,
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildExhibitorCard({
    required String companyName,
    required String hallNumber,
    required String description,
    required Color color,
    required String logoText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color,
                child: AppText(
                  text: logoText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: companyName,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        AppText(
                          text: hallNumber,
                          fontSize: 12,
                          color: AppColors.darkgrey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            text: description,
            fontSize: 13,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Learn More',
            onPressed: () {},
            backgroundColor: AppColors.primaryColor,
            height: 40,
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