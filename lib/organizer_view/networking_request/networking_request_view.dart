import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';

class NetworkingRequestsScreen extends StatefulWidget {
  const NetworkingRequestsScreen({super.key});

  @override
  State<NetworkingRequestsScreen> createState() => _NetworkingRequestsScreenState();
}

class _NetworkingRequestsScreenState extends State<NetworkingRequestsScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<NetworkingRequest> requests = [
    NetworkingRequest(
      name: 'Dr. Johnathan',
      title: 'Director of Regional Affairs',
      organization: 'Middle East Institute',
      description: 'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      status: 'Pending',
      statusColor: Colors.orange,
    ),
    NetworkingRequest(
      name: 'Sarah Mitchell',
      title: 'Innovation Labs',
      organization: 'Global Corp',
      description: 'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      status: 'Approved',
      statusColor: Colors.green,
    ),
    NetworkingRequest(
      name: 'Michael Chen',
      title: 'Data Analytics Team',
      organization: 'AI Labs',
      description: 'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      status: 'Pending',
      statusColor: Colors.orange,
    ),
    NetworkingRequest(
      name: 'Ava Robinson',
      title: 'User Experience Research',
      organization: 'Global Corp',
      description: 'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
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
          text: 'Networking Requests',
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
                _buildStatChip('Users', '456', Colors.blue, false),
                const SizedBox(width: 12),
                _buildStatChip('Pending', '5', Colors.orange, false),
                const SizedBox(width: 12),
                _buildStatChip('Approved', '45', Colors.green, false),
              ],
            ),
          ),

          // View All Link
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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

          // Requests List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _buildRequestCard(request, index);
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

  Widget _buildRequestCard(NetworkingRequest request, int index) {
    bool isApproved = request.status == 'Approved';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
                        text: request.name.split(' ').map((e) => e[0]).join(''),
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
                            text: request.name,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            text: request.title,
                            fontSize: 13,
                            color: AppColors.darkgrey,
                          ),
                          AppText(
                            text: request.organization,
                            fontSize: 13,
                            color: AppColors.darkgrey,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: request.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppText(
                        text: request.status,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: request.statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppText(
                  text: request.description,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),

          if (isApproved) ...[
            // Approved section with arrow
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.darkgrey,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  const AppText(
                    text: 'Approved',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ] else ...[
            // Action buttons for pending requests
            Container(
              padding: const EdgeInsets.all(16),
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
                        text: 'View Details',
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

class NetworkingRequest {
  final String name;
  final String title;
  final String organization;
  final String description;
  final String status;
  final Color statusColor;

  NetworkingRequest({
    required this.name,
    required this.title,
    required this.organization,
    required this.description,
    required this.status,
    required this.statusColor,
  });
}