import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/participants_view/forum_chat/chat_list_view.dart';
import 'package:al_sharq_conference/participants_view/forum_chat/forum_chat.dart';
import 'package:al_sharq_conference/participants_view/message_view/message_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../../images/images.dart';
// Import the new viewmodels
import '../../data/request_models/chats_model/participant_chat_model.dart';
import '../../view_model/participant_viewmodel/participant_networking_viewmodels/participant_connected_users_viewmodel.dart';
import '../../view_model/participant_viewmodel/participant_networking_viewmodels/participant_connection_request_handle_viewmodel.dart';
import '../../view_model/participant_viewmodel/participant_networking_viewmodels/participant_pending_connection_show_viewmodel.dart';
// Import the chat viewmodel
import '../../view_model/participant_viewmodel/participant_chat_viewmodels/participant_chat_viewmodel.dart';

// Person class definition (updated for dynamic data)
class Person {
  final int id;
  final String name;
  final String title;
  final String organization;
  final String description;
  final String imageUrl;
  final String status;
  final int? connectionId;
  final int? requestId;

  Person({
    required this.id,
    required this.name,
    required this.title,
    required this.organization,
    required this.description,
    required this.imageUrl,
    required this.status,
    this.connectionId,
    this.requestId,
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

  // Initialize ViewModels
  final connectedUsersViewModel = Get.put(ParticipantConnectedUsersViewModel());
  final pendingConnectionsViewModel = Get.put(ParticipantPendingConnectionShowViewModel());
  final connectionRequestViewModel = Get.put(ParticipantConnectionRequestHandleViewModel());
  final chatViewModel = Get.put(ParticipantChatViewModel());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    connectedUsersViewModel.fetchConnectedUsers(context);
    pendingConnectionsViewModel.fetchPendingConnections(context);
    // Also fetch connections for chat
    chatViewModel.fetchConnections();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Convert API data to Person objects
  List<Person> get _directoryPeople {
    final pendingConnections = pendingConnectionsViewModel.pendingConnections;

    return pendingConnections.map((connection) {
      return Person(
        id: connection.sender.id,
        name: connection.sender.name,
        title: connection.sender.role,
        organization: 'Pending Connection',
        description: 'Connection request sent on ${_formatDate(connection.sentAt)}',
        imageUrl: _getUserImageUrl(connection.sender.displayImage),
        status: 'pending',
        requestId: connection.requestId,
      );
    }).toList();
  }

  List<Person> get _connectedPeople {
    final connectedUsers = connectedUsersViewModel.connectedUsers;

    return connectedUsers.map((user) {
      return Person(
        id: user.user.id,
        name: user.user.name,
        title: 'Connected User',
        organization: user.user.email,
        description: 'Connected since ${_formatDate(user.connectedAt)}',
        imageUrl: _getUserImageUrl(user.user.displayImage),
        status: 'connected',
        connectionId: user.connectionId,
      );
    }).toList();
  }

  String _getUserImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      // Generate avatar with user initial
      return 'https://ui-avatars.com/api/?name=User&background=FFB3BA&color=fff&size=128';
    }
    return imageUrl;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
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
                    onChanged: (value) {
                      connectedUsersViewModel.search(value);
                    },
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

          // Chat List Banner - Now navigates to REAL MessagesScreen
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
                        child: Obx(() => AppText(
                          text: 'Requests (${pendingConnectionsViewModel.pendingConnections.length})',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _tabController.index == 0
                              ? AppColors.whiteColor
                              : AppColors.darkgrey,
                        )),
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
                        child: Obx(() => AppText(
                          text: 'My Connections (${connectedUsersViewModel.filteredConnectedUsers.length})',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _tabController.index == 1
                              ? AppColors.whiteColor
                              : AppColors.darkgrey,
                        )),
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
            child: Obx(() => AppText(
              text: '${connectedUsersViewModel.filteredConnectedUsers.length} Connected Users',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            )),
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
    return Obx(() {
      if (pendingConnectionsViewModel.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (pendingConnectionsViewModel.errorMessage.value.isNotEmpty) {
        return Center(
          child: Text(pendingConnectionsViewModel.errorMessage.value),
        );
      }

      final people = _directoryPeople;

      if (people.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No pending connection requests',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: people.length,
        itemBuilder: (context, index) {
          return _buildPersonCard(people[index]);
        },
      );
    });
  }

  Widget _buildConnectionsTab() {
    return Obx(() {
      if (connectedUsersViewModel.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (connectedUsersViewModel.errorMessage.value.isNotEmpty) {
        return Center(
          child: Text(connectedUsersViewModel.errorMessage.value),
        );
      }

      final people = _connectedPeople;

      if (people.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No connections yet',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: people.length,
        itemBuilder: (context, index) {
          return _buildPersonCard(people[index]);
        },
      );
    });
  }

  void _startChat(Person person) {
    // Convert Person to ChatUser for the chat system
    final chatUser = ChatUser(
      id: person.id,
      name: person.name,
      email: person.organization,
      role: person.title,
      displayImage: person.imageUrl,
    );

    // Select the user in chat viewmodel
    chatViewModel.selectUser(chatUser);

    // Navigate to REAL MessagesScreen (not the old IndividualChatScreen)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagesScreen(),
      ),
    );
  }

