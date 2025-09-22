import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import '../../../images/images.dart';

class SpeakerDetailsScreen extends StatelessWidget {
  const SpeakerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,

        title: const AppText(
          text: 'Speaker Details',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Speaker Profile and Biography Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.containerGreyColor
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Speaker Profile
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(Images.drjohnthan),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: const AppText(
                        text: 'Dr. Johnathan',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: const AppText(
                        text: 'Director of Regional Affairs',
                        fontSize: 14,
                        color: AppColors.darkgrey,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: const AppText(
                        text: 'Middle East Institute',
                        fontSize: 14,
                        color: AppColors.darkgrey,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Biography
                    const AppText(
                      text: 'Biography',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 12),
                    const AppText(
                      text: 'Dr. Ahmed Hassan is a leading expert in artificial intelligence and digital transformation, with over 15 years of experience in technology innovation. He has led major digital transformation initiatives across Fortune 500 companies and is a recognized thought leader in AI ethics and sustainable technology development.\n\nPrior to founding Tech Innovation Ltd, Dr. Hassan served as Chief Technology Officer at several multinational corporations, where he spearheaded breakthrough AI implementations that delivered exceptional business outcomes and customer experiences.\n\nHe holds a Ph.D. in Computer Science from MIT and has published over 50 research papers on machine learning, neural networks, and AI governance frameworks. Dr. Hassan is also a frequent keynote speaker at international technology conferences and panel meets.',
                      fontSize: 14,
                      color: AppColors.darkgrey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Areas of Expertise
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.containerGreyColor
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const AppText(
                      text: 'Areas of Expertise',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    _buildExpertiseChip('Artificial Intelligence', AppColors.lightred),
                    _buildExpertiseChip('Machine Learning', AppColors.lightPurpleColor),
                    _buildExpertiseChip('Digital Transformation', AppColors.lightred),
                    _buildExpertiseChip('Ethics in AI', AppColors.lightPurpleColor),
                    _buildExpertiseChip('Innovation Strategy', AppColors.lightred),
                    _buildExpertiseChip('Technology Leadership', AppColors.lightPurpleColor),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Speaking Sessions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    text: 'Speaking Sessions (3)',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: AppColors.darkgrey,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Session Cards
              _buildSessionCard(
                title: 'Digital Transformation in MENA',
                speaker: 'Dr. Sarah Hassan',
                time: '2:00 PM - 3:00 PM',
                duration: '90 minutes',
                room: 'Hall B',
                sessionType: 'Keynote',
                sessionTypeColor: Colors.blue,
                description: 'Exploring the role of diplomacy and collaboration in shaping future policies',
              ),
              const SizedBox(height: 12),
              _buildSessionCard(
                title: 'The Future of Regional Cooperation',
                speaker: 'Prof. Omar Khalid',
                time: '10:00 AM - 11:30 AM',
                duration: '90 minutes',
                room: 'Hall B',
                sessionType: 'Panel',
                sessionTypeColor: Colors.orange,
                description: 'Exploring the role of diplomacy and collaboration in shaping future policies',
              ),
              const SizedBox(height: 24),

              // Connect & Contact Section
              const AppText(
                text: 'Connect & Contact',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 16),
              _buildContactOption(const AssetImage('assets/icons/linkedin.png'), 'LinkedIn'),
              const SizedBox(height: 12),
              _buildContactOption(const AssetImage('assets/Facebook.png'), 'Facebook'),
              const SizedBox(height: 12),
              _buildContactOption(const AssetImage('assets/icons/website.png'), 'Website',),
              const SizedBox(height: 12),
              _buildContactOption(const AssetImage('assets/icons/mail.png'), 'Email',),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpertiseChip(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppText(
        text: text,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryColor,
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
    required String description,
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
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: AssetImage(Images.drjohnthan),
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
            text: description,
            fontSize: 12,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.access_time, size: 10, color: AppColors.darkgrey),
              AppText(
                text: time,
                fontSize: 10,
                color: AppColors.darkgrey,
              ),
              AppText(
                text: 'Duration',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black,
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
                color: Colors.black,
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

  Widget _buildContactOption(AssetImage image, String title,) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mediumGreyColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: image,
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 12),
          AppText(
            text: title,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}