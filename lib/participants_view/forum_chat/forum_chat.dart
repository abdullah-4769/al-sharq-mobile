import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import '../../../images/images.dart';
import 'chat_list_view.dart';

class IndividualChatScreen extends StatefulWidget {
  final ChatContact contact;

  const IndividualChatScreen({
    super.key,
    required this.contact,
  });

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _initializeMessages();
  }

  void _initializeMessages() {
    // Sample messages for different contacts
    if (widget.contact.id == '1') {
      messages = [
        ChatMessage(
          id: '1',
          senderId: widget.contact.id,
          senderName: widget.contact.name,
          message: 'Great question Sarah! From my experience, the biggest challenges are:',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isMe: false,
          bulletPoints: [
            BulletPoint('Data Privacy Regulations:', 'GDPR compliance and local data protection laws'),
            BulletPoint('Talent Shortage:', 'Limited AI/ML specialists in the region'),
            BulletPoint('Infrastructure:', 'Legacy systems integration challenges'),
          ],
          additionalText: 'We\'ve had success with gradual implementation and extensive training programs. What\'s been your experience with stakeholder buy-in?',
        ),
        ChatMessage(
          id: '2',
          senderId: widget.contact.id,
          senderName: widget.contact.name,
          message: 'I agree, Emma. I especially liked how they tied the framework back to real-world applications.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isMe: false,
        ),
        ChatMessage(
          id: '3',
          senderId: 'me',
          senderName: 'You',
          message: 'That\'s really insightful! I\'ve been facing similar challenges in my organization.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          isMe: true,
        ),
      ];
    } else {
      // Default messages for other contacts
      messages = [
        ChatMessage(
          id: '1',
          senderId: widget.contact.id,
          senderName: widget.contact.name,
          message: widget.contact.lastMessage,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isMe: false,
        ),
        ChatMessage(
          id: '2',
          senderId: 'me',
          senderName: 'You',
          message: 'Thanks for sharing!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          isMe: true,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: 'me',
            senderName: 'You',
            message: _messageController.text.trim(),
            timestamp: DateTime.now(),
            isMe: true,
          ),
        );
      });
      _messageController.clear();

      // Scroll to bottom after adding new message
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(widget.contact.avatar),
                ),
                if (widget.contact.isOnline)
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: widget.contact.name,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  AppText(
                    text: widget.contact.isOnline ? 'Online' : 'Last seen recently',
                    fontSize: 12,
                    color: AppColors.darkgrey,
                  ),
                ],
              ),
            ),
          ],
        ),
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
            icon: Icon(Icons.more_vert, color: AppColors.darkgrey),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Message Input Area
          Container(
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
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: AppColors.primaryColor),
                  onPressed: () {},
                ),
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
                        hintStyle: TextStyle(color: AppColors.darkgrey, fontSize: 14),
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
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(25),
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
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(widget.contact.avatar),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isMe ? AppColors.primaryColor : AppColors.whiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main message
                  AppText(
                    text: message.message,
                    fontSize: 15,
                    color: message.isMe ? Colors.white : Colors.black,
                  ),

                  // Bullet points if available
                  if (message.bulletPoints != null && message.bulletPoints!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...message.bulletPoints!.map((point) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: point.title,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: message.isMe ? Colors.white : Colors.black,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            text: point.description,
                            fontSize: 14,
                            color: message.isMe ? Colors.white.withOpacity(0.9) : AppColors.darkgrey,
                          ),
                        ],
                      ),
                    )),
                  ],

                  // Additional text if available
                  if (message.additionalText != null && message.additionalText!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    AppText(
                      text: message.additionalText!,
                      fontSize: 15,
                      color: message.isMe ? Colors.white : Colors.black,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Timestamp
                  AppText(
                    text: _formatTimestamp(message.timestamp),
                    fontSize: 12,
                    color: message.isMe ? Colors.white.withOpacity(0.8) : AppColors.darkgrey,
                  ),
                ],
              ),
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryColor,
              child: const AppText(
                text: 'Me',
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isMe;
  final List<BulletPoint>? bulletPoints;
  final String? additionalText;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.bulletPoints,
    this.additionalText,
  });
}

class BulletPoint {
  final String title;
  final String description;

  BulletPoint(this.title, this.description);
}