  void _handleConnectionRequest(int requestId, String status) async {
    final success = await connectionRequestViewModel.handleConnectionRequest(
      requestId: requestId,
      status: status,
      context: context,
    );

    if (success) {
      // Remove from pending list
      pendingConnectionsViewModel.removePendingConnection(requestId);

      // Refresh connected users if accepted
      if (status == 'ACCEPTED') {
        connectedUsersViewModel.fetchConnectedUsers(context);
        // Also refresh chat connections
        chatViewModel.fetchConnections();
      }
    }
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
              // Profile Image with error handling
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(person.imageUrl),
                onBackgroundImageError: (exception, stackTrace) {
                  // Use default avatar if image fails to load
                },
                child: person.imageUrl.isEmpty || !person.imageUrl.startsWith('http')
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
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
              _buildConnectionButton(person),
            ],
          ),
          SizedBox(height: 12),
          // Description
          AppText(
            text: person.description,
            fontSize: 12,
            color: AppColors.darkgrey,
          ),
          // Action Buttons (for pending requests)
          if (person.status == 'pending' && person.requestId != null) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final isLoadingAccept = connectionRequestViewModel.isLoading.value &&
                        connectionRequestViewModel.currentRequestId.value == person.requestId &&
                        connectionRequestViewModel.currentAction.value == 'ACCEPTED';

                    return ElevatedButton(
                      onPressed: isLoadingAccept
                          ? null
                          : () => _handleConnectionRequest(person.requestId!, 'ACCEPTED'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoadingAccept
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          AppText(
                            text: 'Accept',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Obx(() {
                    final isLoadingReject = connectionRequestViewModel.isLoading.value &&
                        connectionRequestViewModel.currentRequestId.value == person.requestId &&
                        connectionRequestViewModel.currentAction.value == 'REJECTED';

                    return ElevatedButton(
                      onPressed: isLoadingReject
                          ? null
                          : () => _handleConnectionRequest(person.requestId!, 'REJECTED'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoadingReject
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          AppText(
                            text: 'Reject',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
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

  Widget _buildConnectionButton(Person person) {
    switch (person.status) {
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



// import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
// import 'package:al_sharq_conference/participants_view/forum_chat/chat_list_view.dart';
// import 'package:al_sharq_conference/participants_view/forum_chat/forum_chat.dart';
// import 'package:al_sharq_conference/participants_view/message_view/message_view.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
//
// import '../../app_colors/app_colors.dart';
// import '../../custom_widgets/app_text.dart';
// import '../../custom_widgets/custom_text_field.dart';
// import '../../../images/images.dart';
// // Import the new viewmodels
// import '../../view_model/participant_viewmodel/participant_networking_viewmodels/participant_connected_users_viewmodel.dart';
// import '../../view_model/participant_viewmodel/participant_networking_viewmodels/participant_connection_request_handle_viewmodel.dart';
// import '../../view_model/participant_viewmodel/participant_networking_viewmodels/participant_pending_connection_show_viewmodel.dart';
//
// // Person class definition (updated for dynamic data)
// class Person {
//   final int id;
//   final String name;
//   final String title;
//   final String organization;
//   final String description;
//   final String imageUrl;
//   final String status;
//   final int? connectionId;
//   final int? requestId;
//
//   Person({
//     required this.id,
//     required this.name,
//     required this.title,
//     required this.organization,
//     required this.description,
//     required this.imageUrl,
//     required this.status,
//     this.connectionId,
//     this.requestId,
//   });
// }
//
// // Chat Manager to handle global chat state
// class ChatManager {
//   static final ChatManager _instance = ChatManager._internal();
//   factory ChatManager() => _instance;
//   ChatManager._internal();
//
//   List<ChatContact> _chatContacts = [];
//   List<ChatContact> get chatContacts => _chatContacts;
//
//   void addOrUpdateChat(Person person) {
//     final existingIndex = _chatContacts.indexWhere((contact) => contact.name == person.name);
//
//     if (existingIndex != -1) {
//       // Update existing chat
//       _chatContacts[existingIndex] = _chatContacts[existingIndex].copyWith(
//         lastMessage: 'Started chatting',
//         timestamp: 'Just now',
//         isOnline: true,
//       );
//     } else {
//       // Add new chat
//       _chatContacts.insert(0, ChatContact(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         name: person.name,
//         lastMessage: 'Started chatting',
//         timestamp: 'Just now',
//         unreadCount: 0,
//         isOnline: true,
//         avatar: person.imageUrl,
//       ));
//     }
//   }
//
//   ChatContact? getChatContact(String personName) {
//     try {
//       return _chatContacts.firstWhere((contact) => contact.name == personName);
//     } catch (e) {
//       return null;
//     }
//   }
// }
//
// // Main Networking Screen
// class NetworkingScreen extends StatefulWidget {
//   @override
//   _NetworkingScreenState createState() => _NetworkingScreenState();
// }
//
// class _NetworkingScreenState extends State<NetworkingScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   TextEditingController _searchController = TextEditingController();
//
//   // Initialize ViewModels
//   final connectedUsersViewModel = Get.put(ParticipantConnectedUsersViewModel());
//   final pendingConnectionsViewModel = Get.put(ParticipantPendingConnectionShowViewModel());
//   final connectionRequestViewModel = Get.put(ParticipantConnectionRequestHandleViewModel());
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//
//     // Fetch data when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchData();
//     });
//   }
//
//   void _fetchData() {
//     connectedUsersViewModel.fetchConnectedUsers(context);
//     pendingConnectionsViewModel.fetchPendingConnections(context);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   // Convert API data to Person objects
//   List<Person> get _directoryPeople {
//     final pendingConnections = pendingConnectionsViewModel.pendingConnections;
//
//     return pendingConnections.map((connection) {
//       return Person(
//         id: connection.sender.id,
//         name: connection.sender.name,
//         title: connection.sender.role,
//         organization: 'Pending Connection',
//         description: 'Connection request sent on ${_formatDate(connection.sentAt)}',
//         imageUrl: connection.sender.displayImage,
//         status: 'pending',
//         requestId: connection.requestId,
//       );
//     }).toList();
//   }
//
//   List<Person> get _connectedPeople {
//     final connectedUsers = connectedUsersViewModel.connectedUsers;
//
//     return connectedUsers.map((user) {
//       return Person(
//         id: user.user.id,
//         name: user.user.name,
//         title: 'Connected User',
//         organization: user.user.email,
//         description: 'Connected since ${_formatDate(user.connectedAt)}',
//         imageUrl: user.user.displayImage,
//         status: 'connected',
//         connectionId: user.connectionId,
//       );
//     }).toList();
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
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: CustomAppDrawer(),
//       backgroundColor: AppColors.lightGreyColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.whiteColor,
//         elevation: 0,
//         title: AppText(
//           text: 'Networking',
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: AppColors.blackColor,
//         ),
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 18.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 6,
//                   child: CustomTextField(
//                     hintText: "Search",
//                     controller: _searchController,
//                     suffixIcon: Icons.search,
//                     onChanged: (value) {
//                       connectedUsersViewModel.search(value);
//                     },
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 Expanded(
//                   child: Container(
//                     height: 50,
//                     width: 40,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.grey.shade300),
//                     ),
//                     child: Icon(Icons.tune, color: AppColors.primaryColor),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Chat List Banner
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => ChatListScreen()),
//               );
//             },
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppColors.lightred,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryColor,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       Icons.chat,
//                       color: AppColors.whiteColor,
//                       size: 20,
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: AppText(
//                       text: 'Chats List',
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.blackColor,
//                     ),
//                   ),
//                   Icon(
//                     Icons.arrow_forward_ios,
//                     color: AppColors.darkgrey,
//                     size: 16,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(height: 8),
//
//           // Custom Tab Bar with better design
//           Container(
//             margin: EdgeInsets.symmetric(horizontal: 16),
//             padding: EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: AppColors.lightGreyColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       _tabController.animateTo(0);
//                       setState(() {});
//                     },
//                     child: Container(
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: _tabController.index == 0
//                             ? AppColors.primaryColor
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Center(
//                         child: Obx(() => AppText(
//                           text: 'Directory (${pendingConnectionsViewModel.pendingConnections.length})',
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: _tabController.index == 0
//                               ? AppColors.whiteColor
//                               : AppColors.darkgrey,
//                         )),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       _tabController.animateTo(1);
//                       setState(() {});
//                     },
//                     child: Container(
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: _tabController.index == 1
//                             ? AppColors.primaryColor
//                             : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Center(
//                         child: Obx(() => AppText(
//                           text: 'My Connections (${connectedUsersViewModel.filteredConnectedUsers.length})',
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: _tabController.index == 1
//                               ? AppColors.whiteColor
//                               : AppColors.darkgrey,
//                         )),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: 16),
//
//           // Speaker Count
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Obx(() => AppText(
//               text: '${connectedUsersViewModel.filteredConnectedUsers.length} Connected Users',
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: AppColors.darkgrey,
//             )),
//           ),
//
//           SizedBox(height: 8),
//
//           // Tab View
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 _buildDirectoryTab(),
//                 _buildConnectionsTab(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDirectoryTab() {
//     return Obx(() {
//       if (pendingConnectionsViewModel.isLoading.value) {
//         return Center(child: CircularProgressIndicator());
//       }
//
//       if (pendingConnectionsViewModel.errorMessage.value.isNotEmpty) {
//         return Center(
//           child: Text(pendingConnectionsViewModel.errorMessage.value),
//         );
//       }
//
//       final people = _directoryPeople;
//
//       if (people.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.people_outline, size: 64, color: Colors.grey),
//               SizedBox(height: 16),
//               Text(
//                 'No pending connection requests',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//         );
//       }
//
//       return ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: people.length,
//         itemBuilder: (context, index) {
//           return _buildPersonCard(people[index]);
//         },
//       );
//     });
//   }
//
//   Widget _buildConnectionsTab() {
//     return Obx(() {
//       if (connectedUsersViewModel.isLoading.value) {
//         return Center(child: CircularProgressIndicator());
//       }
//
//       if (connectedUsersViewModel.errorMessage.value.isNotEmpty) {
//         return Center(
//           child: Text(connectedUsersViewModel.errorMessage.value),
//         );
//       }
//
//       final people = _connectedPeople;
//
//       if (people.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.people_outline, size: 64, color: Colors.grey),
//               SizedBox(height: 16),
//               Text(
//                 'No connections yet',
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//         );
//       }
//
//       return ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: people.length,
//         itemBuilder: (context, index) {
//           return _buildPersonCard(people[index]);
//         },
//       );
//     });
//   }
//
//   void _startChat(Person person) {
//     // Add/Update chat in ChatManager
//     ChatManager().addOrUpdateChat(person);
//
//     // Get or create chat contact
//     ChatContact? contact = ChatManager().getChatContact(person.name);
//
//     if (contact == null) {
//       // Create new contact if doesn't exist
//       contact = ChatContact(
//         id: person.id.toString(),
//         name: person.name,
//         lastMessage: 'Started chatting',
//         timestamp: 'Just now',
//         unreadCount: 0,
//         isOnline: true,
//         avatar: person.imageUrl,
//       );
//     }
//
//     // Navigate to individual chat
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => IndividualChatScreen(contact: contact!),
//       ),
//     );
//   }
//
//   void _handleConnectionRequest(int requestId, String status) async {
//     final success = await connectionRequestViewModel.handleConnectionRequest(
//       requestId: requestId,
//       status: status,
//       context: context,
//     );
//
//     if (success) {
//       // Remove from pending list
//       pendingConnectionsViewModel.removePendingConnection(requestId);
//
//       // Refresh connected users if accepted
//       if (status == 'ACCEPTED') {
//         connectedUsersViewModel.fetchConnectedUsers(context);
//       }
//     }
//   }
//
//   Widget _buildPersonCard(Person person) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.whiteColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Profile Image with error handling
//               CircleAvatar(
//                 radius: 25,
//                 backgroundImage: NetworkImage(person.imageUrl),
//                 onBackgroundImageError: (exception, stackTrace) {
//                   // Handle image loading error
//                 },
//                 child: person.imageUrl.isEmpty
//                     ? Icon(Icons.person, color: Colors.white)
//                     : null,
//               ),
//               SizedBox(width: 12),
//               // Person Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AppText(
//                       text: person.name,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.blackColor,
//                     ),
//                     SizedBox(height: 2),
//                     AppText(
//                       text: person.title,
//                       fontSize: 14,
//                       color: AppColors.darkgrey,
//                     ),
//                     AppText(
//                       text: person.organization,
//                       fontSize: 14,
//                       color: AppColors.darkgrey,
//                     ),
//                   ],
//                 ),
//               ),
//               // Connection Button
//               _buildConnectionButton(person),
//             ],
//           ),
//           SizedBox(height: 12),
//           // Description
//           AppText(
//             text: person.description,
//             fontSize: 12,
//             color: AppColors.darkgrey,
//           ),
//           // Action Buttons (for pending requests)
//           if (person.status == 'pending' && person.requestId != null) ...[
//             SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: Obx(() {
//                     final isLoadingAccept = connectionRequestViewModel.isLoading.value &&
//                         connectionRequestViewModel.currentRequestId.value == person.requestId &&
//                         connectionRequestViewModel.currentAction.value == 'ACCEPTED';
//
//                     return ElevatedButton(
//                       onPressed: isLoadingAccept
//                           ? null
//                           : () => _handleConnectionRequest(person.requestId!, 'ACCEPTED'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: isLoadingAccept
//                           ? SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                           : Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.check, color: Colors.white, size: 16),
//                           SizedBox(width: 8),
//                           AppText(
//                             text: 'Accept',
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.white,
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Obx(() {
//                     final isLoadingReject = connectionRequestViewModel.isLoading.value &&
//                         connectionRequestViewModel.currentRequestId.value == person.requestId &&
//                         connectionRequestViewModel.currentAction.value == 'REJECTED';
//
//                     return ElevatedButton(
//                       onPressed: isLoadingReject
//                           ? null
//                           : () => _handleConnectionRequest(person.requestId!, 'REJECTED'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: isLoadingReject
//                           ? SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                           : Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.close, color: Colors.white, size: 16),
//                           SizedBox(width: 8),
//                           AppText(
//                             text: 'Reject',
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.white,
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//               ],
//             ),
//           ],
//           // Chat Button (only for connected users)
//           if (person.status == 'connected') ...[
//             SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               height: 40,
//               child: ElevatedButton(
//                 onPressed: () => _startChat(person),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.chat_bubble_outline,
//                       color: AppColors.whiteColor,
//                       size: 16,
//                     ),
//                     SizedBox(width: 8),
//                     AppText(
//                       text: 'Chat with ${person.name.split(' ').first}',
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: AppColors.whiteColor,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildConnectionButton(Person person) {
//     switch (person.status) {
//       case 'connect':
//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             border: Border.all(color: AppColors.primaryColor),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: AppText(
//             text: 'Connect',
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             color: AppColors.primaryColor,
//           ),
//         );
//       case 'connected':
//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.green,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: AppText(
//             text: 'Connected',
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             color: AppColors.whiteColor,
//           ),
//         );
//       case 'pending':
//         return Container(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.orange,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: AppText(
//             text: 'Pending',
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             color: AppColors.whiteColor,
//           ),
//         );
//       default:
//         return Container();
//     }
//   }
// }
//
// // Extension to add copyWith method to ChatContact
// extension ChatContactExtension on ChatContact {
//   ChatContact copyWith({
//     String? id,
//     String? name,
//     String? lastMessage,
//     String? timestamp,
//     int? unreadCount,
//     bool? isOnline,
//     String? avatar,
//   }) {
//     return ChatContact(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       lastMessage: lastMessage ?? this.lastMessage,
//       timestamp: timestamp ?? this.timestamp,
//       unreadCount: unreadCount ?? this.unreadCount,
//       isOnline: isOnline ?? this.isOnline,
//       avatar: avatar ?? this.avatar,
//     );
//   }
// }