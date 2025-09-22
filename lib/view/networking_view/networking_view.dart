import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/view/message_view/message_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_text_field.dart';

// Person class definition
class Person {
  final String name;
  final String title;
  final String organization;
  final String description;
  final String imageUrl;
  final String status;

  Person({
    required this.name,
    required this.title,
    required this.organization,
    required this.description,
    required this.imageUrl,
    required this.status,
  });
}

// Main Networking Screen
class NetworkingScreen extends StatefulWidget {
  @override
  _NetworkingScreenState createState() => _NetworkingScreenState();
}

class _NetworkingScreenState extends State<NetworkingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();

  // Sample data
  final List<Person> directoryPeople = [
    Person(
      name: 'Dr. Johnathan',
      title: 'Director of Regional Affairs',
      organization: 'Middle East Institute',
      description:
      'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
      status: 'connected',
    ),
    Person(
      name: 'Sarah Johnson',
      title: 'VP Marketing',
      organization: 'Global Corp',
      description:
      'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      imageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b13a',
      status: 'connect',
    ),
    Person(
      name: 'Michael Chen',
      title: 'Research Director',
      organization: 'AI Labs',
      description:
      'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      imageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e',
      status: 'pending',
    ),
  ];

  final List<Person> connectedPeople = [
    Person(
      name: 'Dr. Johnathan',
      title: 'Director of Regional Affairs',
      organization: 'Middle East Institute',
      description:
      'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
      status: 'connected',
    ),
    Person(
      name: 'Sarah Johnson',
      title: 'VP Marketing',
      organization: 'Global Corp',
      description:
      'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      imageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b13a',
      status: 'connected',
    ),
    Person(
      name: 'Michael Chen',
      title: 'Research Director',
      organization: 'AI Labs',
      description:
      'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      imageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e',
      status: 'connected',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,

        title: AppText(
          text: 'Networking',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.tune, color: AppColors.primaryColor),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.whiteColor,
            padding: EdgeInsets.all(16),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Search...',
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ),

          // Chat List Banner
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightred,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chat,
                    color: AppColors.whiteColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                AppText(
                  text: 'Chats List',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: AppColors.whiteColor,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.whiteColor,
              unselectedLabelColor: AppColors.darkgrey,
              indicator: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'Directory'),
                Tab(text: 'My Connections'),
              ],
            ),
          ),

          // Speaker Count
          Container(
            width: double.infinity,
            color: AppColors.whiteColor,
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: AppText(
              text: '275 Speakers Showing',
              fontSize: 14,
              color: AppColors.darkgrey,
            ),
          ),

          // Tab View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDirectoryTab(),
                _buildConnectionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: directoryPeople.length,
      itemBuilder: (context, index) {
        return _buildPersonCard(directoryPeople[index]);
      },
    );
  }

  Widget _buildConnectionsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: connectedPeople.length,
      itemBuilder: (context, index) {
        return _buildPersonCard(connectedPeople[index]);
      },
    );
  }

  Widget _buildPersonCard(Person person) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(person.imageUrl),
              ),
              SizedBox(width: 12),
              // Person Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: person.name,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                    SizedBox(height: 2),
                    AppText(
                      text: person.title,
                      fontSize: 14,
                      color: AppColors.darkgrey,
                    ),
                    AppText(
                      text: person.organization,
                      fontSize: 14,
                      color: AppColors.darkgrey,
                    ),
                  ],
                ),
              ),
              // Connection Button
              _buildConnectionButton(person.status),
            ],
          ),
          SizedBox(height: 12),
          // Description
          AppText(
            text: person.description,
            fontSize: 12,
            color: AppColors.darkgrey,
          ),
          // Chat Button (only for connected users)
          if (person.status == 'connected') ...[
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(MessagesScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.whiteColor,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    AppText(
                      text: 'Chat with ${person.name.split(' ').first}',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionButton(String status) {
    switch (status) {
      case 'connect':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: AppText(
            text: 'Connect',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryColor,
          ),
        );
      case 'connected':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AppText(
            text: 'Connected',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ),
        );
      case 'pending':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AppText(
            text: 'Pending',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.whiteColor,
          ),
        );
      default:
        return Container(); // Default case for safety
    }
  }
}