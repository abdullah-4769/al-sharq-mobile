
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/view_model/participant_viewmodel/participant_chat_viewmodels/participant_chat_viewmodel.dart';
import 'package:al_sharq_conference/utils/shared_preference.dart';
import '../../data/request_models/chats_model/participant_chat_model.dart';
import '../../../images/images.dart';
import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ParticipantChatViewModel chatViewModel = Get.find<ParticipantChatViewModel>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? currentUserImage;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      // Mark messages as read when opening chat
      if (chatViewModel.selectedUser.value != null) {
        _markMessagesAsRead();
      }
    });
  }

  Future<void> _loadCurrentUserData() async {
    currentUserId = await SharedPrefsHelper.getUserId();
    // Try to get user image from SharedPreferences or other source
    currentUserImage = await SharedPrefsHelper.getUserImage();
    setState(() {});
  }

  Future<void> _markMessagesAsRead() async {
    final selectedUser = chatViewModel.selectedUser.value;
    if (selectedUser != null) {
      await chatViewModel.markMessagesAsRead(selectedUser.id);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    chatViewModel.stopMessagesTimer();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      chatViewModel.sendMessage(_messageController.text.trim());
      _messageController.clear();
      _scrollToBottom();
    }
  }

  String _formatMessageTime(String timestamp) {
    try {
      // Convert UTC timestamp to local time
      final messageTime = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final difference = now.difference(messageTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24 && messageTime.day == now.day) {
        return 'Today';
      } else if (difference.inDays == 1 || (difference.inHours < 48 && messageTime.day == now.day - 1)) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        return days[messageTime.weekday % 7];
      } else {
        return '${messageTime.day}/${messageTime.month}/${messageTime.year}';
      }
    } catch (e) {
      return '';
    }
  }

  String _formatTimeOnly(String timestamp) {
    try {
      // Convert UTC timestamp to local time
      final messageTime = DateTime.parse(timestamp).toLocal();
      final hour = messageTime.hour > 12 ? messageTime.hour - 12 : (messageTime.hour == 0 ? 12 : messageTime.hour);
      final period = messageTime.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        final selectedUser = chatViewModel.selectedUser.value;

        if (selectedUser == null) {
          return _buildSelectUserPrompt();
        }

        return Column(
          children: [
            Expanded(
              child: _buildMessagesList(),
            ),
            _buildMessageInput(),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.whiteColor,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Obx(() {
        final user = chatViewModel.selectedUser.value;
        if (user == null) {
          return const AppText(
            text: 'Messages',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          );
        }

        return Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: user.displayImage.isNotEmpty && user.displayImage.startsWith('http')
                  ? NetworkImage(user.displayImage)
                  : const AssetImage(Images.drjohnthan) as ImageProvider,
              onBackgroundImageError: (exception, stackTrace) {},
              child: user.displayImage.isEmpty || !user.displayImage.startsWith('http')
                  ? const Icon(Icons.person, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: user.name,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  const AppText(
                    text: 'Online',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        IconButton(
          icon: Icon(Icons.videocam, color: AppColors.primaryColor),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.call, color: AppColors.primaryColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSelectUserPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Select a conversation to start chatting',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Obx(() {
      if (chatViewModel.isLoading.value && chatViewModel.messages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (chatViewModel.messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No messages yet',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Start the conversation!',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        );
      }

      // Sort messages by timestamp (oldest first)
      final sortedMessages = List<ChatMessage>.from(chatViewModel.messages);
      sortedMessages.sort((a, b) {
        try {
          final timeA = DateTime.parse(a.createdAt);
          final timeB = DateTime.parse(b.createdAt);
          return timeA.compareTo(timeB); // Ascending order (oldest first)
        } catch (e) {
          return 0;
        }
      });

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: sortedMessages.length,
        itemBuilder: (context, index) {
          final message = sortedMessages[index];
          final isMe = message.from == 'sender';

          // Show date separator if day changed
          bool showDateSeparator = false;
          if (index == 0) {
            showDateSeparator = true;
          } else {
            try {
              final currentDate = DateTime.parse(message.createdAt);
              final previousDate = DateTime.parse(sortedMessages[index - 1].createdAt);
              showDateSeparator = currentDate.day != previousDate.day ||
                  currentDate.month != previousDate.month ||
                  currentDate.year != previousDate.year;
            } catch (e) {
              showDateSeparator = false;
            }
          }

          return Column(
            children: [
              if (showDateSeparator) _buildDateSeparator(message.createdAt),
              _buildMessageBubble(message, isMe),
            ],
          );
        },
      );
    });
  }

  Widget _buildDateSeparator(String timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppText(
                text: _formatMessageTime(timestamp),
                fontSize: 11,
                color: Colors.grey[700]!,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    final user = chatViewModel.selectedUser.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: user?.displayImage != null && user!.displayImage.isNotEmpty && user.displayImage.startsWith('http')
                  ? NetworkImage(user.displayImage)
                  : const AssetImage(Images.drjohnthan) as ImageProvider,
              onBackgroundImageError: (exception, stackTrace) {},
              child: user?.displayImage == null || user!.displayImage.isEmpty || !user.displayImage.startsWith('http')
                  ? const Icon(Icons.person, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primaryColor : AppColors.whiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: AppText(
                    text: message.content,
                    fontSize: 15,
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      text: _formatTimeOnly(message.createdAt),
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      _buildMessageStatusIcon(message.status),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: currentUserImage != null && currentUserImage!.isNotEmpty && currentUserImage!.startsWith('http')
                  ? NetworkImage(currentUserImage!)
                  : const AssetImage(Images.drjohnthan) as ImageProvider,
              onBackgroundImageError: (exception, stackTrace) {},
              child: currentUserImage == null || currentUserImage!.isEmpty || !currentUserImage!.startsWith('http')
                  ? const Icon(Icons.person, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.grey),
        );
      case MessageStatus.failed:
        return const Icon(Icons.error_outline, size: 14, color: Colors.red);
      case MessageStatus.read:
      // Double check mark (blue) for read messages
        return Stack(
          children: [
            const Icon(Icons.done_all, size: 14, color: Colors.blue),
          ],
        );
      case MessageStatus.sent:
      default:
      // Single check mark (grey) for sent messages
        return Icon(Icons.check, size: 14, color: Colors.grey[600]);
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file, color: AppColors.primaryColor),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGreyColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.camera_alt, color: AppColors.primaryColor),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:al_sharq_conference/app_colors/app_colors.dart';
// import 'package:al_sharq_conference/custom_widgets/app_text.dart';
//
// import '../../data/request_models/chats_model/participant_chat_model.dart';
// import '../../view_model/participant_viewmodel/participant_chat_viewmodels/participant_chat_viewmodel.dart';
//
// class MessagesScreen extends StatefulWidget {
//   @override
//   _MessagesScreenState createState() => _MessagesScreenState();
// }
//
// class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final ParticipantChatViewModel chatViewModel = Get.find<ParticipantChatViewModel>();
//   TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//
//     // Fetch connections when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       chatViewModel.fetchConnections();
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     chatViewModel.stopMessagesTimer();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         backgroundColor: AppColors.lightGreyColor,
//         appBar: AppBar(
//           backgroundColor: AppColors.whiteColor,
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: AppColors.blackColor),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: AppText(
//             text: 'Messages',
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: AppColors.blackColor,
//           ),
//           bottom: TabBar(
//             controller: _tabController,
//             labelColor: AppColors.primaryColor,
//             unselectedLabelColor: AppColors.darkgrey,
//             indicatorColor: AppColors.primaryColor,
//             tabs: [
//               Tab(text: 'Chat List'),
//               Tab(text: 'Chats'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             // Chat List Tab with real connections
//             _buildChatListTab(),
//             // Individual Chat Tab
//             _buildChatTab(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildChatListTab() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: 'Search...',
//               prefixIcon: Icon(Icons.search, color: AppColors.darkgrey),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//               filled: true,
//               fillColor: AppColors.whiteColor,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Obx(() {
//             if (chatViewModel.isLoading.value && chatViewModel.connections.isEmpty) {
//               return Center(child: CircularProgressIndicator());
//             }
//
//             if (chatViewModel.errorMessage.value.isNotEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline, size: 64, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text(
//                       chatViewModel.errorMessage.value,
//                       style: TextStyle(color: Colors.grey),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: () => chatViewModel.fetchConnections(),
//                       child: Text('Retry'),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             if (chatViewModel.connections.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.people_outline, size: 64, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text(
//                       'No connections yet',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             return ListView.builder(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               itemCount: chatViewModel.connections.length,
//               itemBuilder: (context, index) {
//                 final connection = chatViewModel.connections[index];
//                 return _buildConnectionTile(connection);
//               },
//             );
//           }),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildConnectionTile(ChatConnection connection) {
//     final unreadCount = chatViewModel.getUnreadCount(connection.user.id);
//
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundImage: _getAvatarImage(connection.user),
//       ),
//       title: AppText(
//         text: connection.user.name,
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//         color: AppColors.blackColor,
//       ),
//       subtitle: AppText(
//         text: 'Connected since ${_formatDate(connection.connectedAt)}',
//         fontSize: 14,
//         color: AppColors.darkgrey,
//       ),
//       trailing: unreadCount > 0
//           ? Container(
//         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           color: AppColors.primaryColor,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: AppText(
//           text: unreadCount.toString(),
//           fontSize: 12,
//           color: Colors.white,
//         ),
//       )
//           : null,
//       onTap: () {
//         chatViewModel.selectUser(connection.user);
//         _tabController.animateTo(1);
//       },
//     );
//   }
//
//   Widget _buildChatTab() {
//     return Obx(() {
//       final selectedUser = chatViewModel.selectedUser.value;
//
//       if (selectedUser == null) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
//               SizedBox(height: 16),
//               Text(
//                 'Select a conversation to start chatting',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//         );
//       }
//
//       return Column(
//         children: [
//           // Chat header
//           Container(
//             color: AppColors.whiteColor,
//             padding: EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   backgroundImage: _getAvatarImage(selectedUser),
//                   radius: 20,
//                 ),
//                 SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AppText(
//                       text: selectedUser.name,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.blackColor,
//                     ),
//                     AppText(
//                       text: selectedUser.email,
//                       fontSize: 14,
//                       color: AppColors.darkgrey,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // Messages area
//           Expanded(
//             child: Obx(() {
//               if (chatViewModel.messages.isEmpty) {
//                 return Center(
//                   child: Text(
//                     'No messages yet. Start the conversation!',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 );
//               }
//
//               return ListView.builder(
//                 padding: EdgeInsets.all(16),
//                 reverse: true,
//                 itemCount: chatViewModel.messages.length,
//                 itemBuilder: (context, index) {
//                   final message = chatViewModel.messages[index];
//                   return _buildMessageBubble(message);
//                 },
//               );
//             }),
//           ),
//
//           // Message input
//           _buildMessageInput(),
//         ],
//       );
//     });
//   }
//
//   Widget _buildMessageBubble(ChatMessage message) {
//     final isMe = message.from == 'sender';
//
//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 4),
//         padding: EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isMe ? AppColors.primaryColor : AppColors.lightGreyColor,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             AppText(
//               text: message.content,
//               fontSize: 14,
//               color: isMe ? AppColors.whiteColor : AppColors.blackColor,
//             ),
//             SizedBox(height: 4),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 AppText(
//                   text: _formatTime(message.createdAt),
//                   fontSize: 10,
//                   color: isMe ? AppColors.whiteColor.withOpacity(0.7) : AppColors.darkgrey,
//                 ),
//                 if (isMe) ...[
//                   SizedBox(width: 4),
//                   _buildMessageStatus(message.status),
//                 ],
//               ],
//             ),
//             if (message.status == MessageStatus.failed && isMe)
//               TextButton(
//                 onPressed: () => chatViewModel.retryMessage(message),
//                 child: Text(
//                   'Retry',
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: AppColors.whiteColor,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMessageStatus(MessageStatus status) {
//     switch (status) {
//       case MessageStatus.sending:
//         return SizedBox(
//           width: 12,
//           height: 12,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(AppColors.whiteColor),
//           ),
//         );
//       case MessageStatus.sent:
//         return Icon(Icons.check, size: 12, color: AppColors.whiteColor);
//       case MessageStatus.failed:
//         return Icon(Icons.error_outline, size: 12, color: Colors.red);
//     }
//   }
//
//   Widget _buildMessageInput() {
//     final textController = TextEditingController();
//
//     return Container(
//       padding: EdgeInsets.all(8),
//       color: AppColors.whiteColor,
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 color: AppColors.whiteColor,
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: TextField(
//                 controller: textController,
//                 decoration: InputDecoration(
//                   hintText: 'Type Here...',
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 8),
//           ElevatedButton(
//             onPressed: () {
//               if (textController.text.trim().isNotEmpty) {
//                 chatViewModel.sendMessage(textController.text.trim());
//                 textController.clear();
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryColor,
//               shape: CircleBorder(),
//               padding: EdgeInsets.all(12),
//             ),
//             child: Icon(Icons.send, color: AppColors.whiteColor),
//           ),
//         ],
//       ),
//     );
//   }
//
//   ImageProvider _getAvatarImage(ChatUser user) {
//     if (user.file != null && user.file!.isNotEmpty) {
//       return NetworkImage(user.file!);
//     } else {
//       // Generate avatar with initial
//       final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';
//       return NetworkImage('https://ui-avatars.com/api/?name=$initial&background=FFB3BA&color=fff&size=128');
//     }
//   }
//
//   String _formatDate(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       return '${date.day}/${date.month}/${date.year}';
//     } catch (e) {
//       return 'Unknown date';
//     }
//   }
//
//   String _formatTime(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return '';
//     }
//   }
// }