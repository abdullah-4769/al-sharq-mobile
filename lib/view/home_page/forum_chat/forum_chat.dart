import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';

import '../../../images/images.dart';

class ForumChatScreen extends StatefulWidget {
  const ForumChatScreen({super.key});

  @override
  State<ForumChatScreen> createState() => _ForumChatScreenState();
}

class _ForumChatScreenState extends State<ForumChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> messages = [
    Message(
      id: '1',
      sender: 'Dr. Johnathan',
      message: 'Great question Sarah! From my experience, the biggest challenges are:',
      timestamp: '1 hour ago',
      bulletPoints: [
        BulletPoint('Data Privacy Regulations:', 'GDPR compliance and local data protection laws'),
        BulletPoint('Talent Shortage:', 'Limited AI/ML specialists in the region'),
        BulletPoint('Infrastructure:', 'Legacy systems integration challenges'),
      ],
      additionalText: 'We\'ve had success with gradual implementation and extensive training programs. What\'s been your experience with stakeholder buy-in?',
      likes: 12,
      isLiked: false,
    ),
    Message(
      id: '2',
      sender: 'Dr. Johnathan',
      message: 'I agree, Emma. I especially liked how they tied the framework back to real-world applications. Too often sessions are just theory, but here I actually feel like I can take the model and use it with my team right away. Did you also find the group activity helpful?',
      timestamp: '1 hour ago',
      likes: 0,
      isLiked: false,
    ),
    Message(
      id: '3',
      sender: 'Layla Hassan',
      message: 'The talent shortage is real! We\'ve been partnering with local universities to create AI training programs. It\'s a long-term investment but necessary.',
      timestamp: '1 hour ago',
      likes: 0,
      isLiked: false,
    ),
  ];

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
          Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sender: 'You',
            message: _messageController.text.trim(),
            timestamp: 'Just now',
            likes: 0,
            isLiked: false,
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

  void _toggleLike(String messageId) {
    setState(() {
      final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
      if (messageIndex != -1) {
        messages[messageIndex].isLiked = !messages[messageIndex].isLiked;
        if (messages[messageIndex].isLiked) {
          messages[messageIndex].likes++;
        } else {
          messages[messageIndex].likes--;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: const AppText(
          text: 'Future of Regional Cooperation',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Forum Info Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Networking Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const AppText(
                            text: 'Networking',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkBlue,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Title
                        const AppText(
                          text: 'Future of Regional Cooperation',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),

                        const SizedBox(height: 8),

                        // Description
                        AppText(
                          text: 'Discuss strategies for regional partnerships and collaborative initiatives',
                          fontSize: 14,
                          color: AppColors.darkgrey,
                        ),

                        const SizedBox(height: 16),

                        // Stats Row
                        Row(
                          children: [
                            Icon(Icons.people, color: AppColors.primaryColor, size: 16),
                            const SizedBox(width: 4),
                            const AppText(text: '245 Members', fontSize: 14, color: Colors.black),
                            const SizedBox(width: 20),
                            Icon(Icons.chat_bubble, color: AppColors.primaryColor, size: 16),
                            const SizedBox(width: 4),
                            const AppText(text: '120 Posts', fontSize: 14, color: Colors.black),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Creator Info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: AssetImage(Images.drjohnthan),
                            ),
                            const SizedBox(width: 8),
                            AppText(
                              text: 'Created By: Dr. Johnathan',
                              fontSize: 14,
                              color: AppColors.darkgrey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Join Notification
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.lightred,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppText(
                          text: 'You Joined the forum  ',
                          fontSize: 14,                          fontWeight: FontWeight.w600,

                          color:AppColors.primaryColor,
                        ),
                        AppText(
                          text: '10:35 AM',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Today Label
                  Container(
                    height: 38,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.lightGreyColor
                    ),
                    child: Center(
                      child: const AppText(
                        text: 'Today',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Messages Column (instead of ListView)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: messages.map((message) => _buildMessageCard(message)).toList(),
                    ),
                  ),

                  // Add some bottom padding to ensure content doesn't get hidden behind input
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Message Input (Fixed at bottom)
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
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
     color: AppColors.lightGreyColor,

                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.darkgrey),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Write your message...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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

  Widget _buildMessageCard(Message message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage: AssetImage(Images.drjohnthan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  text: message.sender,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              AppText(
                text: message.timestamp,
                fontSize: 12,
                color: Colors.grey,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main message
          AppText(
            text: message.message,
            fontSize: 15,
            color: Colors.black,
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
                    color: Colors.black,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    text: point.description,
                    fontSize: 14,
                    color: Colors.grey[600]!,
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
              color: Colors.black,
            ),
          ],

          const SizedBox(height: 16),

          // Actions Row
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(message.id),
                child: Row(
                  children: [
                    Icon(
                      message.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      color: message.isLiked ? AppColors.primaryColor : AppColors.primaryColor,
                      size: 18,
                    ),
                    if (message.likes > 0) ...[
                      const SizedBox(width: 6),
                      AppText(
                        text: message.likes.toString(),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.reply, color: AppColors.primaryColor, size: 18),
                    const SizedBox(width: 6),
                    const AppText(
                      text: 'Reply',
                      fontSize: 14,
                       color:  AppColors.primaryColor                     ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.redo, color: AppColors.primaryColor, size: 24),
                    const SizedBox(width: 6),
                    const AppText(
                      text: 'Share',
                      fontSize: 14,
                      color: Colors.black,
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
}

class Message {
  final String id;
  final String sender;
  final String message;
  final String timestamp;
  final List<BulletPoint>? bulletPoints;
  final String? additionalText;
  int likes;
  bool isLiked;

  Message({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
    this.bulletPoints,
    this.additionalText,
    required this.likes,
    required this.isLiked,
  });
}

class BulletPoint {
  final String title;
  final String description;

  BulletPoint(this.title, this.description);
}