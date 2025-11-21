import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../images/images.dart';
import '../../data/response_models/participant_response_model/speaker_part_in_participant/session_byspeaker_response.dart';
import '../../repository/participants_repository/speaker_part_in_participant/session_byspeaker_viewmodel.dart';
import '../../view_model/participant_viewmodel/speaker_part_in_participant/speaker_full_detail_viewmodel.dart';
import '../seesion_details_view/session_detail_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SpeakerDetailsScreen extends StatefulWidget {
  final int speakerId;

  const SpeakerDetailsScreen({super.key, required this.speakerId});

  @override
  State<SpeakerDetailsScreen> createState() => _SpeakerDetailsScreenState();
}

class _SpeakerDetailsScreenState extends State<SpeakerDetailsScreen> {
  final SpeakerFullDetailViewModel speakerViewModel = Get.put(SpeakerFullDetailViewModel());
  final SessionBySpeakerViewModel sessionViewModel = Get.put(SessionBySpeakerViewModel());

  @override
  void initState() {
    super.initState();
    _fetchSpeakerFullDetails();
    _fetchSpeakerSessions();
  }

  void _fetchSpeakerFullDetails() {
    speakerViewModel.fetchSpeakerFullDetails(widget.speakerId);
  }

  void _fetchSpeakerSessions() {
    sessionViewModel.fetchSessionsBySpeaker(widget.speakerId);
  }

