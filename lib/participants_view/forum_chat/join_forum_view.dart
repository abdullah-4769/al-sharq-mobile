import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

class JoinForumsScreen extends StatelessWidget {
  const JoinForumsScreen({super.key});

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
          text: 'Future of Regional Cooperation',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          // Workshop Banner
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const AppText(
                        text: 'Workshop',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple,
                      ),
                    ),
                    const Spacer(),
                    const AppText(
                      text: '10:00 AM - 11:30 AM',
                      fontSize: 12,
                      color: AppColors.darkgrey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const AppText(
                  text: 'Mon 17 Feb',
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
                const SizedBox(height: 12),
                const AppText(
                  text: 'The Future of Regional Cooperation',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: AppColors.primaryColor),
                        const SizedBox(width: 4),
                        const AppText(text: '245', fontSize: 14, color: Colors.black),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: AppColors.primaryColor),
                        const SizedBox(width: 4),
                        const AppText(text: 'Hall B', fontSize: 14, color: Colors.black),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(Icons.chat_bubble, size: 16, color: AppColors.primaryColor),
                        const SizedBox(width: 4),
                        const AppText(text: '120 Discussions', fontSize: 14, color: Colors.black),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const AppText(
                  text: 'Exploring the role of diplomacy and collaboration in shaping future policies. Attendees will gain insights into sustainable opportunities and the role of technology in fostering collaborative solutions.',
                  fontSize: 13,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),

          // Forum Section Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const AppText(
                    text: 'Networking',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const AppText(
                  text: 'You joined this forum: 10:35 AM',
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),

          // Forum Details
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  text: 'Future of Regional Cooperation',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                const SizedBox(height: 8),
                const AppText(
                  text: 'Discuss strategies for regional partnerships and collaborative initiatives.',
                  fontSize: 13,
                  color: AppColors.darkgrey,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: AppColors.primaryColor),
                    const SizedBox(width: 4),
                    const AppText(text: '245 Members', fontSize: 12, color: Colors.black),
                    const SizedBox(width: 16),
                    Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.primaryColor),
                    const SizedBox(width: 4),
                    const AppText(text: '120 Posts', fontSize: 12, color: Colors.black),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primaryColor,
                      child: const Icon(Icons.person, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const AppText(
                      text: 'Created by: Dr. Johnathan',
                      fontSize: 12,
                      color: AppColors.darkgrey,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Today Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.lightGreyColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: AppText(
                text: 'Today',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Messages Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Message 1
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryColor,
                        child: const AppText(text: 'DJ', fontSize: 10, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const AppText(
                                  text: 'Dr. Johnathan',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                                const Spacer(),
                                const AppText(
                                  text: '1 hour ago',
                                  fontSize: 12,
                                  color: AppColors.darkgrey,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const AppText(
                              text: 'Great question Sarah! From my experience, the biggest challenges are:',
                              fontSize: 13,
                              color: Colors.black,
                            ),
                            const SizedBox(height: 8),
                            _buildBulletPoint('Data Privacy Regulations:', 'GDPR compliance and local data protection laws'),
                            _buildBulletPoint('Talent Shortage:', 'Limited AI/ML specialists in the region'),
                            _buildBulletPoint('Infrastructure:', 'Legacy systems integration challenges'),
                            const SizedBox(height: 8),
                            const AppText(
                              text: 'We\'ve had success with gradual implementation and extensive training programs. What\'s been your experience with stakeholder buy-in?',
                              fontSize: 13,
                              color: Colors.black,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.thumb_up_outlined, size: 16, color: AppColors.primaryColor),
                                    const SizedBox(width: 4),
                                    const AppText(text: '12', fontSize: 12, color: Colors.black),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Icon(Icons.reply, size: 16, color: AppColors.primaryColor),
                                    const SizedBox(width: 4),
                                    const AppText(text: 'Reply', fontSize: 12, color: Colors.black),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Icon(Icons.share, size: 16, color: AppColors.primaryColor),
                                    const SizedBox(width: 4),
                                    const AppText(text: 'Share', fontSize: 12, color: Colors.black),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const AppText(
                    text: 'Bookmark yourself',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const AppText(
                    text: 'Share on insights',
                    fontSize: 12,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const AppText(
                    text: 'Ask Expert',
                    fontSize: 12,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: title,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          AppText(
            text: description,
            fontSize: 12,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }
}