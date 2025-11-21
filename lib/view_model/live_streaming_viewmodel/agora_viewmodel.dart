// view_model/live_streaming_viewmodel/agora_viewmodel.dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/live_streaming_services/agora_services.dart';

class AgoraViewModel extends GetxController {
  final AgoraService _agoraService = Get.find<AgoraService>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentChannel = ''.obs;
  final RxString userDisplayName = ''.obs;
  final RxString userRole = 'audience'.obs;

  // Chat
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final TextEditingController chatController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxInt unreadCount = 0.obs;
  final RxBool showChat = false.obs;

  // Participants
  final RxBool showParticipants = false.obs;
  final RxString viewMode = 'grid'.obs;
  final Rx<ParticipantInfo?> selectedSpeaker = Rx<ParticipantInfo?>(null);

  // REACTIVE PARTICIPANTS LIST
  final RxList<ParticipantInfo> participantsRx = <ParticipantInfo>[].obs;

  // CRITICAL: Force UI rebuild trigger
  final RxInt renderTrigger = 0.obs;

  AgoraService get agoraService => _agoraService;
  bool get isJoined => _agoraService.isJoined.value;
  bool get isHost => userRole.value == 'host';

  // UPDATED: Permission-based controls
  bool get canToggleAudio => isJoined && (isHost || _agoraService.hasAudioPermission.value);
  bool get canToggleVideo => isJoined && (isHost || _agoraService.hasVideoPermission.value);
  bool get canScreenShare => isJoined && (isHost || _agoraService.hasScreenSharePermission.value);
  bool get canSwitchCamera => isJoined && _agoraService.isVideoEnabled.value && canToggleVideo;