  // ==================== URL LAUNCHING METHODS ====================
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  // ==================== IMAGE BUILDER WITH CACHED NETWORK IMAGE ====================
  Widget _buildSpeakerImage(String? fileUrl) {
    print('=== Building speaker image with URL: $fileUrl ===');

    if (fileUrl != null && fileUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: fileUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 100,
            height: 100,
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
            print('=== CachedNetworkImage error ===');
            print('URL: $url');
            print('Error: $error');
            return _buildDefaultAvatar();
          },
        ),
      );
    } else {
      print('=== No image URL provided, showing default avatar ===');
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.grey[600],
      ),
    );
  }

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
      body: Obx(() {
        final speakerLoading = speakerViewModel.isLoading.value && speakerViewModel.speaker == null;
        final sessionLoading = sessionViewModel.isLoading.value && sessionViewModel.sessions.isEmpty;

        if (speakerLoading && sessionLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 16),
                AppText(
                  text: 'Loading speaker details...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== SPEAKER PROFILE SECTION ====================
                _buildSpeakerProfileSection(),
                const SizedBox(height: 24),

                // ==================== AREAS OF EXPERTISE SECTION ====================
                if (speakerViewModel.speaker?.expertise.isNotEmpty ?? false)
                  _buildExpertiseSection(),
                if (speakerViewModel.speaker?.expertise.isNotEmpty ?? false)
                  const SizedBox(height: 24),

                // ==================== SPEAKING SESSIONS SECTION ====================
                _buildSessionsSection(),
                const SizedBox(height: 24),

                // ==================== CONNECT & CONTACT SECTION ====================
                if (_hasSocialMedia())
                  _buildContactSection(),
                if (_hasSocialMedia())
                  const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ==================== HELPER METHODS FOR DATA EXTRACTION ====================
  bool _hasSocialMedia() {
    final speaker = speakerViewModel.speaker;
    if (speaker == null) return false;
    return speaker.website != null ||
        speaker.youtube != null ||
        speaker.facebook != null ||
        speaker.linkedin != null ||
        speaker.twitter != null;
  }

  // ==================== SPEAKER PROFILE SECTION ====================
  Widget _buildSpeakerProfileSection() {
    final speaker = speakerViewModel.speaker;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.containerGreyColor),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speaker Profile Image and Name
          Center(
            child: Column(
              children: [
                _buildSpeakerImage(speaker?.user.file),
                const SizedBox(height: 16),
                AppText(
                  text: speaker?.user.name ?? 'Loading...',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Designations
                if (speaker?.designations.isNotEmpty ?? false)
                  Column(
                    children: speaker!.designations.map((designation) =>
                        AppText(
                          text: designation,
                          fontSize: 14,
                          color: AppColors.darkgrey,
                          textAlign: TextAlign.center,
                        ),
                    ).toList(),
                  ),

                // Country
                if (speaker?.country != null) ...[
                  const SizedBox(height: 4),
                  AppText(
                    text: speaker!.country!,
                    fontSize: 14,
                    color: AppColors.darkgrey,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Biography Section
          const AppText(
            text: 'Biography',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          const SizedBox(height: 12),
          AppText(
            text: speaker?.bio.isNotEmpty == true ? speaker!.bio : 'No biography available',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }

  // ==================== EXPERTISE SECTION ====================
  Widget _buildExpertiseSection() {
    final expertise = speakerViewModel.speaker?.expertise ?? [];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.containerGreyColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            text: 'Areas of Expertise',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: expertise.map((expertise) =>
                _buildExpertiseChip(expertise, _getRandomChipColor()),
            ).toList(),
          ),
        ],
      ),
    );
  }

  // ==================== SESSIONS SECTION ====================
  Widget _buildSessionsSection() {
    return Obx(() {
      final sessions = sessionViewModel.sessions;
      final isLoading = sessionViewModel.isLoading.value;
      final error = sessionViewModel.errorMessage.value;

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (error.isNotEmpty) {
        return Column(
          children: [
            AppText(
              text: 'Error loading sessions',
              fontSize: 16,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Retry',
              onPressed: _fetchSpeakerSessions,
              backgroundColor: AppColors.primaryColor,
              textColor: AppColors.whiteColor,
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: 'Speaking Sessions (${sessions.length})',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const Icon(
                Icons.keyboard_arrow_up,
                color: AppColors.darkgrey,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dynamic Session Cards
          if (sessions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mediumGreyColor),
              ),
              child: const Center(
                child: AppText(
                  text: 'No sessions available',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ),
            )
          else
            Column(
              children: sessions.map((session) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildSessionCard(session),
                  ),
              ).toList(),
            ),
        ],
      );
    });
  }

  // ==================== CONTACT SECTION ====================
  Widget _buildContactSection() {
    final speaker = speakerViewModel.speaker;
    if (speaker == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          text: 'Connect & Contact',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        const SizedBox(height: 16),

        // LinkedIn
        if (speaker.linkedin != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildContactOption(
              const AssetImage('assets/icons/linkedin.png'),
              'LinkedIn',
              onTap: () => _launchUrl(speaker.linkedin!),
            ),
          ),

        // Facebook
        if (speaker.facebook != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildContactOption(
              const AssetImage('assets/Facebook.png'),
              'Facebook',
              onTap: () => _launchUrl(speaker.facebook!),
            ),
          ),

        // Website
        if (speaker.website != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildContactOption(
              const AssetImage('assets/icons/website.png'),
              'Website',
              onTap: () => _launchUrl(speaker.website!),
            ),
          ),

        // Twitter
        if (speaker.twitter != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildContactOption(
              const AssetImage('assets/icons/twitter.png'),
              'Twitter',
              onTap: () => _launchUrl(speaker.twitter!),
            ),
          ),

        // YouTube
        if (speaker.youtube != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildContactOption(
              const AssetImage('assets/icons/youtube.png'),
              'YouTube',
              onTap: () => _launchUrl(speaker.youtube!),
            ),
          ),
      ],
    );
  }

  // ==================== HELPER WIDGETS ====================
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

  Widget _buildSessionCard(SessionBySpeaker session) {
    final sessionTypeColor = _getSessionTypeColor(session.category);

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
                  text: session.title,
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

          // Session Description
          if (session.description.isNotEmpty)
            Column(
              children: [
                AppText(
                  text: session.description,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
            ),

          // Session Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Time
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: AppColors.darkgrey),
                  const SizedBox(width: 4),
                  Text(
                    session.formattedTime,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.darkgrey,
                    ),
                  ),
                ],
              ),

              // Duration
              Row(
                children: [
                  Text(
                    'Duration: ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    session.duration,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.darkgrey,
                    ),
                  ),
                ],
              ),

              // Room
              Row(
                children: [
                  Text(
                    'Room: ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    session.location,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.darkgrey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Session Type and Capacity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Session Type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sessionTypeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  session.category,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: sessionTypeColor,
                  ),
                ),
              ),

              // Capacity
              Text(
                'Capacity: ${session.capacity}',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.darkgrey,
                ),
              ),

              // Registration Required
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: session.registrationRequired ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  session.registrationRequired ? 'Registration Required' : 'Open',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: session.registrationRequired ? Colors.orange : Colors.green,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          CustomButton(
            text: 'View Session Details',
            onPressed: () {
              _navigateToSessionDetails(session.id);
            },
            backgroundColor: AppColors.primaryColor,
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(AssetImage image, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  Color _getRandomChipColor() {
    final colors = [AppColors.lightred, AppColors.lightPurpleColor];
    return colors[DateTime.now().millisecond % colors.length];
  }

  Color _getSessionTypeColor(String category) {
    switch (category.toLowerCase()) {
      case 'keynote':
        return Colors.blue;
      case 'workshop':
        return Colors.green;
      case 'panel':
        return Colors.orange;
      case 'breakout':
        return Colors.purple;
      default:
        return AppColors.primaryColor;
    }
  }

  void _navigateToSessionDetails(int sessionId) {
    print('=== Navigating to session details for ID: $sessionId ===');
    Get.to(() => SessionDetailsScreen(sessionId: sessionId));
  }
}