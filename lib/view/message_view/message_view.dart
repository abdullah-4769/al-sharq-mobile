import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();

  // Sample chat data
  final List<Chat> chats = [
    Chat(
      name: 'Dr. Johnathan',
      message: 'Remember to review your...',
      time: '2 days ago',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
    ),
    Chat(
      name: 'Dr. Emma Wilson',
      message: 'Remember to review your...',
      time: '2 days ago',
      imageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b13a',
    ),
    Chat(
      name: 'David Rodriguez',
      message: 'Remember to review your...',
      time: '2 days ago',
      imageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e',
    ),
    Chat(
      name: 'Lisa Park',
      message: 'Remember to review your...',
      time: '2 days ago',
      imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d',
    ),
    Chat(
      name: 'Michael Chen',
      message: 'Remember to review your...',
      time: '2 days ago',
      imageUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
    ),
  ];

  // Sample messages for Dr. Johnathan
  final List<Message> messages = [
    Message(
      text: 'I really appreciate how today\'s session broke down such a complex topic into manageable steps. The framework the speaker shared makes it much easier to visualize how we can integrate this into our own projects. Definitely one of the most practical workshops I\'ve attended in a while.',
      time: 'Today, 10:32 AM',
      isSent: false,
      imageUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b13a',
    ),
    Message(
      text: 'I agree, Emma. I especially liked how they tied the framework back to real-world applications. Too often sessions are just theory, but here I actually feel like I can take the model and use it with my team right away. Did you also find the group activity helpful?',
      time: 'Today, 10:35 AM',
      isSent: true,
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.lightGreyColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.blackColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: AppText(
            text: 'Messages',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.darkgrey,
            indicatorColor: AppColors.primaryColor,
            tabs: [
              Tab(text: 'Chat List'),
              Tab(text: 'Chats'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Chat List Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search, color: AppColors.darkgrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.whiteColor,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(chats[index].imageUrl),
                        ),
                        title: AppText(
                          text: chats[index].name,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        subtitle: AppText(
                          text: chats[index].message,
                          fontSize: 14,
                          color: AppColors.darkgrey,

                        ),
                        trailing: AppText(
                          text: chats[index].time,
                          fontSize: 12,
                          color: AppColors.darkgrey,
                        ),
                        onTap: () {
                          _tabController.animateTo(1); // Switch to Chats tab
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            // Chats Tab
            Column(
              children: [
                Container(
                  color: AppColors.whiteColor,
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d'),
                        radius: 20,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: 'Dr. Johnathan',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                          AppText(
                            text: 'Director of Regional Affairs',
                            fontSize: 14,
                            color: AppColors.darkgrey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Align(
                        alignment: message.isSent ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.isSent ? AppColors.primaryColor : AppColors.lightGreyColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppText(
                            text: message.text,
                            fontSize: 14,
                            color: message.isSent ? AppColors.whiteColor : AppColors.blackColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Type Here...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(12),
                        ),
                        child: Icon(Icons.send, color: AppColors.whiteColor),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightred,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: AppText(
                          text: 'Introduce yourself',
                          fontSize: 12,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightred,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: AppText(
                          text: 'Share an insight',
                          fontSize: 12,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightred,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: AppText(
                          text: 'Ask a que:',
                          fontSize: 12,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Chat {
  final String name;
  final String message;
  final String time;
  final String imageUrl;

  Chat({
    required this.name,
    required this.message,
    required this.time,
    required this.imageUrl,
  });
}

class Message {
  final String text;
  final String time;
  final bool isSent;
  final String imageUrl;

  Message({
    required this.text,
    required this.time,
    required this.isSent,
    required this.imageUrl,
  });
}