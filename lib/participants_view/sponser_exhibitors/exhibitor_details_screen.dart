import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';

import '../../images/images.dart';

class ExhibitorDetailScreen extends StatelessWidget {
  const ExhibitorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: AppColors.lightGreyColor,
      body: CustomScrollView(
        slivers: [
          // Header with building image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.whiteColor,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const AppText(
                  text: 'Exhibitors Details',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.blackColor.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: MediaQuery.of(context).size.width / 2 - 30,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.lightred2,
                      child: AppText(
                        text: 'CloudTech',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.whiteColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Company Name and Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: 'CloudTech Solutions',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 12),
                        AppText(
                          text: 'CloudTech Solutions is a leading provider of enterprise software solutions and digital transformation services, helping Fortune 500 companies worldwide streamline operations, enhance productivity, and embrace innovation. With decades of experience across multiple industries, TechWorld specializes in creating transformative solutions that not only drive growth, but also improve customer experiences, and enable organizations to stay competitive in an ever-evolving digital landscape. Committed to excellence, TechWorld combines cutting-edge tools, expert consulting, and best-in-class support to deliver measurable business outcomes and empower companies to achieve their strategic goals.',
                          fontSize: 13,
                          color: AppColors.darkgrey,
                        ),
                        const SizedBox(height: 24),

                        // Contact Information Section
                        AppText(
                          text: 'Contact Information',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 16),
                        _buildContactItem(
                          icon: Icons.language,
                          title: 'Website',
                          subtitle: 'www.techcorp.com',
                          iconColor: AppColors.darkBlue,
                        ),
                        const SizedBox(height: 12),
                        _buildContactItem(
                          icon: Icons.email,
                          title: 'Email',
                          subtitle: 'contact@techcorp.com',
                          iconColor: AppColors.darkBlue,
                        ),
                        const SizedBox(height: 12),
                        _buildContactItem(
                          icon: Icons.phone,
                          title: 'Phone',
                          subtitle: '+1 (555) 123-4567',
                          iconColor: AppColors.darkPurpleColor,
                        ),
                        const SizedBox(height: 24),

                        // Team Section
                        AppText(
                          text: 'Team',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 16),
                        _buildTeamMember(
                          name: 'Ahmed Al-Rashid',
                          position: 'Tech Solutions Rep.',
                        ),
                        const SizedBox(height: 12),
                        _buildTeamMember(
                          name: 'Sarah Mitchell',
                          position: 'Innovation Labs',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    color: AppColors.lightGreyColor,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: 'Products & Services',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 16),
                        _buildServiceItem(
                          icon: Icons.cloud,
                          title: 'Cloud Infrastructure',
                          description: 'Scalable cloud computing solutions for enterprise applications',
                          iconColor: AppColors.lightBlue,
                        ),
                        const SizedBox(height: 12),
                        _buildServiceItem(
                          icon: Icons.analytics,
                          title: 'Data Analytics',
                          description: 'Business intelligence and data visualization platforms',
                          iconColor: AppColors.lightBlue,
                        ),
                        const SizedBox(height: 12),
                        _buildServiceItem(
                          icon: Icons.security,
                          title: 'Security Solutions',
                          description: 'Enterprise-grade security and compliance tools',
                          iconColor: AppColors.darkPurpleColor,
                        ),
                        const SizedBox(height: 24),

                        // Booth Information
                        AppText(
                          text: 'Booth Information',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 16),
                        _buildBoothInfo('Booth Number', '45'),
                        _buildBoothInfo('Hall Location', 'Hall A'),
                        _buildBoothInfo('Size', '24m'),
                        _buildBoothInfo('Opening Schedule', 'Wed-Sat'),
                        _buildBoothInfo('Open', '9:00-6:00 PM'),
                        const SizedBox(height: 20),

                        // Booth Layout Image
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.containerGreyColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: AppText(
                              text: 'Booth Layout',
                              fontSize: 14,
                              color: AppColors.darkgrey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Map
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: AppText(
                                  text: 'Map View',
                                  fontSize: 14,
                                  color: AppColors.darkgrey,
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: AppText(
                                    text: '+25 min',
                                    fontSize: 10,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Get Directions Button
                        CustomButton(
                          text: 'Get Directions',
                          onPressed: () {},
                          backgroundColor: AppColors.primaryColor,
                          height: 48,
                        ),
                        const SizedBox(height: 24),

                        // Sessions Section
                        AppText(
                          text: 'Sessions Hosting by Exhibitor',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 16),
                        _buildSessionCard(
                          title: 'Digital Transformation in MENA',
                          speaker: 'Dr. Sarah Hassan',
                          time: '2:00 PM - 3:00 PM',
                          duration: '90 minutes',
                          room: 'Hall B',
                          sessionType: 'Keynote',
                          sessionTypeColor: AppColors.lightBlue,
                        ),
                        const SizedBox(height: 12),
                        _buildSessionCard(
                          title: 'The Future of Regional Cooperation',
                          speaker: 'Prof. Omar Khalid',
                          time: '10:00 AM - 11:30 AM',
                          duration: '90 minutes',
                          room: 'Hall B',
                          sessionType: 'Panel',
                          sessionTypeColor: AppColors.lightred2,
                        ),
                        const SizedBox(height: 24),

                        // Follow Us Section
                        AppText(
                          text: 'Follow Us',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'LinkedIn',
                          onPressed: () {},
                          imagePath: Images.linkedin2,
                          backgroundColor: AppColors.lightBlue,
                          height: 44,
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          text: 'Twitter',
                          onPressed: () {},
                          imagePath: Images.twitterIcon,
                          backgroundColor: AppColors.lightBlue,
                          height: 44,
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          text: 'YouTube',
                          onPressed: () {},
                          imagePath: Images.youtube,
                          backgroundColor: AppColors.primaryColor,
                          height: 44,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: title,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.blackColor,
            ),
            AppText(
              text: subtitle,
              fontSize: 12,
              color: AppColors.darkgrey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamMember({required String name, required String position}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryColor,
            child: AppText(
              text: name.split(' ').map((e) => e[0]).join(''),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.whiteColor,
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
                  color: AppColors.blackColor,
                ),
                AppText(
                  text: position,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: AppText(
              text: 'Connect',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor,
                ),
                AppText(
                  text: description,
                  fontSize: 12,
                  color: AppColors  .darkgrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoothInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: label,
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          AppText(
            text: value,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard({
    required String title,
    required String speaker,
    required String time,
    required String duration,
    required String room,
    required String sessionType,
    required Color sessionTypeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mediumGreyColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
              Icon(
                Icons.bookmark_border,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryColor,
                child: AppText(
                  text: speaker.split(' ').map((e) => e[0]).join(''),
                  fontSize: 10,
                  color: AppColors.whiteColor,
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                text: speaker,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: sessionTypeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  text: sessionType,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: sessionTypeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Exploring the role of diplomacy and collaboration in shaping future policies',
            fontSize: 12,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.darkgrey),
              AppText(
                text: time,
                fontSize: 10,
                color: AppColors.darkgrey,
              ),
              AppText(
                text: 'Duration',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              AppText(
                text: duration,
                fontSize: 10,
                color: AppColors.darkgrey,
              ),
              AppText(
                text: 'Room',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              AppText(
                text: room,
                fontSize: 10,
                color: AppColors.darkgrey,
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'View Details',
            onPressed: () {},
            backgroundColor: AppColors.primaryColor,
            height: 40,
          ),
        ],
      ),
    );
  }
}