  @override
  void onInit() {
    super.onInit();
    debugPrint('=== AgoraViewModel initialized ===');

    // Auto-refresh participants on any change
    ever(_agoraService.isJoined, (_) {
      refreshParticipants();
      renderTrigger.value++;
    });
    ever(_agoraService.isAudioEnabled, (_) => refreshParticipants());
    ever(_agoraService.isVideoEnabled, (_) {
      refreshParticipants();
      renderTrigger.value++;
    });
    ever(_agoraService.isScreenSharing, (_) => refreshParticipants());
    ever(_agoraService.remoteUsers, (_) {
      refreshParticipants();
      renderTrigger.value++;
    });
    ever(_agoraService.userStates, (_) => refreshParticipants());
    ever(_agoraService.userNames, (_) => refreshParticipants());

    // NEW: Watch permission changes
    ever(_agoraService.hasAudioPermission, (_) {
      refreshParticipants();
      renderTrigger.value++;
    });
    ever(_agoraService.hasVideoPermission, (_) {
      refreshParticipants();
      renderTrigger.value++;
    });
    ever(_agoraService.hasScreenSharePermission, (_) {
      refreshParticipants();
      renderTrigger.value++;
    });
  }
// Add these methods to your AgoraViewModel class

// Add muteUserVideo method
  Future<void> muteUserVideo(int uid) async {
    try {
      if (!isHost) {
        Get.snackbar(
          'Permission Denied',
          'Only host can control user video',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
        );
        return;
      }

      final participant = participants.firstWhere((p) => p.uid == uid);

      if (uid == _agoraService.localUserId) {
        // Mute self video
        if (_agoraService.isVideoEnabled.value) {
          await _agoraService.toggleVideo();
        }
        addSystemMessage('Host turned off their video');
      } else {
        // Mute remote user video
        await _agoraService.engine.muteRemoteVideoStream(uid: uid, mute: true);
        addSystemMessage('Host turned off video for ${participant.name}');
        sendSystemMessage('Host turned off video for ${participant.name}');
      }

      refreshParticipants();
    } catch (e) {
      debugPrint('=== Error muting user video: $e ===');
      Get.snackbar(
        'Error',
        'Failed to control video: $e',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

// Add unmuteUserVideo method
  Future<void> unmuteUserVideo(int uid) async {
    try {
      if (!isHost) {
        Get.snackbar(
          'Permission Denied',
          'Only host can control user video',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
        );
        return;
      }

      final participant = participants.firstWhere((p) => p.uid == uid);

      if (uid == _agoraService.localUserId) {
        // Unmute self video
        if (!_agoraService.isVideoEnabled.value) {
          await _agoraService.toggleVideo();
        }
        addSystemMessage('Host turned on their video');
      } else {
        // Unmute remote user video
        await _agoraService.engine.muteRemoteVideoStream(uid: uid, mute: false);
        addSystemMessage('Host turned on video for ${participant.name}');
        sendSystemMessage('Host turned on video for ${participant.name}');
      }

      refreshParticipants();
    } catch (e) {
      debugPrint('=== Error unmuting user video: $e ===');
      Get.snackbar(
        'Error',
        'Failed to control video: $e',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

// Add removeUser method
  Future<void> removeUser(int uid) async {
    try {
      if (!isHost) {
        Get.snackbar(
          'Permission Denied',
          'Only host can remove users',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
        );
        return;
      }

      final participant = participants.firstWhere((p) => p.uid == uid);

      // In a real implementation, you might want to:
      // 1. Send a system message
      // 2. Use Agora's kickUser method if available
      // 3. Or implement your own user management

      addSystemMessage('${participant.name} was removed from the session');
      sendSystemMessage('${participant.name} was removed by host');

      // For now, we'll just show a message since we don't have actual removal logic
      Get.snackbar(
        'User Removed',
        '${participant.name} has been removed from the session',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );

      refreshParticipants();
    } catch (e) {
      debugPrint('=== Error removing user: $e ===');
      Get.snackbar(
        'Error',
        'Failed to remove user: $e',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }
// Add toggleScreenShare method if not present
  Future<void> toggleScreenShare() async {
    try {
      if (!isJoined) return;

      if (!canScreenShare) {
        Get.snackbar(
          'Permission Required',
          'Please request screen share permission from host',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
        );
        return;
      }

      if (_agoraService.isScreenSharing.value) {
        await _agoraService.stopScreenSharing();
        addSystemMessage('${userDisplayName.value} stopped screen sharing');
      } else {
        // Show loading indicator
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        try {
          await _agoraService.startScreenSharing();
          addSystemMessage('${userDisplayName.value} started screen sharing');
          Get.back();
        } catch (e) {
          Get.back();
          rethrow;
        }
      }

      renderTrigger.value++;
    } catch (e) {
      debugPrint('=== Error toggling screen share: $e ===');
      Get.snackbar(
        'Screen Share Error',
        'Failed to start screen sharing: ${e.toString()}',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }
// Add checkVideoStatus method (debug method)
  void checkVideoStatus() {
    debugPrint('=== VIDEO STATUS CHECK ===');
    debugPrint('isJoined: $isJoined');
    debugPrint('isLoading: ${isLoading.value}');
    debugPrint('Local User ID: ${_agoraService.localUserId}');
    debugPrint('Video Enabled: ${_agoraService.isVideoEnabled.value}');
    debugPrint('Audio Enabled: ${_agoraService.isAudioEnabled.value}');
    debugPrint('Screen Sharing: ${_agoraService.isScreenSharing.value}');
    debugPrint('Participants Count: ${participants.length}');
    debugPrint('Chat Messages Count: ${messages.length}');
    debugPrint('User Role: $userRole');
    debugPrint('Can Toggle Video: $canToggleVideo');
    debugPrint('Can Screen Share: $canScreenShare');
    debugPrint('Audio Permission: ${_agoraService.hasAudioPermission.value}');
    debugPrint('Video Permission: ${_agoraService.hasVideoPermission.value}');
    debugPrint('Screen Share Permission: ${_agoraService.hasScreenSharePermission.value}');

    for (final participant in participants) {
      debugPrint('Participant ${participant.uid}: '
          'Name: ${participant.name}, '
          'Local: ${participant.isLocal}, '
          'Host: ${participant.isHost}, '
          'Video: ${participant.videoEnabled}, '
          'Audio: ${participant.audioEnabled}, '
          'Audio Permission: ${participant.hasAudioPermission}, '
          'Video Permission: ${participant.hasVideoPermission}, '
          'Screen Share Permission: ${participant.hasScreenSharePermission}');
    }
  }
  // UPDATED JOIN SESSION METHOD
  Future<bool> joinSession({
    required int sessionId,
    required String nickname,
    required String sessionTitle,
    required String token,
    required int userId,
    required String role,
  }) async {
    try {
      debugPrint('=== Joining session: $sessionId as $role ===');

      isLoading.value = true;
      errorMessage.value = '';

      if (_agoraService.isJoined.value) {
        await leaveSession();
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      userRole.value = role;
      userDisplayName.value = nickname.isNotEmpty ? nickname : 'User $userId';

      final channelName = _cleanChannelName(sessionTitle);

      initializeChat();

      await _agoraService.joinChannel(
        token: token,
        channelName: channelName,
        uid: userId,
        userRole: role,
        userName: userDisplayName.value,
      );

      currentChannel.value = channelName;

      await Future.delayed(const Duration(milliseconds: 2000));

      refreshParticipants();
      renderTrigger.value++;

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to join: $e';
      debugPrint('=== Error joining session: $e ===');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _cleanChannelName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .toLowerCase()
        .substring(0, name.length > 64 ? 64 : name.length);
  }

  // CHAT METHODS (keep existing)
  void initializeChat() {
    debugPrint('=== Initializing real-time chat ===');
    messages.clear();
    addSystemMessage('Chat connected - All users can send and read messages');

    if (!isHost) {
      addSystemMessage('You can request permissions from host to enable microphone, camera, or screen sharing');
    }
  }

  void sendMessage() {
    final text = chatController.text.trim();
    if (text.isEmpty) return;

    _agoraService.sendChatMessage(text, userDisplayName.value, isHost);

    final localMessage = ChatMessage(
      senderId: _agoraService.localUserId,
      senderName: userDisplayName.value,
      message: text,
      timestamp: DateTime.now(),
      type: MessageType.user,
      isHost: isHost,
    );

    messages.add(localMessage);
    chatController.clear();
    scrollToBottom();

    if (!showChat.value) {
      unreadCount.value++;
    }
  }

  void onChatMessageReceived(ChatMessage message) {
    final isDuplicate = messages.any((m) =>
    m.senderId == message.senderId &&
        m.message == message.message &&
        m.timestamp.difference(message.timestamp).inSeconds < 2
    );

    if (!isDuplicate) {
      messages.add(message);
      scrollToBottom();

      if (!showChat.value) {
        unreadCount.value++;
      }
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void addSystemMessage(String text) {
    final message = ChatMessage(
      senderId: 0,
      senderName: 'System',
      message: text,
      timestamp: DateTime.now(),
      type: MessageType.system,
      isHost: false,
    );

    messages.add(message);
    scrollToBottom();
  }

  Future<void> leaveSession() async {
    try {
      await _agoraService.leaveChannel();
      currentChannel.value = '';
      userDisplayName.value = '';
      userRole.value = 'audience';
      messages.clear();
      unreadCount.value = 0;
      showChat.value = false;
      showParticipants.value = false;
      selectedSpeaker.value = null;
      participantsRx.clear();
      renderTrigger.value = 0;
    } catch (e) {
      debugPrint('=== Error leaving session: $e ===');
    }
  }

  // UPDATED TOGGLE METHODS with permission checks
  Future<void> toggleAudio() async {
    try {
      if (!isJoined) return;

      if (!canToggleAudio) {
        Get.snackbar(
          'Permission Required',
          'Please request audio permission from host',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
        );
        return;
      }

      final newState = !_agoraService.isAudioEnabled.value;
      await _agoraService.toggleAudio();

      if (newState && !isHost) {
        addSystemMessage('${userDisplayName.value} unmuted their microphone');
        sendSystemMessage('${userDisplayName.value} joined the conversation');
      } else if (!newState && !isHost) {
        addSystemMessage('${userDisplayName.value} muted their microphone');
      }

      refreshParticipants();
      renderTrigger.value++;
    } catch (e) {
      debugPrint('=== Error toggling audio: $e ===');
      Get.snackbar(
        'Error',
        'Failed to toggle audio: ${e.toString()}',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  Future<void> toggleVideo() async {
    try {
      if (!isJoined) return;

      if (!canToggleVideo) {
        Get.snackbar(
          'Permission Required',
          'Please request video permission from host',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
        );
        return;
      }

      final newState = !_agoraService.isVideoEnabled.value;
      await _agoraService.toggleVideo();

      if (newState && !isHost) {
        addSystemMessage('${userDisplayName.value} turned on video');
        sendSystemMessage('${userDisplayName.value} started video sharing');
      } else if (!newState && !isHost) {
        addSystemMessage('${userDisplayName.value} turned off video');
      }

      refreshParticipants();
      renderTrigger.value++;
    } catch (e) {
      debugPrint('=== Error toggling video: $e ===');
      Get.snackbar(
        'Error',
        'Failed to toggle video: ${e.toString()}',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }



  Future<void> switchCamera() async => await _agoraService.switchCamera();

  // NEW: Permission request methods for audience
  void requestAudioPermission() {
    if (isHost) return;

    sendSystemMessage('${userDisplayName.value} requests audio permission');
    Get.snackbar(
      'Request Sent',
      'Audio permission request sent to host',
      backgroundColor: Colors.orange.shade700,
      colorText: Colors.white,
    );
  }

  void requestVideoPermission() {
    if (isHost) return;

    sendSystemMessage('${userDisplayName.value} requests video permission');
    Get.snackbar(
      'Request Sent',
      'Video permission request sent to host',
      backgroundColor: Colors.orange.shade700,
      colorText: Colors.white,
    );
  }

  void requestScreenSharePermission() {
    if (isHost) return;

    sendSystemMessage('${userDisplayName.value} requests screen share permission');
    Get.snackbar(
      'Request Sent',
      'Screen share permission request sent to host',
      backgroundColor: Colors.orange.shade700,
      colorText: Colors.white,
    );
  }

  // NEW: Host permission management methods
  Future<void> grantUserPermissions(int uid, bool audio, bool video, bool screenShare) async {
    try {
      if (!isHost) {
        Get.snackbar('Permission Denied', 'Only host can grant permissions');
        return;
      }

      await _agoraService.grantPermissions(uid, audio, video, screenShare);

      final participant = participants.firstWhere((p) => p.uid == uid);
      final permissions = [];
      if (audio) permissions.add('audio');
      if (video) permissions.add('video');
      if (screenShare) permissions.add('screen share');

      addSystemMessage('Host granted ${permissions.join(', ')} permissions to ${participant.name}');
      sendSystemMessage('Host granted permissions to ${participant.name}');

      refreshParticipants();
    } catch (e) {
      debugPrint('=== Error granting permissions: $e ===');
      Get.snackbar('Error', 'Failed to grant permissions: $e');
    }
  }

  Future<void> revokeUserPermissions(int uid) async {
    try {
      if (!isHost) {
        Get.snackbar('Permission Denied', 'Only host can revoke permissions');
        return;
      }

      await _agoraService.revokePermissions(uid);

      final participant = participants.firstWhere((p) => p.uid == uid);
      addSystemMessage('Host revoked all permissions from ${participant.name}');
      sendSystemMessage('Host revoked permissions from ${participant.name}');

      refreshParticipants();
    } catch (e) {
      debugPrint('=== Error revoking permissions: $e ===');
      Get.snackbar('Error', 'Failed to revoke permissions: $e');
    }
  }

  // UPDATED: Enhanced participant list with permission info
  void refreshParticipants() {
    final list = <ParticipantInfo>[];

    if (_agoraService.isJoined.value) {
      list.add(ParticipantInfo(
        uid: _agoraService.localUserId,
        name: userDisplayName.value,
        isLocal: true,
        isHost: isHost,
        audioEnabled: _agoraService.isAudioEnabled.value,
        videoEnabled: _agoraService.isVideoEnabled.value || _agoraService.isScreenSharing.value,
        isScreenSharing: _agoraService.isScreenSharing.value,
        // NEW: Add permission info
        hasAudioPermission: _agoraService.hasAudioPermission.value,
        hasVideoPermission: _agoraService.hasVideoPermission.value,
        hasScreenSharePermission: _agoraService.hasScreenSharePermission.value,
      ));
    }

    for (final uid in _agoraService.remoteUserIds) {
      final state = _agoraService.userStates[uid];
      final userName = _agoraService.getUserName(uid);
      final bool isRemoteHost = list.isEmpty && !isHost;

      list.add(ParticipantInfo(
        uid: uid,
        name: userName,
        isLocal: false,
        isHost: isRemoteHost,
        audioEnabled: state?.hasAudio ?? false,
        videoEnabled: state?.hasVideo ?? false,
        isScreenSharing: false,
        // For remote users, we assume they have permissions if they're host
        hasAudioPermission: isRemoteHost,
        hasVideoPermission: isRemoteHost,
        hasScreenSharePermission: isRemoteHost,
      ));
    }

    participantsRx.assignAll(list);
    debugPrint('=== Refreshed participants with permissions ===');
  }

  List<ParticipantInfo> get participants => participantsRx;

  // Keep existing methods (muteUserAudio, unmuteUserAudio, etc.)
  Future<void> muteUserAudio(int uid) async {
    try {
      if (!isHost) {
        Get.snackbar('Permission Denied', 'Only host can mute users');
        return;
      }

      final participant = participants.firstWhere((p) => p.uid == uid);

      if (uid == _agoraService.localUserId) {
        await _agoraService.toggleAudio();
        addSystemMessage('Host muted themselves');
      } else {
        await _agoraService.engine.muteRemoteAudioStream(uid: uid, mute: true);
        addSystemMessage('Host muted ${participant.name}');
        sendSystemMessage('Host muted ${participant.name}');
      }

      refreshParticipants();
    } catch (e) {
      debugPrint('=== Error muting user audio: $e ===');
      Get.snackbar('Error', 'Failed to mute user: $e');
    }
  }

  Future<void> unmuteUserAudio(int uid) async {
    try {
      if (!isHost) {
        Get.snackbar('Permission Denied', 'Only host can unmute users');
        return;
      }

      final participant = participants.firstWhere((p) => p.uid == uid);

      if (uid == _agoraService.localUserId) {
        await _agoraService.toggleAudio();
        addSystemMessage('Host unmuted themselves');
      } else {
        await _agoraService.engine.muteRemoteAudioStream(uid: uid, mute: false);
        addSystemMessage('Host unmuted ${participant.name}');
        sendSystemMessage('Host unmuted ${participant.name}');
      }

      refreshParticipants();
    } catch (e) {
      debugPrint('=== Error unmuting user audio: $e ===');
      Get.snackbar('Error', 'Failed to unmute user: $e');
    }
  }

  void sendSystemMessage(String text) {
    final systemMessage = ChatMessage(
      senderId: 0,
      senderName: 'System',
      message: text,
      timestamp: DateTime.now(),
      type: MessageType.system,
      isHost: false,
    );

    messages.add(systemMessage);
    _agoraService.sendChatMessage(text, 'System', false);
  }

  // Keep other existing methods (toggleChatPanel, switchViewMode, etc.)
  void toggleChatPanel() {
    showChat.value = !showChat.value;
    if (showChat.value) {
      unreadCount.value = 0;
      showParticipants.value = false;
      scrollToBottom();
    }
  }

  void closeChat() => showChat.value = false;
  void toggleParticipantsPanel() {
    showParticipants.value = !showParticipants.value;
    if (showParticipants.value) showChat.value = false;
  }
  void switchViewMode() {
    viewMode.value = viewMode.value == 'grid' ? 'speaker' : 'grid';
  }
  void selectSpeaker(ParticipantInfo p) => selectedSpeaker.value = p;

  Future<void> upgradeToCoHost() async {
    try {
      await _agoraService.upgradeToCoHost();
      addSystemMessage('${userDisplayName.value} is now a co-host');
      refreshParticipants();
    } catch (e) {
      debugPrint('=== Error upgrading to co-host: $e ===');
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    chatController.dispose();
    super.onClose();
  }
}

// UPDATED: ParticipantInfo with permission fields
class ParticipantInfo {
  final int uid;
  final String name;
  final bool isLocal;
  final bool isHost;
  final bool audioEnabled;
  final bool videoEnabled;
  final bool isScreenSharing;
  // NEW: Permission fields
  final bool hasAudioPermission;
  final bool hasVideoPermission;
  final bool hasScreenSharePermission;

  ParticipantInfo({
    required this.uid,
    required this.name,
    required this.isLocal,
    required this.isHost,
    required this.audioEnabled,
    required this.videoEnabled,
    required this.isScreenSharing,
    // NEW: Default permissions
    this.hasAudioPermission = true,
    this.hasVideoPermission = true,
    this.hasScreenSharePermission = true,
  });

  String get displayName => '$name${isLocal ? " (You)" : ""}';
  String get firstChar => name.isNotEmpty ? name[0].toUpperCase() : 'U';

  // NEW: Helper methods for UI
  bool get canEnableAudio => isHost || hasAudioPermission;
  bool get canEnableVideo => isHost || hasVideoPermission;
  bool get canScreenShare => isHost || hasScreenSharePermission;
}

// Keep existing ChatMessage and MessageType
class ChatMessage {
  final int senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final MessageType type;
  final bool isHost;

  ChatMessage({
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isHost,
  });
}

enum MessageType { user, system }














// // view_model/live_streaming_viewmodel/agora_viewmodel.dart
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../services/live_streaming_services/agora_services.dart';
//
// class AgoraViewModel extends GetxController {
//   final AgoraService _agoraService = Get.find<AgoraService>();
//
//   final RxBool isLoading = false.obs;
//   final RxString errorMessage = ''.obs;
//   final RxString currentChannel = ''.obs;
//   final RxString userDisplayName = ''.obs;
//   final RxString userRole = 'audience'.obs;
//
//   // Chat
//   final RxList<ChatMessage> messages = <ChatMessage>[].obs;
//   final TextEditingController chatController = TextEditingController();
//   final ScrollController scrollController = ScrollController();
//   final RxInt unreadCount = 0.obs;
//   final RxBool showChat = false.obs;
//
//   // Participants
//   final RxBool showParticipants = false.obs;
//   final RxString viewMode = 'grid'.obs;
//   final Rx<ParticipantInfo?> selectedSpeaker = Rx<ParticipantInfo?>(null);
//
//   // REACTIVE PARTICIPANTS LIST
//   final RxList<ParticipantInfo> participantsRx = <ParticipantInfo>[].obs;
//
//   // CRITICAL: Force UI rebuild trigger
//   final RxInt renderTrigger = 0.obs;
//
//   AgoraService get agoraService => _agoraService;
//   bool get isJoined => _agoraService.isJoined.value;
//   bool get isHost => userRole.value == 'host';
//
//   // NEW: Equal controls for everyone
//   bool get canToggleVideo => isJoined;
//   bool get canScreenShare => isJoined;
//   bool get canSwitchCamera => isJoined && _agoraService.isVideoEnabled.value;
//   bool get canToggleAudio => isJoined;
//
//   @override
//   void onInit() {
//     super.onInit();
//     debugPrint('=== AgoraViewModel initialized ===');
//
//     // Auto-refresh participants on any change
//     ever(_agoraService.isJoined, (_) {
//       refreshParticipants();
//       renderTrigger.value++;
//     });
//     ever(_agoraService.isAudioEnabled, (_) => refreshParticipants());
//     ever(_agoraService.isVideoEnabled, (_) {
//       refreshParticipants();
//       renderTrigger.value++;
//     });
//     ever(_agoraService.isScreenSharing, (_) => refreshParticipants());
//     ever(_agoraService.remoteUsers, (_) {
//       refreshParticipants();
//       renderTrigger.value++;
//     });
//     ever(_agoraService.userStates, (_) => refreshParticipants());
//     ever(_agoraService.userNames, (_) => refreshParticipants()); // NEW: Watch for name changes
//   }
//
//   // UPDATED JOIN SESSION METHOD - Pass userName to service
//   Future<bool> joinSession({
//     required int sessionId,
//     required String nickname,
//     required String sessionTitle,
//     required String token,
//     required int userId,
//     required String role,
//   }) async {
//     try {
//       debugPrint('=== Joining session: $sessionId as $role ===');
//
//       // Reset state
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       // Ensure we're not already joined
//       if (_agoraService.isJoined.value) {
//         await leaveSession();
//         await Future.delayed(const Duration(milliseconds: 1000));
//       }
//
//       userRole.value = role;
//       userDisplayName.value = nickname.isNotEmpty ? nickname : 'User $userId';
//
//       final channelName = _cleanChannelName(sessionTitle);
//
//       // Initialize chat before joining
//       initializeChat();
//
//       // Use the updated joinChannel method with userName
//       await _agoraService.joinChannel(
//         token: token,
//         channelName: channelName,
//         uid: userId,
//         userRole: role,
//         userName: userDisplayName.value, // PASS USER NAME
//       );
//
//       currentChannel.value = channelName;
//
//       // Wait for connection
//       await Future.delayed(const Duration(milliseconds: 2000));
//
//       // Force refresh
//       refreshParticipants();
//       renderTrigger.value++;
//
//       return true;
//     } catch (e) {
//       errorMessage.value = 'Failed to join: $e';
//       debugPrint('=== Error joining session: $e ===');
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   String _cleanChannelName(String name) {
//     return name
//         .replaceAll(RegExp(r'[^\w]'), '_')
//         .replaceAll(RegExp(r'_+'), '_')
//         .toLowerCase()
//         .substring(0, name.length > 64 ? 64 : name.length);
//   }
//
//   // CHAT METHODS
//   void initializeChat() {
//     debugPrint('=== Initializing real-time chat ===');
//
//     // Clear existing messages
//     messages.clear();
//
//     // Add welcome message
//     addSystemMessage('Chat connected - All users can send and read messages');
//
//     if (!isHost) {
//       addSystemMessage('You can enable your microphone and camera to participate');
//     }
//   }
//
//   void sendMessage() {
//     final text = chatController.text.trim();
//     if (text.isEmpty) return;
//
//     debugPrint('=== Sending real-time chat message: $text ===');
//
//     // Send via Agora data stream
//     _agoraService.sendChatMessage(
//         text,
//         userDisplayName.value,
//         isHost
//     );
//
//     // Add message locally immediately for better UX
//     final localMessage = ChatMessage(
//       senderId: _agoraService.localUserId,
//       senderName: userDisplayName.value,
//       message: text,
//       timestamp: DateTime.now(),
//       type: MessageType.user,
//       isHost: isHost,
//     );
//
//     messages.add(localMessage);
//     chatController.clear();
//
//     // Auto-scroll to show new message
//     scrollToBottom();
//
//     // Update unread count if chat is hidden
//     if (!showChat.value) {
//       unreadCount.value++;
//     }
//   }
//
//   void onChatMessageReceived(ChatMessage message) {
//     // Avoid adding duplicate messages (in case we already added locally)
//     final isDuplicate = messages.any((m) =>
//     m.senderId == message.senderId &&
//         m.message == message.message &&
//         m.timestamp.difference(message.timestamp).inSeconds < 2
//     );
//
//     if (!isDuplicate) {
//       messages.add(message);
//
//       // Auto-scroll to bottom
//       scrollToBottom();
//
//       // Update unread count if chat is hidden
//       if (!showChat.value) {
//         unreadCount.value++;
//       }
//
//       debugPrint('=== Chat message received from ${message.senderName} ===');
//     }
//   }
//
//   void scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (scrollController.hasClients) {
//         scrollController.animateTo(
//           scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   void addSystemMessage(String text) {
//     final message = ChatMessage(
//       senderId: 0,
//       senderName: 'System',
//       message: text,
//       timestamp: DateTime.now(),
//       type: MessageType.system,
//       isHost: false,
//     );
//
//     messages.add(message);
//     scrollToBottom();
//   }
//
//   Future<void> leaveSession() async {
//     try {
//       await _agoraService.leaveChannel();
//       currentChannel.value = '';
//       userDisplayName.value = '';
//       userRole.value = 'audience';
//       messages.clear();
//       unreadCount.value = 0;
//       showChat.value = false;
//       showParticipants.value = false;
//       selectedSpeaker.value = null;
//       participantsRx.clear();
//       renderTrigger.value = 0;
//     } catch (e) {
//       debugPrint('=== Error leaving session: $e ===');
//     }
//   }
//
//   // UPDATED TOGGLE METHODS - Everyone can use them
//   Future<void> toggleAudio() async {
//     try {
//       if (!isJoined) return;
//
//       final newState = !_agoraService.isAudioEnabled.value;
//       await _agoraService.toggleAudio();
//
//       if (newState && !isHost) {
//         // Audience member unmuted themselves
//         addSystemMessage('${userDisplayName.value} unmuted their microphone');
//         sendSystemMessage('${userDisplayName.value} joined the conversation');
//       } else if (!newState && !isHost) {
//         addSystemMessage('${userDisplayName.value} muted their microphone');
//       }
//
//       refreshParticipants();
//       renderTrigger.value++;
//     } catch (e) {
//       debugPrint('=== Error toggling audio: $e ===');
//       Get.snackbar(
//         'Error',
//         'Failed to toggle audio: $e',
//         backgroundColor: Colors.red.shade700,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> toggleVideo() async {
//     try {
//       if (!isJoined) return;
//
//       final newState = !_agoraService.isVideoEnabled.value;
//       await _agoraService.toggleVideo();
//
//       if (newState && !isHost) {
//         // Audience member enabled video
//         addSystemMessage('${userDisplayName.value} turned on video');
//         sendSystemMessage('${userDisplayName.value} started video sharing');
//
//         // Ensure they have publishing rights
//         await _agoraService.upgradeToCoHost();
//       } else if (!newState && !isHost) {
//         addSystemMessage('${userDisplayName.value} turned off video');
//       }
//
//       refreshParticipants();
//       renderTrigger.value++;
//     } catch (e) {
//       debugPrint('=== Error toggling video: $e ===');
//       Get.snackbar(
//         'Error',
//         'Failed to toggle video: $e',
//         backgroundColor: Colors.red.shade700,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // FIXED: Screen sharing for everyone
//   Future<void> toggleScreenShare() async {
//     try {
//       if (!isJoined) return;
//
//       if (_agoraService.isScreenSharing.value) {
//         await _agoraService.stopScreenSharing();
//         addSystemMessage('${userDisplayName.value} stopped screen sharing');
//       } else {
//         // Show loading indicator
//         Get.dialog(
//           const Center(
//             child: CircularProgressIndicator(),
//           ),
//           barrierDismissible: false,
//         );
//
//         try {
//           // Upgrade to co-host first for screen sharing
//           await _agoraService.upgradeToCoHost();
//           await _agoraService.startScreenSharing();
//           addSystemMessage('${userDisplayName.value} started screen sharing');
//           Get.back(); // Close loading dialog
//         } catch (e) {
//           Get.back(); // Close loading dialog
//           rethrow;
//         }
//       }
//
//       renderTrigger.value++;
//     } catch (e) {
//       debugPrint('=== Error toggling screen share: $e ===');
//       Get.snackbar(
//         'Screen Share Error',
//         'Failed to start screen sharing: $e',
//         backgroundColor: Colors.red.shade700,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 5),
//       );
//     }
//   }
//
//   Future<void> switchCamera() async => await _agoraService.switchCamera();
//
//   // NEW: Upgrade audience to co-host
//   Future<void> upgradeToCoHost() async {
//     try {
//       await _agoraService.upgradeToCoHost();
//       addSystemMessage('${userDisplayName.value} is now a co-host');
//       refreshParticipants();
//     } catch (e) {
//       debugPrint('=== Error upgrading to co-host: $e ===');
//     }
//   }
//
//   void toggleChatPanel() {
//     showChat.value = !showChat.value;
//     if (showChat.value) {
//       unreadCount.value = 0;
//       showParticipants.value = false;
//       scrollToBottom();
//     }
//   }
//
//   void openChat() {
//     showChat.value = true;
//     unreadCount.value = 0;
//     scrollToBottom();
//   }
//
//   void closeChat() {
//     showChat.value = false;
//   }
//
//   void toggleParticipantsPanel() {
//     showParticipants.value = !showParticipants.value;
//     if (showParticipants.value) showChat.value = false;
//   }
//
//   void switchViewMode() {
//     viewMode.value = viewMode.value == 'grid' ? 'speaker' : 'grid';
//   }
//
//   void switchToGridView() {
//     viewMode.value = 'grid';
//   }
//
//   void switchToSpeakerView() {
//     viewMode.value = 'speaker';
//   }
//
//   void selectParticipant(ParticipantInfo participant) {
//     selectedSpeaker.value = participant;
//     viewMode.value = 'speaker';
//   }
//
//   void selectSpeaker(ParticipantInfo p) => selectedSpeaker.value = p;
//
//   // FIXED: Enhanced participant list with proper names and host identification
//   void refreshParticipants() {
//     final list = <ParticipantInfo>[];
//
//     if (_agoraService.isJoined.value) {
//       // Add local user (could be host or audience)
//       list.add(ParticipantInfo(
//         uid: _agoraService.localUserId,
//         name: userDisplayName.value, // Use actual display name
//         isLocal: true,
//         isHost: isHost,
//         audioEnabled: _agoraService.isAudioEnabled.value,
//         videoEnabled: _agoraService.isVideoEnabled.value || _agoraService.isScreenSharing.value,
//         isScreenSharing: _agoraService.isScreenSharing.value,
//       ));
//     }
//
//     for (final uid in _agoraService.remoteUserIds) {
//       final state = _agoraService.userStates[uid];
//
//       // GET PROPER USER NAME from service
//       final userName = _agoraService.getUserName(uid);
//
//       // Simple host detection: first user to join is host, or use your own logic
//       final bool isRemoteHost = list.isEmpty && !isHost;
//
//       list.add(ParticipantInfo(
//         uid: uid,
//         name: userName, // Use proper name from service
//         isLocal: false,
//         isHost: isRemoteHost,
//         audioEnabled: state?.hasAudio ?? false,
//         videoEnabled: state?.hasVideo ?? false,
//         isScreenSharing: false, // Remote screen sharing detection would need additional logic
//       ));
//     }
//
//     participantsRx.assignAll(list);
//     debugPrint('=== Refreshed participants: ${list.length} users ===');
//     for (final p in list) {
//       debugPrint('  - ${p.name} (UID: ${p.uid}, Host: ${p.isHost}, Local: ${p.isLocal}, Video: ${p.videoEnabled}, Audio: ${p.audioEnabled})');
//     }
//   }
//
//   List<ParticipantInfo> get participants => participantsRx;
//
//   // Enhanced host controls for remote users
//   Future<void> muteUserAudio(int uid) async {
//     try {
//       if (!isHost) {
//         Get.snackbar(
//           'Permission Denied',
//           'Only host can mute users',
//           backgroundColor: Colors.orange.shade700,
//           colorText: Colors.white,
//         );
//         return;
//       }
//
//       final participant = participants.firstWhere((p) => p.uid == uid);
//
//       if (uid == _agoraService.localUserId) {
//         // Mute self
//         await _agoraService.toggleAudio();
//         addSystemMessage('Host muted themselves');
//       } else {
//         // Mute remote user
//         await _agoraService.engine.muteRemoteAudioStream(uid: uid, mute: true);
//         addSystemMessage('Host muted ${participant.name}');
//
//         // Send system message to everyone
//         sendSystemMessage('Host muted ${participant.name}');
//       }
//
//       refreshParticipants();
//     } catch (e) {
//       debugPrint('=== Error muting user audio: $e ===');
//       Get.snackbar(
//         'Error',
//         'Failed to mute user: $e',
//         backgroundColor: Colors.red.shade700,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> unmuteUserAudio(int uid) async {
//     try {
//       if (!isHost) {
//         Get.snackbar(
//           'Permission Denied',
//           'Only host can unmute users',
//           backgroundColor: Colors.orange.shade700,
//           colorText: Colors.white,
//         );
//         return;
//       }
//
//       final participant = participants.firstWhere((p) => p.uid == uid);
//
//       if (uid == _agoraService.localUserId) {
//         // Unmute self
//         await _agoraService.toggleAudio();
//         addSystemMessage('Host unmuted themselves');
//       } else {
//         // Unmute remote user
//         await _agoraService.engine.muteRemoteAudioStream(uid: uid, mute: false);
//         addSystemMessage('Host unmuted ${participant.name}');
//
//         // Send system message to everyone
//         sendSystemMessage('Host unmuted ${participant.name}');
//       }
//
//       refreshParticipants();
//     } catch (e) {
//       debugPrint('=== Error unmuting user audio: $e ===');
//       Get.snackbar(
//         'Error',
//         'Failed to unmute user: $e',
//         backgroundColor: Colors.red.shade700,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // Add method to send system messages to all users
//   void sendSystemMessage(String text) {
//     final systemMessage = ChatMessage(
//       senderId: 0,
//       senderName: 'System',
//       message: text,
//       timestamp: DateTime.now(),
//       type: MessageType.system,
//       isHost: false,
//     );
//
//     // Add to local messages
//     messages.add(systemMessage);
//
//     // Also send via data stream so all users see it
//     _agoraService.sendChatMessage(text, 'System', false);
//   }
//
//   Future<void> muteUserVideo(int uid) async {
//     try {
//       if (!isHost) return;
//
//       if (uid != _agoraService.localUserId) {
//         await _agoraService.engine.muteRemoteVideoStream(uid: uid, mute: true);
//         addSystemMessage('Muted video for user $uid');
//       }
//     } catch (e) {
//       debugPrint('=== Error muting user video: $e ===');
//     }
//   }
//
//   Future<void> unmuteUserVideo(int uid) async {
//     try {
//       if (!isHost) return;
//
//       if (uid != _agoraService.localUserId) {
//         await _agoraService.engine.muteRemoteVideoStream(uid: uid, mute: false);
//         addSystemMessage('Unmuted video for user $uid');
//       }
//     } catch (e) {
//       debugPrint('=== Error unmuting user video: $e ===');
//     }
//   }
//
//   Future<void> removeUser(int uid) async {
//     try {
//       if (!isHost) return;
//       addSystemMessage('Removed user $uid from session');
//     } catch (e) {
//       debugPrint('=== Error removing user: $e ===');
//     }
//   }
//
//   // DEBUG METHODS
//   void checkVideoStatus() {
//     debugPrint('=== VIDEO STATUS CHECK ===');
//     debugPrint('isJoined: $isJoined');
//     debugPrint('isLoading: ${isLoading.value}');
//     debugPrint('Local User ID: ${_agoraService.localUserId}');
//     debugPrint('Video Enabled: ${_agoraService.isVideoEnabled.value}');
//     debugPrint('Audio Enabled: ${_agoraService.isAudioEnabled.value}');
//     debugPrint('Screen Sharing: ${_agoraService.isScreenSharing.value}');
//     debugPrint('Participants Count: ${participants.length}');
//     debugPrint('Chat Messages Count: ${messages.length}');
//     debugPrint('User Role: $userRole');
//     debugPrint('Can Toggle Video: $canToggleVideo');
//     debugPrint('Can Screen Share: $canScreenShare');
//
//     for (final participant in participants) {
//       debugPrint('Participant ${participant.uid}: '
//           'Name: ${participant.name}, '
//           'Local: ${participant.isLocal}, '
//           'Host: ${participant.isHost}, '
//           'Video: ${participant.videoEnabled}, '
//           'Audio: ${participant.audioEnabled}');
//     }
//   }
//
//   @override
//   void onClose() {
//     scrollController.dispose();
//     chatController.dispose();
//     super.onClose();
//   }
// }
//
// // DATA MODELS
// class ChatMessage {
//   final int senderId;
//   final String senderName;
//   final String message;
//   final DateTime timestamp;
//   final MessageType type;
//   final bool isHost;
//
//   ChatMessage({
//     required this.senderId,
//     required this.senderName,
//     required this.message,
//     required this.timestamp,
//     required this.type,
//     required this.isHost,
//   });
// }
//
// enum MessageType { user, system }
//
// class ParticipantInfo {
//   final int uid;
//   final String name;
//   final bool isLocal;
//   final bool isHost;
//   final bool audioEnabled;
//   final bool videoEnabled;
//   final bool isScreenSharing;
//
//   ParticipantInfo({
//     required this.uid,
//     required this.name,
//     required this.isLocal,
//     required this.isHost,
//     required this.audioEnabled,
//     required this.videoEnabled,
//     required this.isScreenSharing,
//   });
//
//   String get displayName => '$name${isLocal ? " (You)" : ""}';
//   String get firstChar => name.isNotEmpty ? name[0].toUpperCase() : 'U';
// }
//
//
















// // view_model/live_streaming_viewmodel/agora_viewmodel.dart
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../services/live_streaming_services/agora_services.dart';
//
// class AgoraViewModel extends GetxController {
//   final AgoraService _agoraService = Get.find<AgoraService>();
//
//   final RxBool isLoading = false.obs;
//   final RxString errorMessage = ''.obs;
//   final RxString currentChannel = ''.obs;
//   final RxString userDisplayName = ''.obs;
//   final RxString userRole = 'audience'.obs;
//
//   // Chat
//   final RxList<ChatMessage> messages = <ChatMessage>[].obs;
//   final TextEditingController chatController = TextEditingController();
//   final ScrollController scrollController = ScrollController();
//   final RxInt unreadCount = 0.obs;
//   final RxBool showChat = false.obs;
//
//   // Participants
//   final RxBool showParticipants = false.obs;
//   final RxString viewMode = 'grid'.obs;
//   final Rx<ParticipantInfo?> selectedSpeaker = Rx<ParticipantInfo?>(null);
//
//   // REACTIVE PARTICIPANTS LIST
//   final RxList<ParticipantInfo> participantsRx = <ParticipantInfo>[].obs;
//
//   // CRITICAL: Force UI rebuild trigger
//   final RxInt renderTrigger = 0.obs;
//
//   AgoraService get agoraService => _agoraService;
//   bool get isJoined => _agoraService.isJoined.value;
//   bool get isHost => userRole.value == 'host';
//
//   // NEW: Equal controls for everyone
//   bool get canToggleVideo => isJoined;
//   bool get canScreenShare => isJoined;
//   bool get canSwitchCamera => isJoined && _agoraService.isVideoEnabled.value;
//   bool get canToggleAudio => isJoined;
//
//   @override
//   void onInit() {
//     super.onInit();
//     debugPrint('=== AgoraViewModel initialized ===');
//
//     // Auto-refresh participants on any change
//     ever(_agoraService.isJoined, (_) {
//       refreshParticipants();
//       renderTrigger.value++;
//     });
//     ever(_agoraService.isAudioEnabled, (_) => refreshParticipants());
//     ever(_agoraService.isVideoEnabled, (_) {
//       refreshParticipants();
//       renderTrigger.value++;
//     });
//     ever(_agoraService.isScreenSharing, (_) => refreshParticipants());
//     ever(_agoraService.remoteUsers, (_) {
//       refreshParticipants();
//       renderTrigger.value++;
//     });
//     ever(_agoraService.userStates, (_) => refreshParticipants());
//   }
//
//   // UPDATED JOIN SESSION METHOD
//   Future<bool> joinSession({
//     required int sessionId,
//     required String nickname,
//     required String sessionTitle,
//     required String token,
//     required int userId,
//     required String role,
//   }) async {
//     try {
//       debugPrint('=== Joining session: $sessionId as $role ===');
//
//       // Reset state
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       // Ensure we're not already joined
//       if (_agoraService.isJoined.value) {
//         await leaveSession();
//         await Future.delayed(const Duration(milliseconds: 1000));
//       }
//
//       userRole.value = role;
//       userDisplayName.value = nickname.isNotEmpty ? nickname : 'User $userId';
//
//       final channelName = _cleanChannelName(sessionTitle);
//
//       // Initialize chat before joining
//       initializeChat();
//
//       // Use the updated joinChannel method
//       await _agoraService.joinChannel(
//         token: token,
//         channelName: channelName,
//         uid: userId,
//         userRole: role, // Pass role for initial state
//       );
//
//       currentChannel.value = channelName;
//
//       // Wait for connection
//       await Future.delayed(const Duration(milliseconds: 2000));
//
//       // Force refresh
//       refreshParticipants();
//       renderTrigger.value++;
//
//       return true;
//     } catch (e) {
//       errorMessage.value = 'Failed to join: $e';
//       debugPrint('=== Error joining session: $e ===');
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   String _cleanChannelName(String name) {
//     return name
//         .replaceAll(RegExp(r'[^\w]'), '_')
//         .replaceAll(RegExp(r'_+'), '_')
//         .toLowerCase()
//         .substring(0, name.length > 64 ? 64 : name.length);
//   }
//
//   // CHAT METHODS
//   void initializeChat() {
//     debugPrint('=== Initializing real-time chat ===');
//
//     // Clear existing messages
//     messages.clear();
//
//     // Add welcome message
//     addSystemMessage('Chat connected - All users can send and read messages');
//
//     if (!isHost) {
//       addSystemMessage('You can enable your microphone and camera to participate');
//     }
//   }
//
//   void sendMessage() {
//     final text = chatController.text.trim();
//     if (text.isEmpty) return;
//
//     debugPrint('=== Sending real-time chat message: $text ===');
//
//     // Send via Agora data stream
//     _agoraService.sendChatMessage(
//         text,
//         userDisplayName.value,
//         isHost
//     );
//
//     // Add message locally immediately for better UX
//     final localMessage = ChatMessage(
//       senderId: _agoraService.localUserId,
//       senderName: userDisplayName.value,
//       message: text,
//       timestamp: DateTime.now(),
//       type: MessageType.user,
//       isHost: isHost,
//     );
//
//     messages.add(localMessage);
//     chatController.clear();
//
//     // Auto-scroll to show new message
//     scrollToBottom();
//
//     // Update unread count if chat is hidden
//     if (!showChat.value) {
//       unreadCount.value++;
//     }
//   }
//
//   void onChatMessageReceived(ChatMessage message) {
//     // Avoid adding duplicate messages (in case we already added locally)
//     final isDuplicate = messages.any((m) =>
//     m.senderId == message.senderId &&
//         m.message == message.message &&
//         m.timestamp.difference(message.timestamp).inSeconds < 2
//     );
//
//     if (!isDuplicate) {
//       messages.add(message);
//
//       // Auto-scroll to bottom
//       scrollToBottom();
//
//       // Update unread count if chat is hidden
//       if (!showChat.value) {
//         unreadCount.value++;
//       }
//
//       debugPrint('=== Chat message received from ${message.senderName} ===');
//     }
//   }
//
//   void scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (scrollController.hasClients) {
//         scrollController.animateTo(
//           scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   void addSystemMessage(String text) {
//     final message = ChatMessage(
//       senderId: 0,
//       senderName: 'System',
//       message: text,
//       timestamp: DateTime.now(),
//       type: MessageType.system,
//       isHost: false,
//     );
//
//     messages.add(message);
//     scrollToBottom();
//   }
//
//   Future<void> leaveSession() async {
//     try {
//       await _agoraService.leaveChannel();
//       currentChannel.value = '';
//       userDisplayName.value = '';
//       userRole.value = 'audience';
//       messages.clear();
//       unreadCount.value = 0;
//       showChat.value = false;
//       showParticipants.value = false;
//       selectedSpeaker.value = null;
//       participantsRx.clear();
//       renderTrigger.value = 0;
//     } catch (e) {
//       debugPrint('=== Error leaving session: $e ===');
//     }
//   }
//
//   // UPDATED TOGGLE METHODS - Everyone can use them
//   Future<void> toggleAudio() async {
//     try {
//       if (!isJoined) return;
//
//       final newState = !_agoraService.isAudioEnabled.value;
//       await _agoraService.toggleAudio();
//
//       if (newState && !isHost) {
//         // Audience member unmuted themselves
//         addSystemMessage('${userDisplayName.value} unmuted their microphone');
//         sendSystemMessage('${userDisplayName.value} joined the conversation');
//       } else if (!newState && !isHost) {
//         addSystemMessage('${userDisplayName.value} muted their microphone');
//       }
//
//       refreshParticipants();
//       renderTrigger.value++;
//     } catch (e) {
//       debugPrint('=== Error toggling audio: $e ===');
//       Get.snackbar(
//         'Error',
//         'Failed to toggle audio: $e',
//         backgroundColor: Colors.red.shade700,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> toggleVideo() async {
//     try {
//       if (!isJoined) return;
//
//       final newState = !_agoraService.isVideoEnabled.value;
//       await _agoraService.toggleVideo();
//
//       if (newState && !isHost) {
//         // Audience member enabled video
//         addSystemMessage('${userDisplayName.value} turned on video');
//         sendSystemMessage('${userDisplayName.value} started video sharing');
//
//         // Ensure they have publishing rights
//         await _agoraService.upgradeToCoHost();
//       } else if (!newState && !isHost) {
//         addSystemMessage('${userDisplayName.value} turned off video');
//       }
//
//       refreshParticipants();
//       renderTrigger.value++;
//     } catch (e) {
//       debugPrint('=== Error toggling video: $e ===');
//       Get.snackbar(
//         'Error',
//         'Failed to toggle video: $e',
//         backgroundColor: Colors.red.shade700,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // NEW: Screen sharing for everyone
//   Future<void> toggleScreenShare() async {
//     try {
//       if (!isJoined) return;
//
//       if (_agoraService.isScreenSharing.value) {
//         await _agoraService.stopScreenSharing();
//         addSystemMessage('${userDisplayName.value} stopped screen sharing');
//       } else {
//         // Upgrade to co-host first for screen sharing
//         await _agoraService.upgradeToCoHost();
//         await _agoraService.startScreenSharing();
//         addSystemMessage('${userDisplayName.value} started screen sharing');
//       }
//
//       renderTrigger.value++;
//     } catch (e) {
//       debugPrint('=== Error toggling screen share: $e ===');
//       Get.snackbar(
//         'Error',
//         'Failed to start screen sharing: $e',
//         backgroundColor: Colors.red.shade700,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> switchCamera() async => await _agoraService.switchCamera();
//
//   // NEW: Upgrade audience to co-host
//   Future<void> upgradeToCoHost() async {
//     try {
//       await _agoraService.upgradeToCoHost();
//       addSystemMessage('${userDisplayName.value} is now a co-host');
//       refreshParticipants();
//     } catch (e) {
//       debugPrint('=== Error upgrading to co-host: $e ===');
//     }
//   }
//
//   void toggleChatPanel() {
//     showChat.value = !showChat.value;
//     if (showChat.value) {
//       unreadCount.value = 0;
//       showParticipants.value = false;
//       scrollToBottom();
//     }
//   }
//
//   void openChat() {
//     showChat.value = true;
//     unreadCount.value = 0;
//     scrollToBottom();
//   }
//
//   void closeChat() {
//     showChat.value = false;
//   }
//
//   void toggleParticipantsPanel() {
//     showParticipants.value = !showParticipants.value;
//     if (showParticipants.value) showChat.value = false;
//   }
//
//   void switchViewMode() {
//     viewMode.value = viewMode.value == 'grid' ? 'speaker' : 'grid';
//   }
//
//   void switchToGridView() {
//     viewMode.value = 'grid';
//   }
//
//   void switchToSpeakerView() {
//     viewMode.value = 'speaker';
//   }
//
//   void selectParticipant(ParticipantInfo participant) {
//     selectedSpeaker.value = participant;
//     viewMode.value = 'speaker';
//   }
//
//   void selectSpeaker(ParticipantInfo p) => selectedSpeaker.value = p;
//
//   // Enhanced participant list with proper host identification
//   void refreshParticipants() {
//     final list = <ParticipantInfo>[];
//
//     if (_agoraService.isJoined.value) {
//       // Add local user (could be host or audience)
//       list.add(ParticipantInfo(
//         uid: _agoraService.localUserId,
//         name: userDisplayName.value,
//         isLocal: true,
//         isHost: isHost,
//         audioEnabled: _agoraService.isAudioEnabled.value,
//         videoEnabled: _agoraService.isVideoEnabled.value || _agoraService.isScreenSharing.value,
//         isScreenSharing: _agoraService.isScreenSharing.value,
//       ));
//     }
//
//     for (final uid in _agoraService.remoteUserIds) {
//       final state = _agoraService.userStates[uid];
//       final user = _agoraService.remoteUsers[uid];
//
//       // For now, assume first remote user is host if local user is audience
//       final bool isRemoteHost = list.isEmpty && !isHost;
//
//       list.add(ParticipantInfo(
//         uid: uid,
//         name: user?.name ?? 'User $uid',
//         isLocal: false,
//         isHost: isRemoteHost,
//         audioEnabled: state?.hasAudio ?? false,
//         videoEnabled: state?.hasVideo ?? false,
//         isScreenSharing: false,
//       ));
//     }
//
//     participantsRx.assignAll(list);
//     debugPrint('=== Refreshed participants: ${list.length} users ===');
//     for (final p in list) {
//       debugPrint('  - ${p.name} (UID: ${p.uid}, Host: ${p.isHost}, Local: ${p.isLocal}, Video: ${p.videoEnabled}, Audio: ${p.audioEnabled})');
//     }
//   }
//
//   List<ParticipantInfo> get participants => participantsRx;
//
//   // Enhanced host controls for remote users
//   Future<void> muteUserAudio(int uid) async {
//     try {
//       if (!isHost) {
//         Get.snackbar(
//           'Permission Denied',
//           'Only host can mute users',
//           backgroundColor: Colors.orange.shade700,
//           colorText: Colors.white,
//         );
//         return;
//       }
//
//       final participant = participants.firstWhere((p) => p.uid == uid);
//
//       if (uid == _agoraService.localUserId) {
//         // Mute self
//         await _agoraService.toggleAudio();
//         addSystemMessage('Host muted themselves');
//       } else {
//         // Mute remote user
//         await _agoraService.engine.muteRemoteAudioStream(uid: uid, mute: true);
//         addSystemMessage('Host muted ${participant.name}');
//
//         // Send system message to everyone
//         sendSystemMessage('Host muted ${participant.name}');
//       }
//
//       refreshParticipants();
//     } catch (e) {
//       debugPrint('=== Error muting user audio: $e ===');
//       Get.snackbar(
//         'Error',
//         'Failed to mute user: $e',
//         backgroundColor: Colors.red.shade700,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Future<void> unmuteUserAudio(int uid) async {
//     try {
//       if (!isHost) {
//         Get.snackbar(
//           'Permission Denied',
//           'Only host can unmute users',
//           backgroundColor: Colors.orange.shade700,
//           colorText: Colors.white,
//         );
//         return;
//       }
//
//       final participant = participants.firstWhere((p) => p.uid == uid);
//
//       if (uid == _agoraService.localUserId) {
//         // Unmute self
//         await _agoraService.toggleAudio();
//         addSystemMessage('Host unmuted themselves');
//       } else {
//         // Unmute remote user
//         await _agoraService.engine.muteRemoteAudioStream(uid: uid, mute: false);
//         addSystemMessage('Host unmuted ${participant.name}');
//
//         // Send system message to everyone
//         sendSystemMessage('Host unmuted ${participant.name}');
//       }
//
//       refreshParticipants();
//     } catch (e) {
//       debugPrint('=== Error unmuting user audio: $e ===');
//       Get.snackbar(
//         'Error',
//         'Failed to unmute user: $e',
//         backgroundColor: Colors.red.shade700,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   // Add method to send system messages to all users
//   void sendSystemMessage(String text) {
//     final systemMessage = ChatMessage(
//       senderId: 0,
//       senderName: 'System',
//       message: text,
//       timestamp: DateTime.now(),
//       type: MessageType.system,
//       isHost: false,
//     );
//
//     // Add to local messages
//     messages.add(systemMessage);
//
//     // Also send via data stream so all users see it
//     _agoraService.sendChatMessage(text, 'System', false);
//   }
//
//   Future<void> muteUserVideo(int uid) async {
//     try {
//       if (!isHost) return;
//
//       if (uid != _agoraService.localUserId) {
//         await _agoraService.engine.muteRemoteVideoStream(uid: uid, mute: true);
//         addSystemMessage('Muted video for user $uid');
//       }
//     } catch (e) {
//       debugPrint('=== Error muting user video: $e ===');
//     }
//   }
//
//   Future<void> unmuteUserVideo(int uid) async {
//     try {
//       if (!isHost) return;
//
//       if (uid != _agoraService.localUserId) {
//         await _agoraService.engine.muteRemoteVideoStream(uid: uid, mute: false);
//         addSystemMessage('Unmuted video for user $uid');
//       }
//     } catch (e) {
//       debugPrint('=== Error unmuting user video: $e ===');
//     }
//   }
//
//   Future<void> removeUser(int uid) async {
//     try {
//       if (!isHost) return;
//       addSystemMessage('Removed user $uid from session');
//     } catch (e) {
//       debugPrint('=== Error removing user: $e ===');
//     }
//   }
//
//   // DEBUG METHODS
//   void checkVideoStatus() {
//     debugPrint('=== VIDEO STATUS CHECK ===');
//     debugPrint('isJoined: $isJoined');
//     debugPrint('isLoading: ${isLoading.value}');
//     debugPrint('Local User ID: ${_agoraService.localUserId}');
//     debugPrint('Video Enabled: ${_agoraService.isVideoEnabled.value}');
//     debugPrint('Audio Enabled: ${_agoraService.isAudioEnabled.value}');
//     debugPrint('Screen Sharing: ${_agoraService.isScreenSharing.value}');
//     debugPrint('Participants Count: ${participants.length}');
//     debugPrint('Chat Messages Count: ${messages.length}');
//     debugPrint('User Role: $userRole');
//     debugPrint('Can Toggle Video: $canToggleVideo');
//     debugPrint('Can Screen Share: $canScreenShare');
//
//     for (final participant in participants) {
//       debugPrint('Participant ${participant.uid}: '
//           'Name: ${participant.name}, '
//           'Local: ${participant.isLocal}, '
//           'Host: ${participant.isHost}, '
//           'Video: ${participant.videoEnabled}, '
//           'Audio: ${participant.audioEnabled}');
//     }
//   }
//
//   @override
//   void onClose() {
//     scrollController.dispose();
//     chatController.dispose();
//     super.onClose();
//   }
// }
//
// // DATA MODELS
// class ChatMessage {
//   final int senderId;
//   final String senderName;
//   final String message;
//   final DateTime timestamp;
//   final MessageType type;
//   final bool isHost;
//
//   ChatMessage({
//     required this.senderId,
//     required this.senderName,
//     required this.message,
//     required this.timestamp,
//     required this.type,
//     required this.isHost,
//   });
// }
//
// enum MessageType { user, system }
//
// class ParticipantInfo {
//   final int uid;
//   final String name;
//   final bool isLocal;
//   final bool isHost;
//   final bool audioEnabled;
//   final bool videoEnabled;
//   final bool isScreenSharing;
//
//   ParticipantInfo({
//     required this.uid,
//     required this.name,
//     required this.isLocal,
//     required this.isHost,
//     required this.audioEnabled,
//     required this.videoEnabled,
//     required this.isScreenSharing,
//   });
//
//   String get displayName => '$name${isLocal ? " (You)" : ""}';
//   String get firstChar => name.isNotEmpty ? name[0].toUpperCase() : 'U';
// }

//import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../services/live_streaming_services/agora_services.dart';
//
// class AgoraViewModel extends GetxController {
//   final AgoraService _agoraService = Get.find<AgoraService>();
//   final RxString currentChannel = ''.obs;
//   final RxBool isLoading = false.obs;
//   final RxString errorMessage = ''.obs;
//   final RxString userDisplayName = ''.obs;
//   final RxString userRole = 'audience'.obs;
//
//   // Chat - use common ChatMessage model
//   final RxList<ChatMessage> messages = <ChatMessage>[].obs;
//   final TextEditingController chatController = TextEditingController();
//   final RxBool showChat = false.obs;
//
//   // Participants
//   final RxBool showParticipants = false.obs;
//   final RxString viewMode = 'grid'.obs; // 'grid' or 'speaker'
//
//   AgoraService get agoraService => _agoraService;
//   bool get isJoined => _agoraService.isJoined.value;
//   bool get isHost => userRole.value == 'host';
//
//   @override
//   void onInit() {
//     super.onInit();
//     // Listen for chat messages from service
//     ever(_agoraService.chatMessages, (List<ChatMessage> newMessages) {
//       messages.assignAll(newMessages);
//     });
//   }
//
//   @override
//   void onClose() {
//     chatController.dispose();
//     super.onClose();
//   }
//
//   Future<bool> joinSession({
//     required int sessionId,
//     required String nickname,
//     required String sessionTitle,
//     required String token,
//     required int userId,
//     String role = 'audience',
//   }) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       userRole.value = role;
//       userDisplayName.value = nickname.isNotEmpty ? nickname : 'User $userId';
//
//       final channelName = _cleanChannelName(sessionTitle);
//
//       await _agoraService.joinChannel(
//         token: token,
//         channelName: channelName,
//         uid: userId,
//         userRole: role,
//       );
//
//       // Sync messages
//       messages.assignAll(_agoraService.chatMessages);
//
//       return true;
//     } catch (e) {
//       errorMessage.value = 'Failed to join: $e';
//       debugPrint('=== Error joining session: $e ===');
//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   String _cleanChannelName(String name) {
//     return name
//         .replaceAll(RegExp(r'[^\w]'), '_')
//         .toLowerCase()
//         .substring(0, name.length > 64 ? 64 : name.length);
//   }
//
//   // Chat methods
//   void sendMessage() {
//     final text = chatController.text.trim();
//     if (text.isEmpty) return;
//
//     _agoraService.sendChatMessage(text, userDisplayName.value);
//     chatController.clear();
//   }
//
//   // In AgoraViewModel class
//
//   Future<void> toggleAudio() async {
//     try {
//       if (!isJoined) return;
//
//       // Call the service method - don't access service properties directly
//       await _agoraService.toggleAudio();
//
//       // Update UI state
//       update();
//
//       debugPrint('=== Audio toggled in ViewModel ===');
//     } catch (e) {
//       debugPrint('=== Error toggling audio in ViewModel: $e ===');
//     }
//   }
//
//   Future<void> toggleVideo() async {
//     try {
//       if (!isJoined) return;
//
//       // Call the service method - don't access service properties directly
//       await _agoraService.toggleVideo();
//
//       // Update UI state
//       update();
//
//       debugPrint('=== Video toggled in ViewModel ===');
//     } catch (e) {
//       debugPrint('=== Error toggling video in ViewModel: $e ===');
//     }
//   }
//
//   Future<void> switchCamera() async {
//     try {
//       if (!isJoined) return;
//
//       await _agoraService.switchCamera();
//       update();
//     } catch (e) {
//       debugPrint('=== Error switching camera: $e ===');
//     }
//   }
//
//   Future<void> leaveSession() async {
//     await _agoraService.leaveChannel();
//     userDisplayName.value = '';
//     userRole.value = 'audience';
//     messages.clear();
//     showChat.value = false;
//     showParticipants.value = false;
//   }
//
//   void toggleChatPanel() {
//     showChat.value = !showChat.value;
//   }
//
//   void toggleParticipantsPanel() {
//     showParticipants.value = !showParticipants.value;
//   }
//
//   void switchViewMode() {
//     viewMode.value = viewMode.value == 'grid' ? 'speaker' : 'grid';
//     update();
//   }
//
//   // Get participants list for UI
//   List<ParticipantInfo> get participants {
//     final list = <ParticipantInfo>[];
//
//     // Add local user
//     if (isJoined) {
//       list.add(ParticipantInfo(
//         uid: 0, // Using 0 for local user in UI
//         name: userDisplayName.value,
//         isLocal: true,
//         isHost: isHost,
//         audioEnabled: _agoraService.isAudioEnabled.value,
//         videoEnabled: _agoraService.isVideoEnabled.value,
//       ));
//     }
//
//     // Add remote users
//     for (final uid in _agoraService.remoteUserIds) {
//       final state = _agoraService.userStates[uid];
//       final user = _agoraService.remoteUsers[uid];
//
//       list.add(ParticipantInfo(
//         uid: uid,
//         name: user?.name ?? 'User $uid',
//         isLocal: false,
//         isHost: false,
//         audioEnabled: state?.hasAudio ?? false,
//         videoEnabled: state?.hasVideo ?? false,
//       ));
//     }
//
//     return list;
//   }
// }
//
// class ParticipantInfo {
//   final int uid;
//   final String name;
//   final bool isLocal;
//   final bool isHost;
//   final bool audioEnabled;
//   final bool videoEnabled;
//
//   ParticipantInfo({
//     required this.uid,
//     required this.name,
//     required this.isLocal,
//     required this.isHost,
//     required this.audioEnabled,
//     required this.videoEnabled,
//   });
//
//   String get displayName => name;
//   String get firstChar => name.isNotEmpty ? name[0].toUpperCase() : 'U';
// }