import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/response_models/organizer_response_models/organizershowallspeaker_model.dart';
import '../../participants_view/speakers_view/speaker_details_view.dart';
import '../../view_model/organizer_viewmodels/organizershowallspeaker_viewmodel.dart';
import '../../view_model/organizer_viewmodels/organizerdeletespeaker_viewmodel.dart';
import '../add_new_speaker/add_new_speaker_view.dart';
import '../add_new_speaker/organizeraddnewspeaker_dialog.dart';

class OrganizerShowAllSpeakerScreen extends StatefulWidget {
  const OrganizerShowAllSpeakerScreen({super.key});

  @override
  State<OrganizerShowAllSpeakerScreen> createState() => _OrganizerShowAllSpeakerScreenState();
}

class _OrganizerShowAllSpeakerScreenState extends State<OrganizerShowAllSpeakerScreen> {
  final TextEditingController searchController = TextEditingController();
  final OrganizerShowAllSpeakerViewModel _speakersViewModel = Get.put(OrganizerShowAllSpeakerViewModel());
  final OrganizerDeleteSpeakerViewModel _deleteSpeakerViewModel = Get.put(OrganizerDeleteSpeakerViewModel());

  @override
  void initState() {
    super.initState();
    _speakersViewModel.fetchAllSpeakers();
  }

  void _navigateToSpeakerDetails(int speakerId) {
    print('=== Navigating to speaker details for ID: $speakerId ===');
    Get.to(() => SpeakerDetailsScreen(speakerId: speakerId));
  }

