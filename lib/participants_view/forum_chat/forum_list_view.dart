import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/participants_view/create_new_topic_view/create_new_topic_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_text_field.dart';

class ForumsListScreen extends StatelessWidget {
   ForumsListScreen({super.key});
TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        title:  AppText(
          text:
          'Forums',

            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,

        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:   Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: CustomTextField(
                      hintText: "Search",
                      controller: searchController,
                      suffixIcon: Icons.search,
                    ),
                  ),
                  SizedBox(width: 10),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Get.to(CreateNewTopicScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const AppText(
                  text:
                  'Create New Topic',

                      color: Colors.white, fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text:
                    'Trending Topics',

                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,

                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(text: 'Networking'),
                      AppText(text: 'Innovation'),
                      AppText(text: 'Networking'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(text: 'Stability'),
                      AppText(text: 'Business'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Featured Discussions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailedForumCard(
                    'Future of Regional Cooperation',
                    'Discuss strategies for regional partnerships and collaborative initiatives.',
                    245,
                    120,
                    'Dr. Johnathan',
                  ),
                  _buildDetailedForumCard(
                    'Innovations in Technology',
                    'Explore cutting-edge technologies impacting various sectors.',
                    300,
                    200,
                    'Dr. Emily',
                  ),
                  _buildDetailedForumCard(
                    'Sustainable Practices',
                    'Hands-on session on implementing sustainability in business and communities.',
                    350,
                    75,
                    'Mr. Alex',
                  ),
                  _buildDetailedForumCard(
                    'Economic Recovery Post-COVID',
                    'Discuss policies and strategies for economic growth.',
                    200,
                    50,
                    'Ms. Sarah',
                  ),
                  _buildDetailedForumCard(
                    'Connecting Local Entrepreneurs',
                    'Facilitate networking among small business owners.',
                    100,
                    30,
                    'Mr. David',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForumCard(String title, Color color, String? badge, int members, int posts) {
    return Expanded(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

    );
  }

  Widget _buildDetailedForumCard(String title, String description, int members, int posts, String creator) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$members Members', style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$posts Posts', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Created By: $creator', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                minimumSize: const Size(double.infinity, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Join Forum',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}