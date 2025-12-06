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
  bool _initialLoading = true;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _initialLoading = true;
    _loadUserData();
  }

  void _setupListeners() {
    // Listen for connection updates
    ever(chatViewModel.connections, (List<ChatConnection> connections) {
      _updateChatContacts(connections);
      if (_initialLoading) {
        _initialLoading = false;
      }
      _hasLoadedOnce = true;
    });

    // Listen for unread count updates
    ever(chatViewModel.unreadCounts, (Map<int, int> unreadCounts) {
      _updateUnreadCounts();
    });

    // Listen for loading state changes
    ever(chatViewModel.isLoading, (bool isLoading) {
      if (!isLoading && !_hasLoadedOnce) {
        _hasLoadedOnce = true;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      currentUserId = await SharedPrefsHelper.getUserId();
      print('=== Current User ID: $currentUserId ===');

      // Setup listeners after getting user ID
      _setupListeners();

      // Fetch connections immediately
      await _fetchAllConnections();

      // If still loading after 2 seconds, show loading
      Future.delayed(Duration(seconds: 2), () {
        if (_initialLoading && mounted) {
          setState(() {
            _initialLoading = false;
          });
        }
      });
    } catch (e) {
      print('=== Error loading user data: $e ===');
      if (mounted) {
        setState(() {
          _initialLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAllConnections() async {
    try {
      print('=== Fetching connections... ===');
      await chatViewModel.fetchConnections();
      print('=== Connections fetched: ${chatViewModel.connections.length} ===');
    } catch (e) {
      print('=== Error fetching connections: $e ===');
      // Show error but stop loading
      if (mounted) {
        setState(() {
          _initialLoading = false;
        });
      }
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
        connection: connection,
      ));
    }

    // Sort by connection time (most recent first)
    chatContacts.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    _allChatContacts.value = chatContacts;
    _filteredChatContacts.value = chatContacts;

    print('=== Final chat contacts: ${_allChatContacts.length} ===');

    // Stop initial loading
    if (_initialLoading) {
      _initialLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
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

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
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
            child: Row(
              children: [
                Obx(() => AppText(
                  text: 'Connections: ${_allChatContacts.length}',
                  fontSize: 14,
                  color: Colors.grey[600]!,
                )),
                const Spacer(),
                if (_initialLoading || chatViewModel.isLoading.value)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Chat List
          Expanded(
            child: _buildChatList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    // Show loading indicator for initial load
    if (_initialLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading conversations...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    // After initial load, show actual content
    return Obx(() {
      // Show loading indicator when refreshing
      if (chatViewModel.isLoading.value && _allChatContacts.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      // Check if we have any connections
      final hasConnections = chatViewModel.connections.isNotEmpty;
      final hasFilteredContacts = _filteredChatContacts.isNotEmpty;

      // If no connections at all
      if (!hasConnections && _hasLoadedOnce) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No connections yet',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect with people in Networking tab',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchAllConnections,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Text('Refresh', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      // If search returns no results
      if (hasConnections && !hasFilteredContacts) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  searchController.clear();
                  _filterContacts('');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Text('Clear Search', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      // Show the actual list of contacts
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
    });
  }

  Widget _buildChatTile(ChatContact contact) {
    return Obx(() {
      // Get real-time unread count
      final unreadCount = chatViewModel.getUnreadCount(int.parse(contact.id));

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
                )
              else
              // For local assets, show person icon instead of drjohnthan image
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryColor,
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
// import 'package:al_sharq_conference/view_model/participant_viewmodel/participant_chat_viewmodels/participant_chat_viewmodel.dart';
// import 'package:al_sharq_conference/utils/shared_preference.dart';
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
//   final RxList<ChatContact> _allChatContacts = <ChatContact>[].obs;
//   final RxList<ChatContact> _filteredChatContacts = <ChatContact>[].obs;
//   int? currentUserId;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//     _setupListeners();
//   }
//
//   void _setupListeners() {
//     // Listen for connection updates
//     ever(chatViewModel.connections, (List<ChatConnection> connections) {
//       _updateChatContacts(connections);
//     });
//
//     // Listen for unread count updates
//     ever(chatViewModel.unreadCounts, (Map<int, int> unreadCounts) {
//       _updateUnreadCounts();
//     });
//   }
//
//   Future<void> _loadUserData() async {
//     currentUserId = await SharedPrefsHelper.getUserId();
//     print('=== Current User ID: $currentUserId ===');
//     setState(() {});
//   }
//
//   Future<void> _fetchAllConnections() async {
//     try {
//       print('=== Fetching connections... ===');
//       await chatViewModel.fetchConnections();
//       print('=== Connections fetched: ${chatViewModel.connections.length} ===');
//     } catch (e) {
//       print('=== Error fetching connections: $e ===');
//     }
//   }
//
//   void _updateChatContacts(List<ChatConnection> connections) {
//     print('=== Updating chat contacts with ${connections.length} connections ===');
//
//     List<ChatContact> chatContacts = [];
//
//     for (var connection in connections) {
//       final unreadCount = chatViewModel.getUnreadCount(connection.user.id);
//
//       print('=== Connection: ${connection.user.name} (ID: ${connection.user.id}), Unread: $unreadCount ===');
//
//       chatContacts.add(ChatContact(
//         id: connection.user.id.toString(),
//         name: connection.user.name,
//         lastMessage: _getLastMessageText(connection),
//         timestamp: _formatConnectionTime(connection.connectedAt),
//         unreadCount: unreadCount,
//         isOnline: _isUserOnline(connection.connectedAt),
//         avatar: _getUserAvatarUrl(connection.user),
//         lastMessageTime: DateTime.parse(connection.connectedAt),
//         connection: connection, // Store the full connection object
//       ));
//     }
//
//     // Sort by connection time (most recent first)
//     chatContacts.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
//
//     _allChatContacts.value = chatContacts;
//     _filteredChatContacts.value = chatContacts;
//
//     print('=== Final chat contacts: ${_allChatContacts.length} ===');
//   }
//
//   void _updateUnreadCounts() {
//     print('=== Updating unread counts ===');
//     for (int i = 0; i < _allChatContacts.length; i++) {
//       final contact = _allChatContacts[i];
//       final unreadCount = chatViewModel.getUnreadCount(int.parse(contact.id));
//
//       if (contact.unreadCount != unreadCount) {
//         _allChatContacts[i] = contact.copyWith(unreadCount: unreadCount);
//       }
//     }
//     _filteredChatContacts.value = List.from(_allChatContacts);
//   }
//
//   String _getLastMessageText(ChatConnection connection) {
//     // You can enhance this to show actual last message
//     // For now, show connection status or default message
//     return connection.unreadMessages > 0
//         ? '${connection.unreadMessages} unread message${connection.unreadMessages > 1 ? 's' : ''}'
//         : 'Tap to start chatting';
//   }
//
//   String _getUserAvatarUrl(ChatUser user) {
//     if (user.displayImage != null && user.displayImage!.isNotEmpty) {
//       return user.displayImage!;
//     } else if (user.file != null && user.file!.isNotEmpty) {
//       return user.file!;
//     } else {
//       return Images.drjohnthan; // Fallback to local asset
//     }
//   }
//
//   bool _isUserOnline(String connectedAt) {
//     try {
//       final date = DateTime.parse(connectedAt).toLocal();
//       final now = DateTime.now().toLocal();
//       final difference = now.difference(date);
//       // Consider online if connected within last 15 minutes
//       return difference.inMinutes < 15;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   String _formatConnectionTime(String timestamp) {
//     try {
//       final date = DateTime.parse(timestamp).toLocal();
//       final now = DateTime.now().toLocal();
//       final difference = now.difference(date);
//
//       if (difference.inMinutes < 60) {
//         return '${difference.inMinutes}m ago';
//       } else if (difference.inHours < 24) {
//         return '${difference.inHours}h ago';
//       } else if (difference.inDays == 1) {
//         return 'Yesterday';
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
//   void _filterContacts(String query) {
//     if (query.isEmpty) {
//       _filteredChatContacts.value = _allChatContacts;
//     } else {
//       _filteredChatContacts.value = _allChatContacts.where((contact) =>
//           contact.name.toLowerCase().contains(query.toLowerCase())
//       ).toList();
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
//           text: 'Chat List',
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//         ),
//         centerTitle: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.black),
//             onPressed: _fetchAllConnections,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Container(
//             color: AppColors.whiteColor,
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: AppColors.lightGreyColor,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: TextField(
//                 controller: searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search',
//                   hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
//                   prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 22),
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                 ),
//                 onChanged: _filterContacts,
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 8),
//
//           // Connection Status
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Obx(() => Row(
//               children: [
//                 AppText(
//                   text: 'Connections: ${_allChatContacts.length}',
//                   fontSize: 14,
//                   color: Colors.grey[600]!,
//                 ),
//                 const Spacer(),
//                 if (chatViewModel.isLoading.value)
//                   const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(strokeWidth: 0),
//                   ),
//               ],
//             )),
//           ),
//
//           const SizedBox(height: 8),
//
//           // Chat List
//           Expanded(
//             child: Obx(() {
//               if (chatViewModel.isLoading.value && _allChatContacts.isEmpty) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (_filteredChatContacts.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
//                       const SizedBox(height: 16),
//                       Text(
//                         'No connections found',
//                         style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _allChatContacts.isEmpty
//                             ? 'Connect with people to start chatting'
//                             : 'No results for "${searchController.text}"',
//                         style: TextStyle(color: Colors.grey[500], fontSize: 14),
//                         textAlign: TextAlign.center,
//                       ),
//                       if (_allChatContacts.isEmpty) ...[
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _fetchAllConnections,
//                           child: const Text('Refresh'),
//                         ),
//                       ],
//                     ],
//                   ),
//                 );
//               }
//
//               return RefreshIndicator(
//                 onRefresh: () async {
//                   await _fetchAllConnections();
//                 },
//                 child: ListView.separated(
//                   padding: const EdgeInsets.symmetric(horizontal: 0),
//                   itemCount: _filteredChatContacts.length,
//                   separatorBuilder: (context, index) => Divider(
//                     height: 1,
//                     color: Colors.grey[200],
//                     indent: 80,
//                   ),
//                   itemBuilder: (context, index) {
//                     final contact = _filteredChatContacts[index];
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
//     return Obx(() {
//       // Get real-time unread count
//       final unreadCount = chatViewModel.getUnreadCount(int.parse(contact.id));
//
//       print('=== Building tile for ${contact.name}: Unread count = $unreadCount ===');
//
//       return Container(
//         color: AppColors.whiteColor,
//         child: ListTile(
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           leading: Stack(
//             children: [
//               // Check if we have a network image or fallback to asset
//               if (contact.avatar.startsWith('http'))
//               // Network image with error handling
//                 CircleAvatar(
//                   radius: 28,
//                   backgroundImage: NetworkImage(contact.avatar),
//                   onBackgroundImageError: (exception, stackTrace) {
//                     print('=== Image load error for ${contact.name}: $exception ===');
//                   },
//                  // child: const Icon(Icons.person, color: Colors.white, size: 28),
//                 )
//               else
//               // For local assets, show person icon instead of drjohnthan image
//                 CircleAvatar(
//                   radius: 28,
//                   backgroundColor: AppColors.primaryColor, // Optional: add background color
//                   child: const Icon(Icons.person, color: Colors.white, size: 28),
//                 ),
//               if (contact.isOnline)
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: Container(
//                     width: 14,
//                     height: 14,
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 2.5),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: AppText(
//                   text: contact.name,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               AppText(
//                 text: contact.timestamp,
//                 fontSize: 13,
//                 color: Colors.grey[600]!,
//               ),
//             ],
//           ),
//           subtitle: Padding(
//             padding: const EdgeInsets.only(top: 6),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: AppText(
//                     text: contact.lastMessage,
//                     fontSize: 14,
//                     color: unreadCount > 0 ? Colors.black87 : Colors.grey[600]!,
//                     fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 if (unreadCount > 0)
//                   Container(
//                     margin: const EdgeInsets.only(left: 8),
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryColor,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     constraints: const BoxConstraints(
//                       minWidth: 20,
//                       minHeight: 20,
//                     ),
//                     child: Center(
//                       child: AppText(
//                         text: unreadCount > 99 ? '99+' : unreadCount.toString(),
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           onTap: () => _navigateToChat(contact),
//         ),
//       );
//     });
//   }
//
//   void _navigateToChat(ChatContact contact) {
//     print('=== Navigating to chat with ${contact.name} (ID: ${contact.id}) ===');
//
//     // Find the connection
//     final connection = chatViewModel.connections.firstWhere(
//           (conn) => conn.user.id.toString() == contact.id,
//     );
//
//     // Select the user
//     chatViewModel.selectUser(connection.user);
//
//     // Navigate to chat screen
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const MessagesScreen(),
//       ),
//     ).then((_) {
//       // Refresh when returning
//       _fetchAllConnections();
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
//   final DateTime lastMessageTime;
//   final ChatConnection? connection;
//
//   ChatContact({
//     required this.id,
//     required this.name,
//     required this.lastMessage,
//     required this.timestamp,
//     required this.unreadCount,
//     required this.isOnline,
//     required this.avatar,
//     required this.lastMessageTime,
//     this.connection,
//   });
//
//   ChatContact copyWith({
//     String? id,
//     String? name,
//     String? lastMessage,
//     String? timestamp,
//     int? unreadCount,
//     bool? isOnline,
//     String? avatar,
//     DateTime? lastMessageTime,
//     ChatConnection? connection,
//   }) {
//     return ChatContact(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       lastMessage: lastMessage ?? this.lastMessage,
//       timestamp: timestamp ?? this.timestamp,
//       unreadCount: unreadCount ?? this.unreadCount,
//       isOnline: isOnline ?? this.isOnline,
//       avatar: avatar ?? this.avatar,
//       lastMessageTime: lastMessageTime ?? this.lastMessageTime,
//       connection: connection ?? this.connection,
//     );
//   }
// }
