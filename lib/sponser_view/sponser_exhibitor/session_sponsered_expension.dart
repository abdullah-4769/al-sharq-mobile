import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../images/images.dart';
import '../exhibitor_details_view/exhibitor_details+view.dart';

class SessionsSponsoredExtensionScreen extends StatelessWidget {
  const SessionsSponsoredExtensionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightBackground,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sessions Sponsored Section
          const AppText(
            text: 'Sessions Sponsored',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          const SizedBox(height: 16),

          // Session Card 1 - Digital Transformation
          _buildSessionCard(
            title: 'Digital Transformation in MENA',
            speaker: 'Dr. Sarah Hassan',
            speakerRole: '2 more',
            time: '2:00 PM - 3:00 PM',
            duration: '90 minutes',
            room: 'Hall B',
            sessionType: 'Keynote',
            sessionTypeColor: Colors.blue,
            description: 'Exploring the role of diplomacy and collaboration in shaping future policies',
          ),

          const SizedBox(height: 16),

          // Session Card 2 - Regional Cooperation
          _buildSessionCard(
            title: 'The Future of Regional Cooperation',
            speaker: 'Prof. Omar Khalil',
            speakerRole: '',
            time: '10:00 AM - 11:30 AM',
            duration: '90 minutes',
            room: 'Hall B',
            sessionType: 'Panel',
            sessionTypeColor: Colors.orange,
            description: 'Exploring the role of diplomacy and collaboration in shaping future policies',
          ),

          const SizedBox(height: 32),

          // Follow Us Section
          const AppText(
            text: 'Follow Us',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          const SizedBox(height: 16),

          // Social Media Buttons
          CustomButton(
            imagePath: Images.linkedin2,

            text: 'LinkedIn',
            onPressed: () {},
            backgroundColor: AppColors.darkBlue,
            height: 48,
          ),
          const SizedBox(height: 12),
          CustomButton(
            imagePath: Images.twitterIcon,

            text: 'Twitter',
            onPressed: () {},
            backgroundColor: AppColors.lightBlue,
            height: 48,
          ),
          const SizedBox(height: 12),
          CustomButton(
            imagePath: Images.youtube,
            text: 'YouTube',
            onPressed: () {},
            backgroundColor: AppColors.primaryColor,
            height: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard({
    required String title,
    required String speaker,
    required String speakerRole,
    required String time,
    required String duration,
    required String room,
    required String sessionType,
    required Color sessionTypeColor,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mediumGreyColor, width: 0.5),
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
          // Title and Bookmark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Icon(
                Icons.bookmark_border,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Speaker Info
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryColor,
                child: AppText(
                  text: speaker.split(' ').map((e) => e[0]).join(''),
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                text: speaker,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
              if (speakerRole.isNotEmpty) ...[
                const SizedBox(width: 4),
                AppText(
                  text: speakerRole,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
              ],
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

          // Description
          AppText(
            text: description,
            fontSize: 12,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 12),

          // Session Details Row
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.darkgrey),
              const SizedBox(width: 4),
              AppText(
                text: time,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const AppText(
                text: 'Duration',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              const SizedBox(width: 8),
              AppText(
                text: duration,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
              const Spacer(),
              const AppText(
                text: 'Room',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              const SizedBox(width: 8),
              AppText(
                text: room,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
            ],
          ),
          const SizedBox(height: 16),

          CustomButton(
            text: 'View Details',
            onPressed: () {
              Get.to(SponserVenueDetails());
            },
            backgroundColor: AppColors.primaryColor,
            height: 40,
          ),
        ],
      ),
    );
  }
}

// This can be used as part of the Sponsor Detail Screen by adding it after the Products & Services section:

class SponsorDetailScreenWithSessions extends StatelessWidget {
  const SponsorDetailScreenWithSessions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header with building image and sponsor logo
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.whiteColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    const AppText(
                      text: 'Gold Sponsors',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Building background image
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
                  // Gradient overlay
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  // Company logo
                  Positioned(
                    bottom: 30,
                    left: MediaQuery.of(context).size.width / 2 - 40,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: const AppText(
                        text: 'TechCorp',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content including all sections and the new Sessions Sponsored section
          const SliverToBoxAdapter(
            child: SessionsSponsoredExtensionScreen(),
          ),
        ],
      ),
    );
  }
}