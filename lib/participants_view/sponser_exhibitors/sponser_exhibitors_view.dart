import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../view_model/participant_viewmodel/participant_sponsor_exibitor_viewmodel/participant_sponsor_viewmodel.dart';
import 'exhibitor_details_screen.dart';
// Update your SponsorsExhibitorsScreen to use the viewmodel

class SponsorsExhibitorsScreen extends StatefulWidget {
  const SponsorsExhibitorsScreen({super.key});

  @override
  State<SponsorsExhibitorsScreen> createState() => _SponsorsExhibitorsScreenState();
}

class _SponsorsExhibitorsScreenState extends State<SponsorsExhibitorsScreen> {
  final TextEditingController searchController = TextEditingController();
  final ParticipantSponsorViewModel viewModel = Get.put(ParticipantSponsorViewModel());

  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchSponsorsAndExhibitors(context);
    });
  }

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
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(
              viewModel.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: CustomTextField(
                      hintText: "Search",
                      controller: searchController,
                      suffixIcon: Icons.search,
                      onChanged: (value) {
                        viewModel.search(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
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
              child: _buildContent(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = viewModel.selectedTab.value == index;
    return GestureDetector(
      onTap: () {
        viewModel.changeTab(index);
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

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        // Gold Sponsors Section
        if (viewModel.selectedTab.value == 0 || viewModel.selectedTab.value == 1) ...[
          if (viewModel.goldSponsors.isNotEmpty) ...[
            _buildSectionHeader('Gold Sponsors', Icons.star, Colors.orange),
            const SizedBox(height: 16),
            ...viewModel.goldSponsors.map((sponsor) =>
                _buildSponsorCard(
                  companyName: sponsor.name,
                  description: sponsor.description,
                  color: Colors.orange,
                  logoText: _getInitials(sponsor.name),
                  sponsorId: sponsor.id,
                )
            ).toList(),
            const SizedBox(height: 32),
          ],
        ],

        // Silver Sponsors Section
        if (viewModel.selectedTab.value == 0 || viewModel.selectedTab.value == 2) ...[
          if (viewModel.silverSponsors.isNotEmpty) ...[
            _buildSectionHeader('Silver Sponsors', Icons.star_border, Colors.grey),
            const SizedBox(height: 16),
            ...viewModel.silverSponsors.map((sponsor) =>
                _buildSponsorCard(
                  companyName: sponsor.name,
                  description: sponsor.description,
                  color: Colors.grey,
                  logoText: _getInitials(sponsor.name),
                  sponsorId: sponsor.id,
                )
            ).toList(),
            const SizedBox(height: 32),
          ],
        ],

        // Exhibitors Section (only show in All tab)
        if (viewModel.selectedTab.value == 0) ...[
          if (viewModel.filteredExhibitors.isNotEmpty) ...[
            _buildSectionHeader('Exhibitors', Icons.business, Colors.blue),
            const SizedBox(height: 16),
            ...viewModel.filteredExhibitors.map((exhibitor) =>
                _buildExhibitorCard(
                  companyName: exhibitor.name,
                  hallNumber: exhibitor.location,
                  description: exhibitor.description,
                  color: _getRandomColor(),
                  logoText: _getInitials(exhibitor.name),
                  exhibitorId: exhibitor.id,
                )
            ).toList(),
            const SizedBox(height: 20),
          ],
        ],

        // Show message when no data
        if (viewModel.filteredSponsors.isEmpty && viewModel.filteredExhibitors.isEmpty) ...[
          const Center(
            child: Text('No sponsors or exhibitors found'),
          ),
        ],
      ],
    );
  }

  // Helper method to get initials from name
  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }
    return '??';
  }

  // Helper method to generate random color
  Color _getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  // Keep your existing _buildSectionHeader, _buildSponsorCard, _buildExhibitorCard methods
  // but update _buildSponsorCard and _buildExhibitorCard to accept id parameters:

  Widget _buildSponsorCard({
    required String companyName,
    required String description,
    required Color color,
    required String logoText,
    required int sponsorId,
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
              Get.to(() => ExhibitorDetailScreen(
                  id: sponsorId,
                  type: 'sponsor'
              ));
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
    required int exhibitorId,
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
            onPressed: () {
              Get.to(() => ExhibitorDetailScreen(
                  id: exhibitorId,
                  type: 'exhibitor'
              ));
            },
            backgroundColor: AppColors.primaryColor,
            height: 40,
          ),
        ],
      ),
    );
  }

  // Keep your existing _buildSectionHeader method
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}