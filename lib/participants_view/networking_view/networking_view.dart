import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/participants_view/forum_chat/chat_list_view.dart';
import 'package:al_sharq_conference/participants_view/forum_chat/forum_chat.dart';
import 'package:al_sharq_conference/participants_view/message_view/message_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../../images/images.dart';

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

// Chat Manager to handle global chat state
class ChatManager {
  static final ChatManager _instance = ChatManager._internal();
  factory ChatManager() => _instance;
  ChatManager._internal();

  List<ChatContact> _chatContacts = [];
  List<ChatContact> get chatContacts => _chatContacts;

  void addOrUpdateChat(Person person) {
    final existingIndex = _chatContacts.indexWhere((contact) => contact.name == person.name);

    if (existingIndex != -1) {
      // Update existing chat
      _chatContacts[existingIndex] = _chatContacts[existingIndex].copyWith(
        lastMessage: 'Started chatting',
        timestamp: 'Just now',
        isOnline: true,
      );
    } else {
      // Add new chat
      _chatContacts.insert(0, ChatContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: person.name,
        lastMessage: 'Started chatting',
        timestamp: 'Just now',
        unreadCount: 0,
        isOnline: true,
        avatar: Images.drjohnthan,
      ));
    }
  }

  ChatContact? getChatContact(String personName) {
    try {
      return _chatContacts.firstWhere((contact) => contact.name == personName);
    } catch (e) {
      return null;
    }
  }
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
        elevation: 0,
        title: AppText(
          text: 'Networking',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
        ),

      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: CustomTextField(
                    hintText: "Search",
                    controller: _searchController,
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
          // Chat List Banner
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatListScreen()),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  Expanded(
                    child: AppText(
                      text: 'Chats List',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.darkgrey,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8),

          // Custom Tab Bar with better design
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.lightGreyColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _tabController.animateTo(0);
                      setState(() {});
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: _tabController.index == 0
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: AppText(
                          text: 'Directory',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _tabController.index == 0
                              ? AppColors.whiteColor
                              : AppColors.darkgrey,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _tabController.animateTo(1);
                      setState(() {});
                    },
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: _tabController.index == 1
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: AppText(
                          text: 'My Connections',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _tabController.index == 1
                              ? AppColors.whiteColor
                              : AppColors.darkgrey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Speaker Count
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppText(
              text: '275 Speakers Showing',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
          ),

          SizedBox(height: 8),

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

  void _startChat(Person person) {
    // Add/Update chat in ChatManager
    ChatManager().addOrUpdateChat(person);

    // Get or create chat contact
    ChatContact? contact = ChatManager().getChatContact(person.name);

    if (contact == null) {
      // Create new contact if doesn't exist
      contact = ChatContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: person.name,
        lastMessage: 'Started chatting',
        timestamp: 'Just now',
        unreadCount: 0,
        isOnline: true,
        avatar: Images.drjohnthan,
      );
    }

    // Navigate to individual chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IndividualChatScreen(contact: contact!),
      ),
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
            blurRadius: 8,
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
                onPressed: () => _startChat(person),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  elevation: 0,
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
        return Container();
    }
  }
}

// Extension to add copyWith method to ChatContact
extension ChatContactExtension on ChatContact {
  ChatContact copyWith({
    String? id,
    String? name,
    String? lastMessage,
    String? timestamp,
    int? unreadCount,
    bool? isOnline,
    String? avatar,
  }) {
    return ChatContact(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      avatar: avatar ?? this.avatar,
    );
  }
}