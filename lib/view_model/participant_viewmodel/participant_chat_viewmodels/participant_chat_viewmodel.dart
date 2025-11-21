import 'dart:async';
import 'package:get/get.dart';
import 'package:al_sharq_conference/utils/shared_preference.dart';
import '../../../data/request_models/chats_model/participant_chat_model.dart';
import '../../../repository/participants_repository/participant_chat_repo/participant_chat_repo.dart';

class ParticipantChatViewModel extends GetxController {
  final ParticipantChatRepository _chatRepository = ParticipantChatRepository();

  // Observables
  final RxList<ChatConnection> connections = <ChatConnection>[].obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final Rx<ChatUser?> selectedUser = Rx<ChatUser?>(null);
  final RxMap<int, int> unreadCounts = <int, int>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // For real-time updates
  var _isFetching = false;
  Timer? _messagesTimer;
  Timer? _connectionsTimer;
// Add this method to your ParticipantChatViewModel class

// Mark messages as read when opening chat
  Future<void> markMessagesAsRead(int otherUserId) async {
    try {
      // Call API to mark messages as read
      final success = await _chatRepository.markMessagesAsRead(otherUserId);

      if (success) {
        // Update local messages to read status
        final updatedMessages = messages.map((msg) {
          if (msg.from == 'receiver') {
            return msg.copyWith(status: MessageStatus.read, isRead: true);
          }
          return msg;
        }).toList();

        messages.value = updatedMessages;

        // Clear unread count
        unreadCounts[otherUserId] = 0;

        print('=== Marked messages as read for user $otherUserId ===');
      }
    } catch (e) {
      print('=== Error marking messages as read: $e ===');
    }
  }

// Update the fetchMessages method to properly handle read status
  Future<void> fetchMessages(int otherUserId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final dynamic response = await _chatRepository.getMessages(otherUserId);

      List<dynamic> messagesList = [];

      if (response is List) {
        messagesList = response;
      } else if (response is Map<String, dynamic>) {
        if (response['messages'] is List) {
          messagesList = response['messages'] as List;
        } else if (response['data'] is List) {
          messagesList = response['data'] as List;
        } else if (response['items'] is List) {
          messagesList = response['items'] as List;
        } else {
          messagesList = [response];
        }
      }

      final int? userId = await SharedPrefsHelper.getUserId();
      final formattedMessages = messagesList.map((apiMsg) {
        Map<String, dynamic> messageMap = {};

        if (apiMsg is Map<String, dynamic>) {
          messageMap = apiMsg;
        } else if (apiMsg is Map) {
          messageMap = Map<String, dynamic>.from(apiMsg);
        }

        final dynamic senderId = messageMap['senderId'] ?? messageMap['fromId'];
        bool isMe = false;

        if (userId != null) {
          if (senderId is int) {
            isMe = senderId == userId;
          } else if (senderId is String) {
            isMe = int.tryParse(senderId) == userId;
          } else {
            final fromField = messageMap['from'];
            isMe = fromField == 'sender' || fromField == 'me';
          }
        }

        // Determine message status
        MessageStatus status = MessageStatus.sent;
        if (isMe) {
          // For sent messages, check if read
          final isRead = messageMap['isRead'] ?? messageMap['read'] ?? false;
          status = isRead ? MessageStatus.read : MessageStatus.sent;
        }

        return ChatMessage(
          id: messageMap['id'] is int ? messageMap['id'] : null,
          from: isMe ? 'sender' : 'receiver',
          content: messageMap['content'] ?? messageMap['message'] ?? '',
          createdAt: messageMap['createdAt'] ?? messageMap['timestamp'] ?? DateTime.now().toIso8601String(),
          status: status,
          isRead: messageMap['isRead'] ?? messageMap['read'],
        );
      }).toList();

      final optimisticMessages = messages.where((msg) =>
      msg.status == MessageStatus.sending || msg.status == MessageStatus.failed).toList();

      messages.value = [...formattedMessages, ...optimisticMessages];

      // Mark messages as read when opening chat
      if (selectedUser.value?.id == otherUserId) {
        await markMessagesAsRead(otherUserId);
      }

      print('=== Fetched ${messages.length} messages for user $otherUserId ===');

      _startMessagesTimer(otherUserId);

    } catch (e) {
      errorMessage.value = 'Failed to load messages: $e';
      print('=== Error fetching messages: $e ===');
    } finally {
      isLoading.value = false;
    }
  }
  @override
  void onInit() {
    super.onInit();
    print('=== ParticipantChatViewModel initialized ===');
  }

  @override
  void onClose() {
    _stopTimers();
    super.onClose();
  }

  void _stopTimers() {
    _messagesTimer?.cancel();
    _connectionsTimer?.cancel();
  }

  // Fetch all connections
  Future<void> fetchConnections() async {
    try {
      if (_isFetching) return;
      _isFetching = true;

      isLoading.value = true;
      errorMessage.value = '';

      final dynamic connectionsData = await _chatRepository.getConnections();

      // Handle different response structures
      List<dynamic> connectionList = [];

      if (connectionsData is List) {
        connectionList = connectionsData;
      } else if (connectionsData is Map<String, dynamic>) {
        // Handle Map response - check for common keys
        if (connectionsData['data'] is List) {
          connectionList = connectionsData['data'] as List;
        } else if (connectionsData['connections'] is List) {
          connectionList = connectionsData['connections'] as List;
        } else if (connectionsData['items'] is List) {
          connectionList = connectionsData['items'] as List;
        } else {
          // If it's a Map but contains connection data directly
          connectionList = [connectionsData];
        }
      }

      final List<ChatConnection> connectionsList = connectionList
          .map((conn) {
        if (conn is Map<String, dynamic>) {
          return ChatConnection.fromJson(conn);
        } else if (conn is Map) {
          return ChatConnection.fromJson(Map<String, dynamic>.from(conn));
        } else {
          return ChatConnection.fromJson({});
        }
      })
          .where((conn) => conn.user.id != 0) // Filter out invalid connections
          .toList();

      connections.value = connectionsList;

      // Update unread counts
      for (final conn in connectionsList) {
        if (conn.unreadMessages > 0) {
          unreadCounts[conn.user.id] = conn.unreadMessages;
        }
      }

      print('=== Fetched ${connections.length} connections ===');

      // Start periodic updates for connections
      _startConnectionsTimer();

    } catch (e) {
      errorMessage.value = 'Failed to load connections: $e';
      print('=== Error fetching connections: $e ===');
    } finally {
      isLoading.value = false;
      _isFetching = false;
    }
  }

  // // Fetch messages for a specific user
  // Future<void> fetchMessages(int otherUserId) async {
  //   try {
  //     isLoading.value = true;
  //     errorMessage.value = '';
  //
  //     final dynamic response = await _chatRepository.getMessages(otherUserId);
  //
  //     // Handle different response structures
  //     List<dynamic> messagesList = [];
  //
  //     if (response is List) {
  //       messagesList = response;
  //     } else if (response is Map<String, dynamic>) {
  //       // Handle Map response - check for common keys
  //       if (response['messages'] is List) {
  //         messagesList = response['messages'] as List;
  //       } else if (response['data'] is List) {
  //         messagesList = response['data'] as List;
  //       } else if (response['items'] is List) {
  //         messagesList = response['items'] as List;
  //       } else {
  //         // If it's a Map but contains message data directly
  //         messagesList = [response];
  //       }
  //     }
  //
  //     // Convert API messages to our format
  //     final int? userId = await SharedPrefsHelper.getUserId();
  //     final formattedMessages = messagesList.map((apiMsg) {
  //       Map<String, dynamic> messageMap = {};
  //
  //       if (apiMsg is Map<String, dynamic>) {
  //         messageMap = apiMsg;
  //       } else if (apiMsg is Map) {
  //         messageMap = Map<String, dynamic>.from(apiMsg);
  //       }
  //
  //       // Determine if message is from current user
  //       final dynamic senderId = messageMap['senderId'] ?? messageMap['fromId'];
  //       bool isMe = false;
  //
  //       if (userId != null) {
  //         if (senderId is int) {
  //           isMe = senderId == userId;
  //         } else if (senderId is String) {
  //           isMe = int.tryParse(senderId) == userId;
  //         } else {
  //           // Check 'from' field as fallback
  //           final fromField = messageMap['from'];
  //           isMe = fromField == 'sender' || fromField == 'me';
  //         }
  //       }
  //
  //       return ChatMessage(
  //         id: messageMap['id'] is int ? messageMap['id'] : null,
  //         from: isMe ? 'sender' : 'receiver',
  //         content: messageMap['content'] ?? messageMap['message'] ?? '',
  //         createdAt: messageMap['createdAt'] ?? messageMap['timestamp'] ?? DateTime.now().toIso8601String(),
  //         status: MessageStatus.sent,
  //       );
  //     }).toList();
  //
  //     // Merge with existing optimistic messages
  //     final optimisticMessages = messages.where((msg) =>
  //     msg.status == MessageStatus.sending || msg.status == MessageStatus.failed).toList();
  //
  //     messages.value = [...formattedMessages, ...optimisticMessages];
  //
  //     // Mark messages as read when opening chat
  //     if (selectedUser.value?.id == otherUserId) {
  //       await _chatRepository.markMessagesAsRead(otherUserId);
  //       unreadCounts[otherUserId] = 0;
  //     }
  //
  //     print('=== Fetched ${messages.length} messages for user $otherUserId ===');
  //
  //     // Start periodic updates for messages
  //     _startMessagesTimer(otherUserId);
  //
  //   } catch (e) {
  //     errorMessage.value = 'Failed to load messages: $e';
  //     print('=== Error fetching messages: $e ===');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Select a user for chatting
  void selectUser(ChatUser user) {
    selectedUser.value = user;
    messages.clear();

    // Reset unread count for this user
    unreadCounts[user.id] = 0;

    // Fetch messages for this user
    fetchMessages(user.id);
  }

  // Send a message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || selectedUser.value == null) return;

    try {
      final int? userId = await SharedPrefsHelper.getUserId();
      if (userId == null) throw Exception('User ID not found');

      // Create optimistic message
      final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
      final optimisticMessage = ChatMessage(
        from: 'sender',
        content: content.trim(),
        createdAt: DateTime.now().toIso8601String(),
        tempId: tempId,
        status: MessageStatus.sending,
      );

      // Add optimistic message
      messages.add(optimisticMessage);

      // Send to server
      final success = await _chatRepository.sendMessage(
        receiverId: selectedUser.value!.id,
        content: content.trim(),
      );

      if (success) {
        // Update message status to sent
        final index = messages.indexWhere((msg) => msg.tempId == tempId);
        if (index != -1) {
          messages[index] = messages[index].copyWith(status: MessageStatus.sent);
        }

        // Refresh messages to get server ID
        await fetchMessages(selectedUser.value!.id);
      } else {
        throw Exception('Failed to send message');
      }

    } catch (e) {
      print('=== Error sending message: $e ===');

      // Update message status to failed
      final index = messages.indexWhere((msg) =>
      msg.tempId != null && msg.status == MessageStatus.sending);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: MessageStatus.failed);
      }

      errorMessage.value = 'Failed to send message: $e';
    }
  }

  // Retry failed message
  Future<void> retryMessage(ChatMessage message) async {
    if (selectedUser.value == null) return;

    try {
      // Update status to sending
      final index = messages.indexWhere((msg) => msg.tempId == message.tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: MessageStatus.sending);
      }

      // Retry sending
      final success = await _chatRepository.sendMessage(
        receiverId: selectedUser.value!.id,
        content: message.content,
      );

      if (success) {
        // Update status to sent
        if (index != -1) {
          messages[index] = messages[index].copyWith(status: MessageStatus.sent);
        }

        // Refresh messages
        await fetchMessages(selectedUser.value!.id);
      } else {
        throw Exception('Failed to retry message');
      }

    } catch (e) {
      print('=== Error retrying message: $e ===');

      // Update status to failed
      final index = messages.indexWhere((msg) => msg.tempId == message.tempId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: MessageStatus.failed);
      }
    }
  }

  // Get unread count for a user
  int getUnreadCount(int userId) {
    return unreadCounts[userId] ?? 0;
  }

  // Timer methods for real-time updates
  void _startConnectionsTimer() {
    _connectionsTimer?.cancel();
    _connectionsTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (!_isFetching) {
        fetchConnections();
      }
    });
  }

  void _startMessagesTimer(int otherUserId) {
    _messagesTimer?.cancel();
    _messagesTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (selectedUser.value?.id == otherUserId && !isLoading.value) {
        fetchMessages(otherUserId);
      }
    });
  }

  // Stop message timer when leaving chat
  void stopMessagesTimer() {
    _messagesTimer?.cancel();
  }

  // Clear all data
  void clearData() {
    connections.clear();
    messages.clear();
    selectedUser.value = null;
    unreadCounts.clear();
    _stopTimers();
  }

  // Test method for debugging
  Future<void> testApis() async {
    try {
      print('=== Testing Chat APIs ===');
      await _chatRepository.testAllApis();
    } catch (e) {
      print('=== Test Error: $e ===');
    }
  }
}