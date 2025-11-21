import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/view_model/participant_viewmodel/participant_chat_viewmodels/participant_chat_viewmodel.dart';
import 'package:al_sharq_conference/utils/shared_preference.dart';
import '../../../images/images.dart';
import '../../data/request_models/chats_model/participant_chat_model.dart';
import '../message_view/message_view.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController searchController = TextEditingController();
  final ParticipantChatViewModel chatViewModel = Get.find<ParticipantChatViewModel>();
  final RxList<ChatContact> _allChatContacts = <ChatContact>[].obs;
  final RxList<ChatContact> _filteredChatContacts = <ChatContact>[].obs;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupListeners();
  }

  void _setupListeners() {
    // Listen for connection updates
    ever(chatViewModel.connections, (List<ChatConnection> connections) {
      _updateChatContacts(connections);
    });

    // Listen for unread count updates
    ever(chatViewModel.unreadCounts, (Map<int, int> unreadCounts) {
      _updateUnreadCounts();
    });
  }

  Future<void> _loadUserData() async {
    currentUserId = await SharedPrefsHelper.getUserId();
    print('=== Current User ID: $currentUserId ===');
    setState(() {});
  }

  Future<void> _fetchAllConnections() async {
    try {
      print('=== Fetching connections... ===');
      await chatViewModel.fetchConnections();
      print('=== Connections fetched: ${chatViewModel.connections.length} ===');
    } catch (e) {
      print('=== Error fetching connections: $e ===');
    }
  }

  void _updateChatContacts(List<ChatConnection> connections) {
    print('=== Updating chat contacts with ${connections.length} connections ===');

    List<ChatContact> chatContacts = [];

    for (var connection in connections) {
      final unreadCount = chatViewModel.getUnreadCount(connection.user.id);

      print('=== Connection: ${connection.user.name} (ID: ${connection.user.id}), Unread: $unreadCount ===');

      chatContacts.add(ChatContact(
        id: connection.user.id.toString(),
        name: connection.user.name,
        lastMessage: _getLastMessageText(connection),
        timestamp: _formatConnectionTime(connection.connectedAt),
        unreadCount: unreadCount,
        isOnline: _isUserOnline(connection.connectedAt),
        avatar: _getUserAvatarUrl(connection.user),
        lastMessageTime: DateTime.parse(connection.connectedAt),
        connection: connection, // Store the full connection object
      ));
    }

    // Sort by connection time (most recent first)
    chatContacts.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    _allChatContacts.value = chatContacts;
    _filteredChatContacts.value = chatContacts;

    print('=== Final chat contacts: ${_allChatContacts.length} ===');
  }

  void _updateUnreadCounts() {
    print('=== Updating unread counts ===');
    for (int i = 0; i < _allChatContacts.length; i++) {
      final contact = _allChatContacts[i];
      final unreadCount = chatViewModel.getUnreadCount(int.parse(contact.id));

      if (contact.unreadCount != unreadCount) {
        _allChatContacts[i] = contact.copyWith(unreadCount: unreadCount);
      }
    }
    _filteredChatContacts.value = List.from(_allChatContacts);
  }

  String _getLastMessageText(ChatConnection connection) {
    // You can enhance this to show actual last message
    // For now, show connection status or default message
    return connection.unreadMessages > 0
        ? '${connection.unreadMessages} unread message${connection.unreadMessages > 1 ? 's' : ''}'
        : 'Tap to start chatting';
  }

  String _getUserAvatarUrl(ChatUser user) {
    if (user.displayImage != null && user.displayImage!.isNotEmpty) {
      return user.displayImage!;
    } else if (user.file != null && user.file!.isNotEmpty) {
      return user.file!;
    } else {
      return Images.drjohnthan; // Fallback to local asset
    }
  }

  bool _isUserOnline(String connectedAt) {
    try {
      final date = DateTime.parse(connectedAt).toLocal();
      final now = DateTime.now().toLocal();
      final difference = now.difference(date);
      // Consider online if connected within last 15 minutes
      return difference.inMinutes < 15;
    } catch (e) {
      return false;
    }
  }

  String _formatConnectionTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now().toLocal();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      _filteredChatContacts.value = _allChatContacts;
    } else {
      _filteredChatContacts.value = _allChatContacts.where((contact) =>
          contact.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
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
          text: 'Chat List',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchAllConnections,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightGreyColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: _filterContacts,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Connection Status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
              children: [
                AppText(
                  text: 'Connections: ${_allChatContacts.length}',
                  fontSize: 14,
                  color: Colors.grey[600]!,
                ),
                const Spacer(),
                if (chatViewModel.isLoading.value)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 0),
                  ),
              ],
            )),
          ),

          const SizedBox(height: 8),

          // Chat List
          Expanded(
            child: Obx(() {
              if (chatViewModel.isLoading.value && _allChatContacts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_filteredChatContacts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No connections found',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _allChatContacts.isEmpty
                            ? 'Connect with people to start chatting'
                            : 'No results for "${searchController.text}"',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      if (_allChatContacts.isEmpty) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchAllConnections,
                          child: const Text('Refresh'),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await _fetchAllConnections();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  itemCount: _filteredChatContacts.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                    indent: 80,
                  ),
                  itemBuilder: (context, index) {
                    final contact = _filteredChatContacts[index];
                    return _buildChatTile(contact);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(ChatContact contact) {
    return Obx(() {
      // Get real-time unread count
      final unreadCount = chatViewModel.getUnreadCount(int.parse(contact.id));

      print('=== Building tile for ${contact.name}: Unread count = $unreadCount ===');

      return Container(
        color: AppColors.whiteColor,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              // Check if we have a network image or fallback to asset
              if (contact.avatar.startsWith('http'))
              // Network image with error handling
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(contact.avatar),
                  onBackgroundImageError: (exception, stackTrace) {
                    print('=== Image load error for ${contact.name}: $exception ===');
                  },
                 // child: const Icon(Icons.person, color: Colors.white, size: 28),
                )
              else
              // For local assets, show person icon instead of drjohnthan image
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryColor, // Optional: add background color
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
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
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  text: contact.name,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppText(
                text: contact.timestamp,
                fontSize: 13,
                color: Colors.grey[600]!,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    text: contact.lastMessage,
                    fontSize: 14,
                    color: unreadCount > 0 ? Colors.black87 : Colors.grey[600]!,
                    fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: AppText(
                        text: unreadCount > 99 ? '99+' : unreadCount.toString(),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          onTap: () => _navigateToChat(contact),
        ),
      );
    });
  }

  void _navigateToChat(ChatContact contact) {
    print('=== Navigating to chat with ${contact.name} (ID: ${contact.id}) ===');

    // Find the connection
    final connection = chatViewModel.connections.firstWhere(
          (conn) => conn.user.id.toString() == contact.id,
    );

    // Select the user
    chatViewModel.selectUser(connection.user);

    // Navigate to chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MessagesScreen(),
      ),
    ).then((_) {
      // Refresh when returning
      _fetchAllConnections();
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
  final DateTime lastMessageTime;
  final ChatConnection? connection;

  ChatContact({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
    required this.avatar,
    required this.lastMessageTime,
    this.connection,
  });

  ChatContact copyWith({
    String? id,
    String? name,
    String? lastMessage,
    String? timestamp,
    int? unreadCount,
    bool? isOnline,
    String? avatar,
    DateTime? lastMessageTime,
    ChatConnection? connection,
  }) {
    return ChatContact(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      avatar: avatar ?? this.avatar,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      connection: connection ?? this.connection,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:al_sharq_conference/app_colors/app_colors.dart';
// import 'package:al_sharq_conference/custom_widgets/app_text.dart';
// import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
// import 'package:al_sharq_conference/view_model/participant_viewmodel/participant_chat_viewmodels/participant_chat_viewmodel.dart';
// import '../../../images/images.dart';
// import '../../data/request_models/chats_model/participant_chat_model.dart';
// import '../message_view/message_view.dart';
//
// class ChatListScreen extends StatefulWidget {
//   const ChatListScreen({super.key});
//
//   @override
//   State<ChatListScreen> createState() => _ChatListScreenState();
// }
//
// class _ChatListScreenState extends State<ChatListScreen> {
//   final TextEditingController searchController = TextEditingController();
//   final ParticipantChatViewModel chatViewModel = Get.find<ParticipantChatViewModel>();
//
//   @override
//   void initState() {
//     super.initState();
//     // Fetch connections when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       chatViewModel.fetchConnections();
//     });
//   }
//
//   // Get all chat contacts from the real API connections
//   List<ChatContact> get allChatContacts {
//     final connections = chatViewModel.connections;
//
//     // If no connections from API, show empty list
//     if (connections.isEmpty) {
//       return [];
//     }
//
//     return connections.map((connection) {
//       final user = connection.user;
//       final unreadCount = chatViewModel.getUnreadCount(user.id);
//
//       return ChatContact(
//         id: user.id.toString(),
//         name: user.name,
//         lastMessage: 'Tap to start chatting', // Default message
//         timestamp: _formatConnectionTime(connection.connectedAt),
//         unreadCount: unreadCount,
//         isOnline: _isUserOnline(connection.connectedAt), // Simple online check
//         avatar: _getUserAvatarUrl(user),
//       );
//     }).toList();
//   }
//
//   String _getUserAvatarUrl(ChatUser user) {
//     if (user.displayImage != null && user.displayImage!.isNotEmpty) {
//       return user.displayImage!;
//     } else if (user.file != null && user.file!.isNotEmpty) {
//       return user.file!;
//     } else {
//       // Fallback to your local image
//       return Images.drjohnthan;
//     }
//   }
//
//   bool _isUserOnline(String connectedAt) {
//     try {
//       final date = DateTime.parse(connectedAt);
//       final now = DateTime.now();
//       final difference = now.difference(date);
//       // Consider user online if connected within last 10 minutes
//       return difference.inMinutes < 10;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   String _formatConnectionTime(String connectedAt) {
//     try {
//       final date = DateTime.parse(connectedAt);
//       final now = DateTime.now();
//       final difference = now.difference(date);
//
//       if (difference.inMinutes < 1) {
//         return 'Just now';
//       } else if (difference.inMinutes < 60) {
//         return '${difference.inMinutes}m ago';
//       } else if (difference.inHours < 24) {
//         return '${difference.inHours}h ago';
//       } else if (difference.inDays < 7) {
//         return '${difference.inDays}d ago';
//       } else {
//         return '${date.day}/${date.month}/${date.year}';
//       }
//     } catch (e) {
//       return 'Recently';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightGreyColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.whiteColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const AppText(
//           text: 'Messages',
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add_comment, color: AppColors.primaryColor),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Container(
//             color: AppColors.whiteColor,
//             padding: const EdgeInsets.all(16),
//             child: CustomTextField(
//               hintText: 'Search messages',
//               controller: searchController,
//               suffixIcon: Icons.search,
//               suffixIconColor: Colors.grey[600],
//             ),
//           ),
//
//           // Online Users Section
//           Container(
//             height: 100,
//             color: AppColors.whiteColor,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: AppText(
//                     text: 'Online Now',
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Expanded(
//                   child: Obx(() {
//                     final onlineContacts = allChatContacts.where((contact) => contact.isOnline).toList();
//
//                     return onlineContacts.isEmpty
//                         ? Center(
//                       child: AppText(
//                         text: 'No online users',
//                         fontSize: 12,
//                         color: AppColors.darkgrey,
//                       ),
//                     )
//                         : ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: onlineContacts.length,
//                       itemBuilder: (context, index) {
//                         final contact = onlineContacts[index];
//                         return GestureDetector(
//                           onTap: () => _navigateToChat(contact),
//                           child: Container(
//                             width: 60,
//                             margin: const EdgeInsets.only(right: 12),
//                             child: Column(
//                               children: [
//                                 Stack(
//                                   children: [
//                                     CircleAvatar(
//                                       radius: 20,
//                                       backgroundImage: AssetImage(contact.avatar),
//                                     ),
//                                     Positioned(
//                                       bottom: 0,
//                                       right: 0,
//                                       child: Container(
//                                         width: 12,
//                                         height: 12,
//                                         decoration: BoxDecoration(
//                                           color: Colors.green,
//                                           shape: BoxShape.circle,
//                                           border: Border.all(color: Colors.white, width: 2),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 AppText(
//                                   text: contact.name.split(' ')[0],
//                                   fontSize: 10,
//                                   color: Colors.black,
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   }),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           // Chat List
//           Expanded(
//             child: Obx(() {
//               if (chatViewModel.isLoading.value && allChatContacts.isEmpty) {
//                 return Center(child: CircularProgressIndicator());
//               }
//
//               if (allChatContacts.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
//                       SizedBox(height: 16),
//                       Text(
//                         'No chat conversations yet',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         'Connect with people in the Networking tab to start chatting',
//                         style: TextStyle(color: Colors.grey, fontSize: 12),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               return RefreshIndicator(
//                 onRefresh: () async {
//                   await chatViewModel.fetchConnections();
//                 },
//                 child: ListView.builder(
//                   itemCount: allChatContacts.length,
//                   itemBuilder: (context, index) {
//                     final contact = allChatContacts[index];
//                     return _buildChatTile(contact);
//                   },
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildChatTile(ChatContact contact) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       decoration: BoxDecoration(
//         color: AppColors.whiteColor,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(12),
//         leading: Stack(
//           children: [
//             CircleAvatar(
//               radius: 24,
//               backgroundImage: AssetImage(contact.avatar),
//             ),
//             if (contact.isOnline)
//               Positioned(
//                 bottom: 0,
//                 right: 0,
//                 child: Container(
//                   width: 14,
//                   height: 14,
//                   decoration: BoxDecoration(
//                     color: Colors.green,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             AppText(
//               text: contact.name,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//             AppText(
//               text: contact.timestamp,
//               fontSize: 12,
//               color: AppColors.darkgrey,
//             ),
//           ],
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Row(
//             children: [
//               Expanded(
//                 child: AppText(
//                   text: contact.lastMessage,
//                   fontSize: 14,
//                   color: AppColors.darkgrey,
//                 ),
//               ),
//               if (contact.unreadCount > 0)
//                 Container(
//                   margin: const EdgeInsets.only(left: 8),
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColors.primaryColor,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: AppText(
//                     text: contact.unreadCount.toString(),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         onTap: () => _navigateToChat(contact),
//       ),
//     );
//   }
//
//   void _navigateToChat(ChatContact contact) {
//     // Find the corresponding ChatUser from connections
//     final connection = chatViewModel.connections.firstWhere(
//           (conn) => conn.user.id.toString() == contact.id,
//       orElse: () => ChatConnection(
//         connectionId: 0,
//         user: ChatUser(
//           id: int.parse(contact.id),
//           name: contact.name,
//           email: '',
//           role: '',
//           displayImage: contact.avatar,
//         ),
//         connectedAt: '',
//         unreadMessages: 0,
//       ),
//     );
//
//     // Select the user in chat viewmodel
//     chatViewModel.selectUser(connection.user);
//
//     // Navigate to MessagesScreen (the real API-based chat screen)
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MessagesScreen(),
//       ),
//     ).then((_) {
//       // Refresh chat list when coming back
//       chatViewModel.fetchConnections();
//     });
//   }
//
//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }
// }
//
// class ChatContact {
//   final String id;
//   final String name;
//   final String lastMessage;
//   final String timestamp;
//   final int unreadCount;
//   final bool isOnline;
//   final String avatar;
//
//   ChatContact({
//     required this.id,
//     required this.name,
//     required this.lastMessage,
//     required this.timestamp,
//     required this.unreadCount,
//     required this.isOnline,
//     required this.avatar,
//   });
// }