import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

import '../../data/response_models/organizer_response_models/organizer_exhibitor_show_model.dart';
import '../../participants_view/sponser_exhibitors/exhibitor_details_screen.dart';
import '../../view_model/organizer_viewmodels/organizer_exhibitor_show_viewmodel.dart';
import 'organizeraddnewexhibitor_screen.dart';

class OrganizerManageExhibitorsScreen extends StatefulWidget {
  const OrganizerManageExhibitorsScreen({super.key});

  @override
  State<OrganizerManageExhibitorsScreen> createState() => _OrganizerManageExhibitorsScreenState();
}

class _OrganizerManageExhibitorsScreenState extends State<OrganizerManageExhibitorsScreen> {
  final TextEditingController searchController = TextEditingController();
  final OrganizerExhibitorShowViewModel _exhibitorsViewModel =
  Get.put(OrganizerExhibitorShowViewModel());

  @override
  void initState() {
    super.initState();
    _exhibitorsViewModel.fetchExhibitors();
  }

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
          text: 'Manage Exhibitors',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Obx(() {
        if (_exhibitorsViewModel.isLoading.value && _exhibitorsViewModel.exhibitorsData.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 16),
                AppText(
                  text: 'Loading exhibitors...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        if (_exhibitorsViewModel.error.isNotEmpty && _exhibitorsViewModel.exhibitorsData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: _exhibitorsViewModel.error.value,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _exhibitorsViewModel.fetchExhibitors,
                  child: const AppText(text: 'Retry'),
                ),
              ],
            ),
          );
        }

        final searchResults = _exhibitorsViewModel.searchExhibitors(searchController.text);
        final exhibitorsWithBooths = searchResults.where((e) => e.booths.isNotEmpty).toList();
        final exhibitorsWithoutBooths = searchResults.where((e) => e.booths.isEmpty).toList();

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
                      hintText: 'Search exhibitors...',
                      controller: searchController,
                      suffixIcon: Icons.search,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.tune, color: AppColors.primaryColor),
                ],
              ),
            ),

            // Stats Bar - Horizontal Scroll
            Container(
              color: AppColors.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatChip('Total', _exhibitorsViewModel.totalExhibitors.toString(), Colors.blue),
                    const SizedBox(width: 12),
                    _buildStatChip('With Booths', _exhibitorsViewModel.exhibitorsWithBoothsCount.toString(), Colors.green),
                    const SizedBox(width: 12),
                    _buildStatChip('No Booths', _exhibitorsViewModel.exhibitorsWithoutBoothsCount.toString(), Colors.orange),
                    const SizedBox(width: 12),
                    _buildStatChip('Products', _exhibitorsViewModel.totalProducts.toString(), Colors.purple),
                    const SizedBox(width: 12),
                    _buildStatChip('Booths', _exhibitorsViewModel.totalBooths.toString(), Colors.red),
                  ],
                ),
              ),
            ),
            // Add New Exhibitor Button
            // In your OrganizerManageExhibitorsScreen, update the Add New Exhibitor button:
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: CustomButton(
                text: 'Add New Exhibitor',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrganizerAddNewExhibitorScreen()),
                  );
                },
                backgroundColor: AppColors.primaryColor,
                height: 48,
              ),
            ),

            // Exhibitors List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (exhibitorsWithBooths.isNotEmpty)
                    _buildExhibitorSection('Exhibitors with Booths', exhibitorsWithBooths),

                  if (exhibitorsWithoutBooths.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildExhibitorSection('Exhibitors without Booths', exhibitorsWithoutBooths),
                  ],

                  if (searchResults.isEmpty) ...[
                    const SizedBox(height: 60),
                    Column(
                      children: [
                        Icon(Icons.search_off, size: 64, color: AppColors.mediumGreyColor),
                        const SizedBox(height: 16),
                        AppText(
                          text: searchController.text.isEmpty
                              ? 'No exhibitors found'
                              : 'No exhibitors found for "${searchController.text}"',
                          fontSize: 16,
                          color: AppColors.darkgrey,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
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

  Widget _buildExhibitorSection(String title, List<OrganizerExhibitor> sectionExhibitors) {
    IconData sectionIcon;
    Color sectionColor;

    switch (title) {
      case 'Exhibitors with Booths':
        sectionIcon = Icons.assignment_turned_in;
        sectionColor = Colors.green;
        break;
      case 'Exhibitors without Booths':
        sectionIcon = Icons.assignment_late;
        sectionColor = Colors.orange;
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: sectionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppText(
                text: sectionExhibitors.length.toString(),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sectionColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sectionExhibitors.map((exhibitor) => _buildExhibitorCard(exhibitor)).toList(),
      ],
    );
  }

  Widget _buildExhibitorCard(OrganizerExhibitor exhibitor) {
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
              // Exhibitor Logo/Image
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getColorFromName(exhibitor.name),
                ),
                child: exhibitor.picUrl != null && exhibitor.picUrl!.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    exhibitor.picUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: AppText(
                          text: _getInitials(exhibitor.name),
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
                    text: _getInitials(exhibitor.name),
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
                      text: exhibitor.name,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      text: exhibitor.location,
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
            text: exhibitor.description,
            fontSize: 13,
            color: AppColors.darkgrey,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Booth Information
          if (exhibitor.booths.isNotEmpty)
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: AppColors.primaryColor),
                const SizedBox(width: 4),
                AppText(
                  text: exhibitor.boothInfo,
                  fontSize: 12,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),

          if (exhibitor.booths.isEmpty)
            Row(
              children: [
                Icon(Icons.warning, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                AppText(
                  text: 'No booth assigned',
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),

          const SizedBox(height: 8),

          // Products Count
          Row(
            children: [
              Icon(Icons.inventory_2, size: 14, color: AppColors.darkgrey),
              const SizedBox(width: 4),
              AppText(
                text: exhibitor.productsCount,
                fontSize: 12,
                color: AppColors.darkgrey,
              ),
            ],
          ),

          const SizedBox(height: 16),
          CustomButton(
            text: 'View Details',
            onPressed: () {
              Get.to(() => ExhibitorDetailScreen(id: exhibitor.id, type: 'exhibitor'));
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
      return '??';
    }

    List<String> words = name.trim().split(' ');
    if (words.isEmpty) {
      return '??';
    }

    String firstInitial = words[0][0].toUpperCase();
    if (words.length > 1) {
      String secondInitial = words[1][0].toUpperCase();
      return '$firstInitial$secondInitial';
    }

    return firstInitial;
  }

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