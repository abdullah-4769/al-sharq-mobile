import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

import '../add_new_sponser/add_new_sponser_view.dart';

class ManageSponsorsScreen extends StatefulWidget {
  const ManageSponsorsScreen({super.key});

  @override
  State<ManageSponsorsScreen> createState() => _ManageSponsorsScreenState();
}

class _ManageSponsorsScreenState extends State<ManageSponsorsScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<SponsorData> sponsors = [
    SponsorData(
      name: 'TechCore Solutions',
      description: 'Leading provider of enterprise software solutions and digital transformation services',
      logoColor: Colors.blue,
      logoText: 'TC',
      type: 'Gold Sponsors',
    ),
    SponsorData(
      name: 'InnovateLab Inc.',
      description: 'Pioneering AI and machine learning technologies for business and transforming industries',
      logoColor: Colors.green,
      logoText: 'IL',
      type: 'Gold Sponsors',
    ),
    SponsorData(
      name: 'DataFlow Systems',
      description: 'Leading provider of enterprise software solutions and digital transformation services',
      logoColor: Colors.purple,
      logoText: 'DF',
      type: 'Silver Sponsors',
    ),
    SponsorData(
      name: 'SecureNet Technologies',
      description: 'Pioneering AI and machine learning technologies for business and transforming industries',
      logoColor: Colors.red,
      logoText: 'SN',
      type: 'Silver Sponsors',
    ),
    SponsorData(
      name: 'CloudTech Solutions',
      description: 'Leading provider of enterprise software solutions and digital transformation services',
      logoColor: Colors.orange,
      logoText: 'CT',
      type: 'Exhibitors',
    ),
    SponsorData(
      name: 'CloudTech Solutions',
      description: 'Leading provider of enterprise software solutions and digital transformation services',
      logoColor: Colors.teal,
      logoText: 'CT',
      type: 'Exhibitors',
    ),
    SponsorData(
      name: 'CloudTech Solutions',
      description: 'Leading provider of enterprise software solutions and digital transformation services',
      logoColor: Colors.indigo,
      logoText: 'CT',
      type: 'Exhibitors',
    ),
  ];

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
          text: 'Manage Sponsors',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: 'Search',
                    controller: searchController,
                    suffixIcon: Icons.search,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.tune, color: AppColors.primaryColor),
              ],
            ),
          ),

          // Stats Bar
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildStatChip('Gold', '24', Colors.yellow, false),
                const SizedBox(width: 12),
                _buildStatChip('Silver', '5', Colors.grey, false),
                const SizedBox(width: 12),
                _buildStatChip('Exhibitors', '12', Colors.green, false),
              ],
            ),
          ),

          // Add New Sponsor Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Add New Sponsor',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddNewSponsorScreen()),
                );
              },
              backgroundColor: AppColors.primaryColor,
              height: 48,
            ),
          ),

          // Sponsors List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSponsorSection('Gold Sponsors', sponsors.where((s) => s.type == 'Gold Sponsors').toList()),
                const SizedBox(height: 16),
                _buildSponsorSection('Silver Sponsors', sponsors.where((s) => s.type == 'Silver Sponsors').toList()),
                const SizedBox(height: 16),
                _buildSponsorSection('Exhibitors', sponsors.where((s) => s.type == 'Exhibitors').toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String count, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : AppColors.mediumGreyColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? color : AppColors.darkgrey,
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              text: count,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorSection(String title, List<SponsorData> sectionSponsors) {
    IconData sectionIcon;
    Color sectionColor;

    switch (title) {
      case 'Gold Sponsors':
        sectionIcon = Icons.star;
        sectionColor = Colors.orange;
        break;
      case 'Silver Sponsors':
        sectionIcon = Icons.star_border;
        sectionColor = Colors.grey;
        break;
      case 'Exhibitors':
        sectionIcon = Icons.business;
        sectionColor = Colors.blue;
        break;
      default:
        sectionIcon = Icons.business;
        sectionColor = Colors.grey;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(sectionIcon, color: sectionColor, size: 16),
            const SizedBox(width: 8),
            AppText(
              text: title,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sectionSponsors.map((sponsor) => _buildSponsorCard(sponsor)).toList(),
      ],
    );
  }

  Widget _buildSponsorCard(SponsorData sponsor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: sponsor.logoColor,
                child: AppText(
                  text: sponsor.logoText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  text: sponsor.name,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            text: sponsor.description,
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

class SponsorData {
  final String name;
  final String description;
  final Color logoColor;
  final String logoText;
  final String type;

  SponsorData({
    required this.name,
    required this.description,
    required this.logoColor,
    required this.logoText,
    required this.type,
  });
}