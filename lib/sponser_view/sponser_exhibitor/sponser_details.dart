import 'package:al_sharq_conference/sponser_view/sponser_exhibitor/session_sponsered_expension.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

class SponsorDetailScreen extends StatelessWidget {
  const SponsorDetailScreen({super.key});

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
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: AppColors.warningColor, size: 14),
                    const SizedBox(width: 4),
                    const AppText(
                      text: 'Gold Sponsors',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
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
                        const AppText(
                          text: 'TechCorp Solutions',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        const AppText(
                          text: 'TechWorld Inc. is a leading provider of enterprise software solutions and digital transformation services, helping Fortune 500 companies worldwide streamline operations, enhance productivity, and embrace innovation. With decades of experience across multiple industries, TechWorld specializes in creating customized technology solutions that not only drive growth, improve customer experiences, and enable organizations to stay competitive in an ever-evolving digital landscape. Committed to excellence, TechWorld combines cutting-edge tools, expert consulting, and best-in-class support to deliver measurable business outcomes and empower companies to achieve their strategic goals.',
                          fontSize: 13,
                          color: AppColors.darkgrey,
                        ),
                        const SizedBox(height: 24),

                        // Contact Information Section
                        const AppText(
                          text: 'Contact Information',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        _buildContactItem(
                          icon: Icons.language,
                          title: 'Website',
                          subtitle: 'www.techcorp.com',
                          iconColor: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildContactItem(
                          icon: Icons.email,
                          title: 'Email',
                          subtitle: 'contact@techcorp.com',
                          iconColor: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildContactItem(
                          icon: Icons.phone,
                          title: 'Phone',
                          subtitle: '+1 (555) 123-4567',
                          iconColor: Colors.purple,
                        ),
                        const SizedBox(height: 24),

                        // Representatives Section
                        const AppText(
                          text: 'Representatives',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        _buildRepresentative(
                          name: 'Ahmed Al-Rashid',
                          position: 'Tech Solutions Rep.',
                        ),
                        const SizedBox(height: 12),
                        _buildRepresentative(
                          name: 'Sarah Mitchell',
                          position: 'Innovation Labs',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Products & Services Section
                  Container(
                    width: double.infinity,
                    color: AppColors.lightBackground,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          text: 'Products & Services',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        _buildServiceItem(
                          icon: Icons.cloud,
                          title: 'Cloud Infrastructure',
                          description: 'Scalable cloud computing solutions for enterprise applications',
                          iconColor: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildServiceItem(
                          icon: Icons.analytics,
                          title: 'Data Analytics',
                          description: 'Business intelligence and data visualization platforms',
                          iconColor: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildServiceItem(
                          icon: Icons.security,
                          title: 'Security Solutions',
                          description: 'Enterprise-grade security and compliance tools',
                          iconColor: Colors.purple,
                        ),
                        SessionsSponsoredExtensionScreen()
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
              color: Colors.black,
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

  Widget _buildRepresentative({required String name, required String position}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
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
            child: const AppText(
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
                  color: Colors.black,
                ),
                AppText(
                  text: description,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}