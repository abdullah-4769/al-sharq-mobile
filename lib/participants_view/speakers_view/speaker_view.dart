import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/participants_view/speakers_view/speaker_details_view.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:get/get.dart';
import '../../../custom_widgets/app_text.dart';
import '../../../images/images.dart';
import '../../../utils/shared_preference.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/response_models/participant_response_model/speaker_part_in_participant/speaker_short_detail_responsemodel.dart';
import '../../view_model/participant_viewmodel/speaker_part_in_participant/speaker_short_detail_viewmodel.dart';

class SpeakersScreen extends StatefulWidget {
  const SpeakersScreen({super.key});

  @override
  State<SpeakersScreen> createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
  final TextEditingController searchController = TextEditingController();
  final SpeakerShortDetailViewModel viewModel = Get.put(SpeakerShortDetailViewModel());

  int? _currentEventId;

  @override
  void initState() {
    super.initState();
    _getEventIdAndFetchSpeakers();
  }

  Future<void> _getEventIdAndFetchSpeakers() async {
    try {
      _currentEventId = await SharedPrefsHelper.getLatestEventId();
      print('=== Retrieved event ID: $_currentEventId ===');

      if (_currentEventId != null) {
        viewModel.fetchSpeakerShortDetails(_currentEventId!);
      }
    } catch (e) {
      print('=== Error getting event ID: $e ===');
    }
  }

  // void _navigateToSpeakerDetails(SpeakerShortDetail speaker) {
  //   print('=== Navigating to speaker details for: ${speaker.user.name} ===');
  //   Get.to(() => SpeakerDetailsScreen(speaker: speaker));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const AppText(
          text: 'Speakers',
          color: AppColors.blackColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Obx(() {
        if (viewModel.isLoading.value && viewModel.allSpeakers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage.value.isNotEmpty && viewModel.allSpeakers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: 'Error loading speakers',
                  fontSize: 16,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Retry',
                  onPressed: _getEventIdAndFetchSpeakers,
                  backgroundColor: AppColors.primaryColor,
                  textColor: AppColors.whiteColor,
                ),
              ],
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
                      hintText: "Search speakers...",
                      controller: searchController,
                      suffixIcon: Icons.search,
                      onChanged: (value) {
                        viewModel.searchSpeakers(value);
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


            // Filter Buttons - Horizontal Scroll
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterButton('All', 0),
                    const SizedBox(width: 8),
                    _buildFilterButton('Keynote', 1),
                    const SizedBox(width: 8),
                    _buildFilterButton('Technology', 2),
                    const SizedBox(width: 8),
                    _buildFilterButton('Business', 3),
                  ],
                ),
              ),
            ),

            // Speakers Count
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${viewModel.filteredSpeakers.length} Speakers Showing',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),

            // Speaker List
            Expanded(
              child: _buildSpeakerList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterButton(String text, int index) {
    return Obx(() {
      bool isSelected = viewModel.selectedFilter.value == index;
      return GestureDetector(
        onTap: () {
          viewModel.setFilter(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSpeakerList() {
    if (viewModel.filteredSpeakers.isEmpty && viewModel.searchQuery.value.isNotEmpty) {
      return _buildNoResults();
    }

    if (viewModel.filteredSpeakers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: viewModel.filteredSpeakers.length,
      itemBuilder: (context, index) {
        final speaker = viewModel.filteredSpeakers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildSpeakerCard(speaker),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.darkgrey,
          ),
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
          Icon(
            Icons.person_outline,
            size: 64,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 16),
          AppText(
            text: 'No Speakers Available',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Check back later for speaker information',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerCard(SpeakerShortDetail speaker) {
    final categoryColor = _getCategoryColor(speaker.tags);
    final category = _getPrimaryCategory(speaker.tags);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Speaker Image
              _buildSpeakerImage(speaker.user.file),
              const SizedBox(width: 16),

              // Speaker Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                speaker.user.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Designations
                              if (speaker.designations.isNotEmpty)
                                Text(
                                  speaker.designations.take(2).join(', '),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                              // Expertise
                              if (speaker.expertise.isNotEmpty)
                                Text(
                                  speaker.expertise.take(2).join(', '),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),

                        // Tags
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                speaker.sessionsCountText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Bio
          Text(
            speaker.bio.isNotEmpty ? speaker.bio : 'No bio available',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: CustomButton(
              text: 'View Details',
              onPressed: () {
                Get.to(() => SpeakerDetailsScreen(speakerId: speaker.id));
              },
              backgroundColor: AppColors.primaryColor,
              height: 36,
            ),
          ),
        ],
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
  Widget _buildSpeakerImage(String? fileUrl) {
    print('=== Building speaker list image with URL: $fileUrl ===');

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
            print('=== Error loading image: $error ===');
            return ClipOval(
              child: Image.asset(
                Images.drjohnthan,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      );
    } else {
      return ClipOval(
        child: Image.asset(
          Images.drjohnthan,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}