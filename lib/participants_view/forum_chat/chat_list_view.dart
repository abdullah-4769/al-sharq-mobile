import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import '../../../images/images.dart';
import '../networking_view/networking_view.dart';
import 'forum_chat.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController searchController = TextEditingController();

  // Default chat contacts (existing ones)
  List<ChatContact> _defaultChatContacts = [
    ChatContact(
      id: '1',
      name: 'Dr. Johnathan',
      lastMessage: 'Great question! From my experience...',
      timestamp: '2 min ago',
      unreadCount: 2,
      isOnline: true,
      avatar: Images.drjohnthan,
    ),
    ChatContact(
      id: '2',
      name: 'Sarah Mitchell',
      lastMessage: 'I agree with your analysis on AI trends',
      timestamp: '5 min ago',
      unreadCount: 0,
      isOnline: true,
      avatar: Images.drjohnthan,
    ),
    ChatContact(
      id: '3',
      name: 'Ahmed Al-Rashid',
      lastMessage: 'Thanks for sharing the presentation',
      timestamp: '1 hour ago',
      unreadCount: 1,
      isOnline: false,
      avatar: Images.drjohnthan,
    ),
    ChatContact(
      id: '4',
      name: 'Layla Hassan',
      lastMessage: 'The talent shortage is real! We\'ve been...',
      timestamp: '2 hours ago',
      unreadCount: 0,
      isOnline: true,
      avatar: Images.drjohnthan,
    ),
    ChatContact(
      id: '5',
      name: 'Michael Chen',
      lastMessage: 'Looking forward to our collaboration',
      timestamp: 'Yesterday',
      unreadCount: 0,
      isOnline: false,
      avatar: Images.drjohnthan,
    ),
    ChatContact(
      id: '6',
      name: 'Prof. Omar Khalid',
      lastMessage: 'The session was very insightful',
      timestamp: 'Yesterday',
      unreadCount: 3,
      isOnline: false,
      avatar: Images.drjohnthan,
    ),
  ];

  List<ChatContact> get allChatContacts {
    // Get chats from ChatManager
    final managerChats = ChatManager().chatContacts;

    // Combine with default chats, avoiding duplicates
    final combinedChats = <String, ChatContact>{};

    // Add default chats first
    for (final chat in _defaultChatContacts) {
      combinedChats[chat.name] = chat;
    }

    // Add or update with manager chats
    for (final chat in managerChats) {
      combinedChats[chat.name] = chat;
    }

    // Return as sorted list (newest first)
    final result = combinedChats.values.toList();
    result.sort((a, b) {
      // Put "Just now" and recent chats first
      if (a.timestamp == 'Just now') return -1;
      if (b.timestamp == 'Just now') return 1;
      return 0; // Keep original order for others
    });

    return result;
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
          text: 'Messages',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment, color: AppColors.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              hintText: 'Search messages',
              controller: searchController,
              suffixIcon: Icons.search,
              suffixIconColor: Colors.grey[600],
            ),
          ),

          // Online Users Section
          Container(
            height: 100,
            color: AppColors.whiteColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: AppText(
                    text: 'Online Now',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: allChatContacts.where((contact) => contact.isOnline).length,
                    itemBuilder: (context, index) {
                      final onlineContacts = allChatContacts.where((contact) => contact.isOnline).toList();
                      final contact = onlineContacts[index];
                      return GestureDetector(
                        onTap: () => _navigateToChat(contact),
                        child: Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: AssetImage(contact.avatar),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                text: contact.name.split(' ')[0],
                                fontSize: 10,
                                color: Colors.black,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Chat List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {}); // Refresh the list
              },
              child: ListView.builder(
                itemCount: allChatContacts.length,
                itemBuilder: (context, index) {
                  final contact = allChatContacts[index];
                  return _buildChatTile(contact);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(ChatContact contact) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(contact.avatar),
            ),
            if (contact.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: contact.name,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            AppText(
              text: contact.timestamp,
              fontSize: 12,
              color: AppColors.darkgrey,
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  text: contact.lastMessage,
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
              ),
              if (contact.unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText(
                    text: contact.unreadCount.toString(),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
        onTap: () => _navigateToChat(contact),
      ),
    );
  }

  void _navigateToChat(ChatContact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IndividualChatScreen(contact: contact),
      ),
    ).then((_) {
      // Refresh chat list when coming back
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class ChatContact {
  final String id;
  final String name;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isOnline;
  final String avatar;

  ChatContact({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
    required this.avatar,
  });
}