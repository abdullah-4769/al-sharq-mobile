import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

import '../add_new_speaker/add_new_speaker_view.dart';

class OrganizerManageSpeakersScreen extends StatefulWidget {
  const OrganizerManageSpeakersScreen({super.key});

  @override
  State<OrganizerManageSpeakersScreen> createState() => _OrganizerManageSpeakersScreenState();
}

class _OrganizerManageSpeakersScreenState extends State<OrganizerManageSpeakersScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<SpeakerData> speakers = [
    SpeakerData(
      name: 'Dr. Johnathan',
      title: 'Director of Regional Affairs',
      organization: 'Middle East Institute',
      description: 'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      status: 'Business',
      sessionCount: '3 Sessions',
      profileImage: '',
    ),
    SpeakerData(
      name: 'Sarah Johnson',
      title: 'VP Marketing',
      organization: 'Global Corp',
      description: 'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      status: 'Business',
      sessionCount: '3 Sessions',
      profileImage: '',
    ),
    SpeakerData(
      name: 'Michael Chen',
      title: 'Research Director',
      organization: 'AI Labs',
      description: 'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      status: 'Business',
      sessionCount: '3 Sessions',
      profileImage: '',
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
          text: 'Manage Speakers',
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
            padding: const EdgeInsets.symmetric(horizontal:8, vertical: 12),
            child: Row(
              children: [
                _buildStatChip('All', '24', Colors.blue, true),
                const SizedBox(width: 12),
                _buildStatChip('Speakers by Status', '5', Colors.green, false),
                const SizedBox(width: 12),
                _buildStatChip('Confirmed', '12', Colors.orange, false),
              ],
            ),
          ),

          // Add New Speaker Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Add New Speakers',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddNewSpeakerScreen()),
                );
              },
              backgroundColor: AppColors.primaryColor,
              height: 48,
            ),
          ),

          // Speakers Count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  text: '275 Speakers Showing',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
                GestureDetector(
                  onTap: () {},
                  child: const AppText(
                    text: 'View All',
                    fontSize: 14,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Speakers List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: speakers.length,
              itemBuilder: (context, index) {
                final speaker = speakers[index];
                return _buildSpeakerCard(speaker);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String count, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : AppColors.mediumGreyColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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

  Widget _buildSpeakerCard(SpeakerData speaker) {
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
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryColor,
                child: AppText(
                  text: speaker.name.split(' ').map((e) => e[0]).join(''),
                  fontSize: 16,
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
                      text: speaker.name,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      text: speaker.title,
                      fontSize: 13,
                      color: AppColors.darkgrey,
                    ),
                    AppText(
                      text: speaker.organization,
                      fontSize: 13,
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
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(
                      text: speaker.status,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(
                      text: speaker.sessionCount,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText(
            text: speaker.description,
            fontSize: 12,
            color: AppColors.darkgrey,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 16),

          CustomButton(
            text: 'View Details',
            onPressed: () {},

            textColor: AppColors.whiteColor,
            height: 36,
          ),
          const SizedBox(height: 16),
          Row(
            children: [

              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
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
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.darkgrey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const AppText(
                          text: 'Delete',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkgrey,
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class SpeakerData {
  final String name;
  final String title;
  final String organization;
  final String description;
  final String status;
  final String sessionCount;
  final String profileImage;

  SpeakerData({
    required this.name,
    required this.title,
    required this.organization,
    required this.description,
    required this.status,
    required this.sessionCount,
    required this.profileImage,
  });
}
