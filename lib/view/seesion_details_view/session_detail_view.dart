import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/view/seesion_details_view/session_detail.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/images/images.dart';
import '../../../app_colors/session_card.dart';

class SessionDetailsScreen extends StatefulWidget {
  const SessionDetailsScreen({super.key});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomAppDrawer(),
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppText(
          text: 'Session Details',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGreyColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Workshop badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.lightPurpleColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const AppText(
                        text: 'Workshop',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkPurpleColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title and bookmark
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText(
                                text: 'The Future of Regional Cooperation',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: AppColors.primaryColor, size: 16),
                                  const AppText(
                                    text: 'Hall A',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.blackColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.access_time_filled, color: AppColors.primaryColor, size: 16),
                                  const AppText(
                                    text: '99 minutes',
                                    fontSize: 12,
                                    color: AppColors.blackColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.group, color: AppColors.primaryColor, size: 16),
                                  const AppText(
                                    text: '50 capacity',
                                    fontSize: 12,
                                    color: AppColors.blackColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const AppText(
                      text:
                      'Explore the evolving landscape of regional cooperation in the Middle East and North Africa. This keynote will examine emerging partnerships, economic integration opportunities, and the role of technology in fostering collaboration across borders.',
                    ),
                    const SizedBox(height: 20),
                    // Uncomment if needed, with similar layout fixes
                    /*
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.red[600], size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: 'Session Focus',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700]!,
                                ),
                                const SizedBox(height: 4),
                                AppText(
                                  text: 'Advanced discussions, skills enhancement, and expert insights',
                                  fontSize: 12,
                                  color: Colors.red[600]!,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    */
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const SizedBox(height: 16),
                    IntrinsicHeight(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightred,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightGreyColor),
                          image: DecorationImage(image: AssetImage(Images.session))
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side icon
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                color: AppColors.lightred2,
                                image: DecorationImage(image: AssetImage(Images.session))
                              ),
                           // Optional tint
                              
                            ),
                            const SizedBox(width: 16),
                            // Right side text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: "Session Form",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryColor,
                                  ),
                                  AppText(
                                    text:
                                    "Join the discussion with other attendees, ask questions, and share insights about this session.",
                                    fontSize: 13,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const SizedBox(height: 16),
                    IntrinsicHeight(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightGreyColor),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const AppText(
                                        text: 'Speakers',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      Container(
                                        height: 30,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: AppColors.lightBlue,
                                        ),
                                        child: const Center(
                                          child: AppText(
                                            text: "Key Note speaker",
                                            color: AppColors.darkBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[300],
                                   backgroundImage: AssetImage(Images.drjohnthan),
                                  ),
                                  const AppText(
                                    text: 'Dr. Richardson',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  const SizedBox(height: 4),
                                  const AppText(
                                    text: 'Director of Regional Affairs',
                                    fontSize: 12,
                                    color: AppColors.blackColor,
                                  ),
                                  const AppText(
                                    text: 'Public Co-Speakers',
                                    fontSize: 12,
                                    color: AppColors.blackColor,
                                  ),
                                  const SizedBox(height: 8),
                                  const AppText(
                                    text:
                                    'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
                                    fontSize: 12,
                                    color: AppColors.blackColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const CustomSessionDetail(),
              const SizedBox(height: 24),
              // Related Sessions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    text: 'Related Sessions',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
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
              const SizedBox(height: 16),
              // Related session cards using SessionCard
              SessionCard(
                title: 'Digital Transformation in MENA',
                speaker: 'Dr. Sarah Johnson',
                speakerRole: 'Tech Lead',
                description: 'Exploring digital advancements in the MENA region.',
                time: '2:00 PM - 3:30 PM',
                duration: '90 minutes',
                room: 'Hall A',
                sessionType: 'Keynote',
                isBookmarked: false,
                onBookmarkTap: () {},
                onViewDetails: () {},
              ),
              SessionCard(
                title: 'The Future of Regional Cooperation',
                speaker: 'Prof. Omar Al-Rawi',
                speakerRole: 'Policy Expert',
                description: 'Discussing strategies for regional collaboration.',
                time: '11:00 AM - 12:30 PM',
                duration: '90 minutes',
                room: 'Main Hall',
                sessionType: 'Workshop',
                isBookmarked: false,
                onBookmarkTap: () {},
                onViewDetails: () {},
              ),
              SessionCard(
                title: 'Digital Transformation in MENA',
                speaker: 'Dr. Sarah Johnson',
                speakerRole: 'Tech Lead',
                description: 'Exploring digital advancements in the MENA region.',
                time: '2:00 PM - 3:30 PM',
                duration: '90 minutes',
                room: 'Hall A',
                sessionType: 'Keynote',
                isBookmarked: false,
                onBookmarkTap: () {},
                onViewDetails: () {},
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}