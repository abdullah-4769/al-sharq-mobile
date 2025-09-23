import 'package:flutter/material.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import '../../../app_colors/app_colors.dart';
import '../../../images/images.dart';

class SessionContentWidget extends StatefulWidget {
  const SessionContentWidget({Key? key}) : super(key: key);

  @override
  _SessionContentWidgetState createState() => _SessionContentWidgetState();
}

class _SessionContentWidgetState extends State<SessionContentWidget> {
  TextEditingController _chatController = TextEditingController();
  String _selectedPollOption = '';
  Set<int> _likedMessages = Set<int>(); // Track liked messages
  List<Map<String, dynamic>> _chatMessages = [
    {
      'name': 'Dr. Johnathan',
      'message': 'Really appreciate the depth of insights you\'ve shared on AI implementation today. It\'s not just the technology, but the way you explained its impact and the examples you used. Very much appreciated. Definitely taking notes for how this can be applied in my own work.',
      'time': '2 min ago',
      'likes': 12,
      'isHost': true,
    },
    {
      'name': 'Sarah Thompson',
      'message': 'Thank you for looking forward to the upcoming Q&A segment. There\'s so much valuable information already, but I\'m excited to see the questions from the audience and hear your thoughts on some challenges that might not fit George.',
      'time': '5 min ago',
      'likes': 15,
      'isHost': false,
    },
    {
      'name': 'Michael Lee',
      'message': 'Excellent presentation! 👏 Your ability to break down complex topics into easy-to-understand concepts is impressive. It kept me fully engaged from start to finish, especially one of the most valuable sessions I\'ve attended this year.',
      'time': '10 min ago',
      'likes': 18,
      'isHost': false,
    },
    {
      'name': 'Emma Garcia',
      'message': 'I was especially impressed by the statistics you presented. They really highlighted the scale of change that AI is driving across different sectors. These numbers really help quantify what feels like such an important topic right now.',
      'time': '15 min ago',
      'likes': 8,
      'isHost': false,
    },
  ];

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_chatController.text.isNotEmpty) {
      setState(() {
        _chatMessages.insert(
          0,
          {
            'name': 'You',
            'message': _chatController.text,
            'time': 'Just now',
            'likes': 0,
            'isHost': false,
          },
        );
        _chatController.clear();
      });
    }
  }

  void _toggleLike(int index) {
    setState(() {
      if (_likedMessages.contains(index)) {
        // Unlike: Remove from liked set and decrement likes
        _likedMessages.remove(index);
        _chatMessages[index]['likes'] = (_chatMessages[index]['likes'] as int) - 1;
      } else {
        // Like: Add to liked set and increment likes
        _likedMessages.add(index);
        _chatMessages[index]['likes'] = (_chatMessages[index]['likes'] as int) + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'The Future of Regional Cooperation',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
          Row(
            children: [
              AppText(
                text: 'Dr. Johnathan',
                fontSize: 12,
                color: AppColors.blackColor,
              ),
              Icon(Icons.circle, size: 6, color: AppColors.primaryColor),
              AppText(
                text: 'Director of Regional Affairs',
                fontSize: 12,
                color: AppColors.blackColor,
              ),
            ],
          ),
          AppText(
            text: 'Middle East Institute',
            fontSize: 12,
            color: AppColors.blackColor,
          ),
          SizedBox(height: 16),
          AppText(
            text: 'Live Session Chat',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.mediumGreyColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts...',
                      hintStyle: TextStyle(color: AppColors.darkgrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: AppColors.mediumGreyColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: AppColors.mediumGreyColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: AppColors.primaryColor),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      image: DecorationImage(image: AssetImage(Images.sendIcons)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              reverse: true,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                return _buildChatMessage(
                  message['name'],
                  message['message'],
                  message['time'],
                  message['likes'],
                  isHost: message['isHost'],
                  isLiked: _likedMessages.contains(index),
                  onLike: () => _toggleLike(index),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          AppText(
            text: 'About',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          SizedBox(height: 12),
          AppText(
            text: 'Explore the evolving landscape of regional cooperation in the Middle East and North Africa. This keynote will examine emerging partnerships, economic integration opportunities, and the role of technology in fostering collaboration across borders.',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 20),
          AppText(
            text: 'Key Topics',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          SizedBox(height: 12),
          _buildTopicChips(),
          SizedBox(height: 20),
          AppText(
            text: 'Target Audience',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          SizedBox(height: 8),
          AppText(
            text: 'Government officials, policy makers, business leaders, and researchers interested in regional cooperation and economic development.',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 20),
          AppText(
            text: 'Language',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          SizedBox(height: 8),
          AppText(
            text: 'English with Arabic translation available',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 20),
          _buildSpeakerInfo(),
          SizedBox(height: 20),
          AppText(
            text: 'Live Poll',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.darkgrey,
              ),
              SizedBox(width: 4),
              AppText(
                text: '2:30 left',
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ],
          ),
          SizedBox(height: 16),
          AppText(
            text: 'Which technology will have the biggest impact on your industry in the next 5 years?',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
          SizedBox(height: 20),
          _buildPollOption('Artificial Intelligence', 45, 'ai'),
          _buildPollOption('Blockchain', 25, 'blockchain'),
          _buildPollOption('Internet of Things', 15, 'iot'),
          SizedBox(height: 20),
          CustomButton(
            text: 'Submit Response',
            onPressed: _selectedPollOption.isEmpty
                ? null
                : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Your response has been submitted!'),
                  backgroundColor: AppColors.primaryColor,
                ),
              );
            },
            backgroundColor: _selectedPollOption.isEmpty ? AppColors.mediumGreyColor : AppColors.primaryColor,
            textColor: AppColors.whiteColor,
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightBlue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.forum,
                      color: AppColors.darkBlue,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    AppText(
                      text: 'Session Forum',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                AppText(
                  text: 'Join the discussion with other attendees, ask questions, and share insights about this session.',
                  fontSize: 14,
                  color: AppColors.darkBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChips() {
    List<String> topics = [
      'Economic Integration',
      'Digital Cooperation',
      'Trade Partnerships',
      'Regional Security'
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: topics
          .map((topic) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.lightred,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3),
          ),
        ),
        child: AppText(
          text: topic,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryColor,
        ),
      ))
          .toList(),
    );
  }

  Widget _buildSpeakerInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mediumGreyColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.mediumGreyColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.darkgrey,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: 'Dr. Johnathan',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                    AppText(
                      text: 'Director of Regional Affairs',
                      fontSize: 14,
                      color: AppColors.darkgrey,
                    ),
                    AppText(
                      text: 'Middle East Institute',
                      fontSize: 14,
                      color: AppColors.darkgrey,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  text: 'Keynote Speaker',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          AppText(
            text: 'Dr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations. He has written 15 books, published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
            fontSize: 13,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 12),
          CustomButton(
            text: 'Chat with Dr. Johnathan',
            onPressed: () {},
            backgroundColor: AppColors.primaryColor,
            textColor: AppColors.whiteColor,
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(String name, String message, String time, int likes, {bool isHost = false, required bool isLiked, required VoidCallback onLike}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isHost ? AppColors.primaryColor : AppColors.mediumGreyColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: AppColors.whiteColor,
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: name,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                    AppText(
                      text: time,
                      fontSize: 12,
                      color: AppColors.darkgrey,
                    ),
                  ],
                ),
                SizedBox(height: 4),
                AppText(
                  text: message,
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLike,
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isLiked ? AppColors.primaryColor : AppColors.darkgrey,
                      ),
                    ),
                    SizedBox(width: 4),
                    AppText(
                      text: '$likes',
                      fontSize: 12,
                      color: AppColors.darkgrey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollOption(String option, int percentage, String value) {
    bool isSelected = _selectedPollOption == value;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPollOption = value;
          });
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightred : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : AppColors.mediumGreyColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryColor : AppColors.mediumGreyColor,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.primaryColor : AppColors.whiteColor,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 14, color: AppColors.whiteColor)
                        : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: AppText(
                      text: option,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackColor,
                    ),
                  ),
                  AppText(
                    text: '$percentage%',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: AppColors.lightGreyColor,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}