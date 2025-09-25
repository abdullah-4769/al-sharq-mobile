import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

class ManageParticipantsScreen extends StatefulWidget {
  const ManageParticipantsScreen({super.key});

  @override
  State<ManageParticipantsScreen> createState() => _ManageParticipantsScreenState();
}

class _ManageParticipantsScreenState extends State<ManageParticipantsScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<ParticipantData> participants = [
    ParticipantData(
      name: 'Dr. Johnathan',
      title: 'Director of Regional Affairs',
      email: 'johnathan@institute.com',
      status: 'Approved',
      statusColor: Colors.green,
    ),
    ParticipantData(
      name: 'Sarah Mitchell',
      title: 'Innovation Labs',
      email: 'sarah@global.com',
      status: 'Approved',
      statusColor: Colors.green,
    ),
    ParticipantData(
      name: 'Michael Chen',
      title: 'Data Analytics Team',
      email: 'michael@labs.com',
      status: 'Approved',
      statusColor: Colors.green,
    ),
    ParticipantData(
      name: 'Ava Robinson',
      title: 'User Experience Research',
      email: 'ava.robinson@global.com',
      status: 'Pending',
      statusColor: Colors.orange,
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
          text: 'Manage Participants',
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
                _buildStatChip('Registered', '1,785', Colors.blue, false),
                const SizedBox(width: 12),
                _buildStatChip('Checked In', '5', Colors.green, false),
                const SizedBox(width: 12),
                _buildStatChip('Pending', '45', Colors.red, false),
              ],
            ),
          ),

          // Export Report Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.file_download, color: AppColors.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        text: 'Export Report',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      const AppText(
                        text: 'Generate Report list',
                        fontSize: 12,
                        color: AppColors.darkgrey,
                      ),
                    ],
                  ),
                ),
                const AppText(
                  text: 'Download CSV',
                  fontSize: 12,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.primaryColor),
              ],
            ),
          ),

          // Networking Requests Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: 'Networking Requests',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      AppText(
                        text: 'Manage All Connection Requests',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Participants Count
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

          // Participants List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];
                return _buildParticipantCard(participant);
              },
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

  Widget _buildParticipantCard(ParticipantData participant) {
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
                radius: 25,
                backgroundColor: AppColors.primaryColor,
                child: AppText(
                  text: participant.name.split(' ').map((e) => e[0]).join(''),
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
                      text: participant.name,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      text: participant.title,
                      fontSize: 13,
                      color: AppColors.darkgrey,
                    ),
                    AppText(
                      text: participant.email,
                      fontSize: 13,
                      color: AppColors.darkgrey,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: participant.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  text: participant.status,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: participant.statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const AppText(
            text: 'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
            fontSize: 12,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const AppText(
                    text: 'View Details',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
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
                          text: 'Block',
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

class ParticipantData {
  final String name;
  final String title;
  final String email;
  final String status;
  final Color statusColor;

  ParticipantData({
    required this.name,
    required this.title,
    required this.email,
    required this.status,
    required this.statusColor,
  });
}