import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/data/response_models/organizer_response_models/organizer_all_sponsor_show_model.dart';
import 'package:al_sharq_conference/view_model/organizer_viewmodels/organizer_all_sponsor_show_viewmodel.dart';
import '../../sponser_view/sponser_exhibitor/sponser_details.dart';
import '../add_new_sponser/add_new_sponser_view.dart';

class ManageSponsorsScreen extends StatefulWidget {
  const ManageSponsorsScreen({super.key});

  @override
  State<ManageSponsorsScreen> createState() => _ManageSponsorsScreenState();
}

class _ManageSponsorsScreenState extends State<ManageSponsorsScreen> {
  final TextEditingController searchController = TextEditingController();
  final OrganizerAllSponsorShowViewModel _sponsorsViewModel =
  Get.put(OrganizerAllSponsorShowViewModel());

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
      body: Obx(() {
        if (_sponsorsViewModel.isLoading.value && _sponsorsViewModel.sponsorsData.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 16),
                AppText(
                  text: 'Loading sponsors...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        if (_sponsorsViewModel.error.isNotEmpty && _sponsorsViewModel.sponsorsData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: _sponsorsViewModel.error.value,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _sponsorsViewModel.fetchSponsors,
                  child: const AppText(text: 'Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
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

            // Stats Bar - Using API data with horizontal scroll
            Container(
              color: AppColors.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatChip('Gold', _sponsorsViewModel.goldCount.toString(), Colors.yellow, false),
                    const SizedBox(width: 12),
                    _buildStatChip('Silver', _sponsorsViewModel.silverCount.toString(), Colors.grey, false),
                    const SizedBox(width: 12),
                    _buildStatChip('Others', _sponsorsViewModel.otherCount.toString(), Colors.green, false),
                    // You can add more stat chips here if needed
                  ],
                ),
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
                    MaterialPageRoute(builder: (context) => const OrganizerAddNewSponsorScreen()),
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
                  if (_sponsorsViewModel.goldSponsors.isNotEmpty)
                    _buildSponsorSection('Gold Sponsors', _sponsorsViewModel.goldSponsors),
                  if (_sponsorsViewModel.silverSponsors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSponsorSection('Silver Sponsors', _sponsorsViewModel.silverSponsors),
                  ],
                  if (_sponsorsViewModel.otherSponsors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSponsorSection('Other Sponsors', _sponsorsViewModel.otherSponsors),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
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

  Widget _buildSponsorSection(String title, List<OrganizerAllSponsorShowSponsor> sectionSponsors) {
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
      default:
        sectionIcon = Icons.business;
        sectionColor = Colors.blue;
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

  Widget _buildSponsorCard(OrganizerAllSponsorShowSponsor sponsor) {
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
              // Sponsor Logo/Image
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getColorFromName(sponsor.name),
                ),
                child: sponsor.picUrl != null && sponsor.picUrl!.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    sponsor.picUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: AppText(
                          text: _getInitials(sponsor.name),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                )
                    : Center(
                  child: AppText(
                    text: _getInitials(sponsor.name),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: sponsor.name,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      text: sponsor.category,
                      fontSize: 12,
                      color: AppColors.darkgrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            text: sponsor.description,
            fontSize: 13,
            color: AppColors.darkgrey,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Learn More',
            onPressed: () {
              Get.to(() => SponsorDetailScreen(sponsorId: sponsor.id));
            },
            backgroundColor: AppColors.primaryColor,
            height: 40,
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) {
      return '??'; // Return default initials for empty names
    }

    // Split the name into words and get first letters
    List<String> words = name.trim().split(' ');

    if (words.isEmpty) {
      return '??';
    }

    // Get first letter of first word
    String firstInitial = words[0][0].toUpperCase();

    // If there's a second word, get its first letter too
    if (words.length > 1) {
      String secondInitial = words[1][0].toUpperCase();
      return '$firstInitial$secondInitial';
    }

    // If only one word, return just the first letter
    return firstInitial;
  }
  // String _getInitials(String name) {
  //   final names = name.split(' ');
  //   if (names.length >= 2) {
  //     return '${names[0][0]}${names[1][0]}'.toUpperCase();
  //   } else if (name.isNotEmpty) {
  //     return name.substring(0, 1).toUpperCase();
  //   }
  //   return 'S';
  // }

  Color _getColorFromName(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];
    final index = name.length % colors.length;
    return colors[index];
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}