  void _editSpeaker(OrganizerSpeaker speaker) {
    _speakersViewModel.editSpeaker(speaker);
    Get.snackbar(
      'Coming Soon',
      'Edit speaker feature will be implemented soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _deleteSpeaker(OrganizerSpeaker speaker) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const AppText(
            text: 'Delete Speaker',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          content: AppText(
            text: 'Are you sure you want to delete ${speaker.user.name}? This action cannot be undone.',
            fontSize: 14,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const AppText(
                text: 'Cancel',
                color: AppColors.primaryColor,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const AppText(
                text: 'Delete',
                color: Colors.red,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await _deleteSpeakerViewModel.deleteSpeaker(speaker.id);

      if (success) {
        // Refresh the speakers list after successful deletion
        _speakersViewModel.fetchAllSpeakers();

        Get.snackbar(
          'Success',
          _deleteSpeakerViewModel.successMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          _deleteSpeakerViewModel.errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
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
          text: 'Manage Speakers',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Obx(() {
        // Show loading for delete operation
        if (_deleteSpeakerViewModel.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 16),
                AppText(
                  text: 'Deleting speaker...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        if (_speakersViewModel.isLoading.value && _speakersViewModel.speakersData.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 16),
                AppText(
                  text: 'Loading speakers...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        if (_speakersViewModel.error.isNotEmpty && _speakersViewModel.speakersData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: _speakersViewModel.error.value,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _speakersViewModel.fetchAllSpeakers,
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
                      hintText: 'Search speakers...',
                      controller: searchController,
                      suffixIcon: Icons.search,
                      onChanged: (value) => _speakersViewModel.searchSpeakers(value),
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
                    _buildStatChip('All', _speakersViewModel.totalSpeakers.toString(), Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatChip('Featured', _speakersViewModel.featuredSpeakers.toString(), Colors.orange),
                    const SizedBox(width: 8),
                    _buildStatChip('Verified', _speakersViewModel.verifiedSpeakers.toString(), Colors.green),
                    const SizedBox(width: 8),
                    _buildStatChip('Standard', _speakersViewModel.standardSpeakers.toString(), Colors.grey),
                  ],
                ),
              ),
            ),

            // Add New Speaker Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                child: CustomButton(
                  text: 'Add New Speaker',
                  onPressed: () {
                    _showAddSpeakerDialog();
                  },
                  backgroundColor: AppColors.primaryColor,
                  height: 48,
                ),
              ),
            ),

            // Speakers Count
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: '${_speakersViewModel.filteredSpeakers.length} Speakers Showing',
                    fontSize: 14,
                    color: AppColors.darkgrey,
                  ),
                  // GestureDetector(
                  //   onTap: () {},
                  //   child: const AppText(
                  //     text: 'View All',
                  //     fontSize: 14,
                  //     color: AppColors.primaryColor,
                  //   ),
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Speakers List
            Expanded(
              child: _buildSpeakersList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: label,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
          const SizedBox(width: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakersList() {
    final speakers = _speakersViewModel.filteredSpeakers;

    if (speakers.isEmpty && _speakersViewModel.searchQuery.value.isNotEmpty) {
      return _buildNoResults();
    }

    if (speakers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: speakers.length,
      itemBuilder: (context, index) {
        final speaker = speakers[index];
        return _buildSpeakerCard(speaker);
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.darkgrey),
          const SizedBox(height: 16),
          AppText(
            text: 'No speakers found',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Try adjusting your search terms',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: AppColors.darkgrey),
          const SizedBox(height: 16),
          AppText(
            text: 'No Speakers Available',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Add new speakers to get started',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerCard(OrganizerSpeaker speaker) {
    final categoryColor = _getCategoryColor(speaker.tags);
    final category = _getPrimaryCategory(speaker.tags);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Speaker Image
              _buildSpeakerImage(speaker.user.file, speaker.user.initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: speaker.user.name,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      text: speaker.primaryDesignation,
                      fontSize: 13,
                      color: AppColors.darkgrey,
                    ),
                    if (speaker.designations.length > 1)
                      AppText(
                        text: speaker.designations.skip(1).join(', '),
                        fontSize: 12,
                        color: AppColors.darkgrey,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: speaker.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      speaker.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: speaker.statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: categoryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            text: speaker.bio.isNotEmpty ? speaker.bio : 'No biography available',
            fontSize: 12,
            color: AppColors.darkgrey,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          if (speaker.expertise.isNotEmpty)
            Text(
              'Expertise: ${speaker.expertiseSummary}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.darkgrey,
              ),
            ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'View Details',
            onPressed: () => _navigateToSpeakerDetails(speaker.id),
            backgroundColor: AppColors.primaryColor,
            height: 36,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _editSpeaker(speaker),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const AppText(
                          text: 'Edit',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _deleteSpeaker(speaker),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const AppText(
                          text: 'Delete',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddSpeakerDialog() {
    showDialog(
      context: context,
      builder: (context) => OrganizerAddNewSpeakerDialog(
        onUserRegistered: (userId) {
          Navigator.of(context).pop(); // Close dialog
          Get.to(() => OrganizerAddNewSpeakerScreen(userId: userId));
        },
      ),
    ).then((value) {
      // If user cancels the dialog, nothing happens (stays on current screen)
    });
  }
  Widget _buildSpeakerImage(String? fileUrl, String initials) {
    if (fileUrl != null && fileUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: fileUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            return _buildDefaultAvatar(initials);
          },
        ),
      );
    } else {
      return _buildDefaultAvatar(initials);
    }
  }

  Widget _buildDefaultAvatar(String initials) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppText(
          text: initials,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getCategoryColor(List<String> tags) {
    if (tags.any((tag) => tag.toLowerCase().contains('keynote'))) {
      return Colors.blue;
    } else if (tags.any((tag) => tag.toLowerCase().contains('technology') || tag.toLowerCase().contains('tech'))) {
      return Colors.green;
    } else if (tags.any((tag) => tag.toLowerCase().contains('business'))) {
      return Colors.orange;
    } else if (tags.any((tag) => tag.toLowerCase().contains('workshop'))) {
      return Colors.purple;
    } else {
      return AppColors.primaryColor;
    }
  }

  String _getPrimaryCategory(List<String> tags) {
    if (tags.any((tag) => tag.toLowerCase().contains('keynote'))) {
      return 'Keynote';
    } else if (tags.any((tag) => tag.toLowerCase().contains('technology') || tag.toLowerCase().contains('tech'))) {
      return 'Technology';
    } else if (tags.any((tag) => tag.toLowerCase().contains('business'))) {
      return 'Business';
    } else if (tags.any((tag) => tag.toLowerCase().contains('workshop'))) {
      return 'Workshop';
    } else if (tags.any((tag) => tag.toLowerCase().contains('innovation'))) {
      return 'Innovation';
    } else {
      return 'Speaker';
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}