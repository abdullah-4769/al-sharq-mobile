// services/live_streaming_services/agora_services.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../view_model/live_streaming_viewmodel/agora_viewmodel.dart';

class AgoraService extends GetxService {
  static AgoraService get to => Get.find();

  late RtcEngine _agoraEngine;
  final _isInitialized = false.obs;
  final _localUserId = 0.obs;
  final _localUserName = ''.obs;

  // Track states
  final isJoined = false.obs;
  final isAudioEnabled = true.obs;
  final isVideoEnabled = false.obs;
  final isScreenSharing = false.obs;
  final isFrontCamera = true.obs;
  final connectionState = ConnectionStateType.connectionStateDisconnected.obs;

  // NEW: Permission states for audience
  final hasAudioPermission = true.obs; // Audience starts without permission
  final hasVideoPermission = false.obs;
  final hasScreenSharePermission = false.obs;

  // Remote users management
  final remoteUsers = <int, RemoteUser>{}.obs;
  final userStates = <int, UserState>{}.obs;
  final userNames = <int, String>{}.obs;

  // Chat management
  final RxList<ChatMessage> _chatMessages = <ChatMessage>[].obs;
  List<ChatMessage> get chatMessages => _chatMessages;
  int _dataStreamId = 0;

  RtcEngine get engine => _agoraEngine;
  int get localUserId => _localUserId.value;
  String get localUserName => _localUserName.value;
  bool get isInitialized => _isInitialized.value;

  @override
  void onInit() {
    super.onInit();
    debugPrint('=== AgoraService initialized ===');
  }

  @override
  void onClose() {
    _dispose();
    super.onClose();
  }

  Future<void> initializeAgoraEngine() async {
    try {
      if (_isInitialized.value) {
        debugPrint('=== Agora Engine already initialized ===');
        return;
      }

      debugPrint('=== Initializing Agora Engine ===');

      _agoraEngine = createAgoraRtcEngine();

      await _agoraEngine.initialize(const RtcEngineContext(
        appId: 'bc95ca12d08b4233babfb9a7803b59b7',
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      _registerEventHandlers();

      await _agoraEngine.enableVideo();
      await _agoraEngine.enableAudio();

      await _agoraEngine.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 360),
          frameRate: 15,
          bitrate: 1000,
          orientationMode: OrientationMode.orientationModeAdaptive,
        ),
      );

      _isInitialized.value = true;
      debugPrint('=== Agora Engine initialized successfully ===');
    } catch (e) {
      debugPrint('=== Error initializing Agora Engine: $e ===');
      rethrow;
    }
  }

  void _registerEventHandlers() {
    debugPrint('=== Registering Agora event handlers ===');

    _agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onConnectionStateChanged: (connection, state, reason) {
          debugPrint('=== Connection state: $state, reason: $reason ===');
          connectionState.value = state;
        },

        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint('=== Joined channel successfully, UID: ${connection.localUid} ===');
          isJoined.value = true;
          if (connection.localUid != null) {
            _localUserId.value = connection.localUid!;
          }
          _notifyParticipantsUpdate();
        },

        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint('=== REMOTE USER JOINED: $remoteUid ===');

          _sendUserInfo(remoteUid);

          remoteUsers[remoteUid] = RemoteUser(uid: remoteUid, name: 'Loading...');
          userStates[remoteUid] = UserState(hasAudio: true, hasVideo: false, isOnline: true);
          userNames[remoteUid] = 'Loading...';

          _notifyParticipantsUpdate();

          _agoraEngine.muteRemoteAudioStream(uid: remoteUid, mute: false);
          _agoraEngine.muteRemoteVideoStream(uid: remoteUid, mute: false);
        },

        onUserOffline: (connection, remoteUid, reason) {
          debugPrint('=== Remote user offline: $remoteUid ===');
          remoteUsers.remove(remoteUid);
          userStates.remove(remoteUid);
          userNames.remove(remoteUid);
          _notifyParticipantsUpdate();
        },

        onRemoteAudioStateChanged: (connection, remoteUid, state, reason, elapsed) {
          debugPrint('=== User $remoteUid audio state: $state, reason: $reason ===');
          if (userStates.containsKey(remoteUid)) {
            final hasAudio = state == RemoteAudioState.remoteAudioStateDecoding;
            userStates[remoteUid] = userStates[remoteUid]!.copyWith(hasAudio: hasAudio);
            _notifyParticipantsUpdate();
          }
        },

        onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
          debugPrint('=== User $remoteUid video state: $state, reason: $reason ===');
          if (userStates.containsKey(remoteUid)) {
            final hasVideo = state == RemoteVideoState.remoteVideoStateDecoding;
            userStates[remoteUid] = userStates[remoteUid]!.copyWith(hasVideo: hasVideo);
            _notifyParticipantsUpdate();
          }
        },

        onAudioVolumeIndication: (connection, speakers, speakerNumber, totalVolume) {
          for (final speaker in speakers) {
            final speakerUid = speaker.uid;
            final volume = speaker.volume ?? 0;

            if (speakerUid == 0) {
              debugPrint('=== Local user volume: $volume ===');
            } else if (speakerUid != null) {
              debugPrint('=== Remote user $speakerUid volume: $volume ===');
              if (userStates.containsKey(speakerUid)) {
                userStates[speakerUid] = userStates[speakerUid]!.copyWith(
                  hasAudio: volume > 3,
                );
                _notifyParticipantsUpdate();
              }
            }
          }
        },

        // CHAT AND USER INFO MESSAGES
        onStreamMessage: (connection, remoteUid, streamId, data, length, sentTs) {
          try {
            final messageString = utf8.decode(data);
            final messageData = json.decode(messageString) as Map<String, dynamic>;

            if (messageData['type'] == 'chat') {
              debugPrint('=== Received chat message from $remoteUid ===');

              final chatMessage = ChatMessage(
                senderId: messageData['senderId'] ?? remoteUid,
                senderName: messageData['senderName'] ?? 'User $remoteUid',
                message: messageData['message'] ?? '',
                timestamp: DateTime.fromMillisecondsSinceEpoch(
                  messageData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
                ),
                type: MessageType.user,
                isHost: messageData['isHost'] ?? false,
              );

              _chatMessages.add(chatMessage);

              if (Get.isRegistered<AgoraViewModel>()) {
                final viewModel = Get.find<AgoraViewModel>();
                viewModel.onChatMessageReceived(chatMessage);
              }
            }
            else if (messageData['type'] == 'user_info') {
              debugPrint('=== Received user info from $remoteUid ===');
              final userName = messageData['userName'] ?? 'User $remoteUid';
              final isHost = messageData['isHost'] ?? false;

              userNames[remoteUid] = userName;
              if (remoteUsers.containsKey(remoteUid)) {
                remoteUsers[remoteUid] = RemoteUser(uid: remoteUid, name: userName);
              }

              _notifyParticipantsUpdate();
              debugPrint('=== Updated user $remoteUid name to: $userName, isHost: $isHost ===');
            }
            // NEW: Handle permission updates
            else if (messageData['type'] == 'permission_update') {
              debugPrint('=== Received permission update from $remoteUid ===');
              final targetUid = messageData['targetUid'];
              final audioAllowed = messageData['audioAllowed'] ?? false;
              final videoAllowed = messageData['videoAllowed'] ?? false;
              final screenShareAllowed = messageData['screenShareAllowed'] ?? false;

              if (targetUid == localUserId) {
                // This permission update is for us
                hasAudioPermission.value = audioAllowed;
                hasVideoPermission.value = videoAllowed;
                hasScreenSharePermission.value = screenShareAllowed;

                debugPrint('=== Permissions updated - Audio: $audioAllowed, Video: $videoAllowed, ScreenShare: $screenShareAllowed ===');

                // Notify viewmodel
                _notifyParticipantsUpdate();
              }
            }
          } catch (e) {
            debugPrint('=== Error processing stream message: $e ===');
          }
        },

        onStreamMessageError: (connection, remoteUid, streamId, error, missed, cached) {
          debugPrint('=== Stream message error: $error, missed: $missed ===');
        },

        onError: (errorCode, msg) {
          debugPrint('=== Agora error: $errorCode, $msg ===');
        },

        onLeaveChannel: (connection, stats) {
          debugPrint('=== Left channel ===');
          isJoined.value = false;
          remoteUsers.clear();
          userStates.clear();
          userNames.clear();
          _chatMessages.clear();
          // Reset permissions
          hasAudioPermission.value = true;
          hasVideoPermission.value = false;
          hasScreenSharePermission.value = false;
          _notifyParticipantsUpdate();
        },

        onLocalVideoStateChanged: (source, state, reason) {
          debugPrint('=== Local video state: $state, reason: $reason ===');
        },

        onLocalAudioStateChanged: (connection, state, reason) {
          debugPrint('=== Local audio state: $state, reason: $reason ===');
        },

        onFirstRemoteVideoFrame: (connection, remoteUid, width, height, elapsed) {
          debugPrint('=== First remote video frame from $remoteUid ===');
          if (userStates.containsKey(remoteUid)) {
            userStates[remoteUid] = userStates[remoteUid]!.copyWith(hasVideo: true);
            _notifyParticipantsUpdate();
          }
        },
      ),
    );
  }

  Future<void> _sendUserInfo(int? targetUid) async {
    try {
      if (_dataStreamId == 0) return;

      final userInfo = {
        'type': 'user_info',
        'userId': localUserId,
        'userName': _localUserName.value,
        'isHost': Get.isRegistered<AgoraViewModel>() ? Get.find<AgoraViewModel>().isHost : false,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final encodedData = utf8.encode(json.encode(userInfo));
      await _agoraEngine.sendStreamMessage(
        streamId: _dataStreamId,
        data: encodedData,
        length: encodedData.length,
      );

      debugPrint('=== Sent user info: ${_localUserName.value} ===');
    } catch (e) {
      debugPrint('=== Error sending user info: $e ===');
    }
  }

  // NEW: Send permission updates to users
  Future<void> _sendPermissionUpdate(int targetUid, bool audioAllowed, bool videoAllowed, bool screenShareAllowed) async {
    try {
      if (_dataStreamId == 0) return;

      final permissionUpdate = {
        'type': 'permission_update',
        'targetUid': targetUid,
        'audioAllowed': audioAllowed,
        'videoAllowed': videoAllowed,
        'screenShareAllowed': screenShareAllowed,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final encodedData = utf8.encode(json.encode(permissionUpdate));
      await _agoraEngine.sendStreamMessage(
        streamId: _dataStreamId,
        data: encodedData,
        length: encodedData.length,
      );

      debugPrint('=== Sent permission update to $targetUid ===');
    } catch (e) {
      debugPrint('=== Error sending permission update: $e ===');
    }
  }

  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
    required String userRole,
    required String userName,
  }) async {
    try {
      debugPrint('=== Joining channel: $channelName, uid: $uid, role: $userRole, name: $userName ===');

      if (!_isInitialized.value) {
        await initializeAgoraEngine();
      }

      _localUserId.value = uid;
      _localUserName.value = userName;

      await _agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      _dataStreamId = await _agoraEngine.createDataStream(
        DataStreamConfig(syncWithAudio: false, ordered: true),
      );
      debugPrint('=== Data stream created with ID: $_dataStreamId ===');

      await _agoraEngine.enableAudio();
      await _agoraEngine.enableVideo();

      // Set initial permissions based on role
      if (userRole == 'host') {
        // Host has all permissions by default
        hasAudioPermission.value = true;
        hasVideoPermission.value = true;
        hasScreenSharePermission.value = true;

        await _agoraEngine.enableLocalAudio(true);
        await _agoraEngine.muteLocalAudioStream(false);
        await _agoraEngine.enableLocalVideo(true);
        await _agoraEngine.muteLocalVideoStream(false);
        await _agoraEngine.startPreview();
        isVideoEnabled.value = true;
        isAudioEnabled.value = true;
      } else {
        // Audience starts with limited permissions
        hasAudioPermission.value = false;
        hasVideoPermission.value = false;
        hasScreenSharePermission.value = false;

        await _agoraEngine.enableLocalAudio(true);
        await _agoraEngine.muteLocalAudioStream(true); // Start muted
        await _agoraEngine.enableLocalVideo(false); // Video off
        isAudioEnabled.value = false;
        isVideoEnabled.value = false;
      }

      await _agoraEngine.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioChatroom,
      );

      await _agoraEngine.enableAudioVolumeIndication(
        interval: 200,
        smooth: 3,
        reportVad: true,
      );

      final options = ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: userRole == 'host', // Host starts with video
        publishMicrophoneTrack: userRole == 'host', // Host starts with audio
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        enableAudioRecordingOrPlayout: true,
      );

      await _agoraEngine.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: options,
      );

      _sendUserInfo(null);

      debugPrint('=== Channel join request sent with proper permissions ===');
    } catch (e) {
      debugPrint('=== Error joining channel: $e ===');
      rethrow;
    }
  }

  Future<void> upgradeToCoHost() async {
    try {
      await _agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      await _agoraEngine.enableLocalAudio(true);
      await _agoraEngine.enableLocalVideo(true);

      await _agoraEngine.updateChannelMediaOptions(ChannelMediaOptions(
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        publishScreenCaptureVideo: true,
        publishScreenCaptureAudio: true,
      ));

      // Grant all permissions when upgraded to co-host
      hasAudioPermission.value = true;
      hasVideoPermission.value = true;
      hasScreenSharePermission.value = true;

      debugPrint('=== User upgraded to Co-Host with full permissions ===');
    } catch (e) {
      debugPrint('=== Error upgrading to co-host: $e ===');
      rethrow;
    }
  }

  // UPDATED: Check permissions before toggling
  Future<void> toggleAudio() async {
    try {
      if (!isJoined.value) return;

      // Check permission for audience
      if (!hasAudioPermission.value && !(Get.isRegistered<AgoraViewModel>() ? Get.find<AgoraViewModel>().isHost : false)) {
        throw Exception('Audio permission not granted. Please request from host.');
      }

      final newState = !isAudioEnabled.value;
      await _agoraEngine.enableLocalAudio(newState);
      await _agoraEngine.muteLocalAudioStream(!newState);

      isAudioEnabled.value = newState;
      _notifyParticipantsUpdate();
      debugPrint('=== Audio toggled to: $newState ===');
    } catch (e) {
      debugPrint('=== Error toggling audio: $e ===');
      rethrow;
    }
  }

  // UPDATED: Check permissions before toggling
  Future<void> toggleVideo() async {
    try {
      if (!isJoined.value || isScreenSharing.value) return;

      // Check permission for audience
      if (!hasVideoPermission.value && !(Get.isRegistered<AgoraViewModel>() ? Get.find<AgoraViewModel>().isHost : false)) {
        throw Exception('Video permission not granted. Please request from host.');
      }

      final newState = !isVideoEnabled.value;
      debugPrint('=== Toggling video to $newState ===');

      if (newState) {
        await _agoraEngine.enableLocalVideo(true);
        await _agoraEngine.muteLocalVideoStream(false);
        if (!isVideoEnabled.value) {
          await _agoraEngine.startPreview();
        }
      } else {
        await _agoraEngine.muteLocalVideoStream(true);
      }

      isVideoEnabled.value = newState;
      _notifyParticipantsUpdate();
    } catch (e) {
      debugPrint('=== Error toggling video: $e ===');
      rethrow;
    }
  }

  // UPDATED: Check permissions before screen sharing
  Future<void> startScreenSharing() async {
    try {
      if (!isJoined.value) {
        throw Exception('Not joined to channel');
      }

      // Check permission for audience
      if (!hasScreenSharePermission.value && !(Get.isRegistered<AgoraViewModel>() ? Get.find<AgoraViewModel>().isHost : false)) {
        throw Exception('Screen share permission not granted. Please request from host.');
      }

      debugPrint('=== Starting screen sharing ===');

      // Ensure co-host permissions
      await upgradeToCoHost();

      // Stop camera preview if active
      if (isVideoEnabled.value) {
        await _agoraEngine.muteLocalVideoStream(true);
        await _agoraEngine.stopPreview();
        isVideoEnabled.value = false;
      }

      await _agoraEngine.startScreenCapture(
        const ScreenCaptureParameters2(
          captureAudio: true,
          captureVideo: true,
          videoParams: ScreenVideoParameters(
            dimensions: VideoDimensions(width: 1280, height: 720),
            frameRate: 15,
            bitrate: 2000,
          ),
        ),
      );

      await _agoraEngine.updateChannelMediaOptions(ChannelMediaOptions(
        publishScreenCaptureVideo: true,
        publishScreenCaptureAudio: true,
        publishCameraTrack: false,
        publishMicrophoneTrack: isAudioEnabled.value,
      ));

      isScreenSharing.value = true;
      _notifyParticipantsUpdate();

      debugPrint('=== Screen sharing started successfully ===');

    } catch (e) {
      debugPrint('=== Error starting screen share: $e ===');

      if (!isScreenSharing.value && isVideoEnabled.value) {
        await _agoraEngine.muteLocalVideoStream(false);
        await _agoraEngine.startPreview();
      }

      rethrow;
    }
  }

  Future<void> stopScreenSharing() async {
    try {
      if (!isJoined.value || !isScreenSharing.value) return;

      debugPrint('=== Stopping screen sharing ===');

      await _agoraEngine.stopScreenCapture();

      await _agoraEngine.updateChannelMediaOptions(ChannelMediaOptions(
        publishScreenCaptureVideo: false,
        publishScreenCaptureAudio: false,
        publishCameraTrack: isVideoEnabled.value,
        publishMicrophoneTrack: isAudioEnabled.value,
      ));

      if (isVideoEnabled.value) {
        await _agoraEngine.muteLocalVideoStream(false);
        await _agoraEngine.startPreview();
      }

      isScreenSharing.value = false;
      _notifyParticipantsUpdate();

      debugPrint('=== Screen sharing stopped successfully ===');
    } catch (e) {
      debugPrint('=== Error stopping screen share: $e ===');
    }
  }

  // NEW: Grant permissions to user (called by host)
  Future<void> grantPermissions(int targetUid, bool audio, bool video, bool screenShare) async {
    try {
      await _sendPermissionUpdate(targetUid, audio, video, screenShare);
      debugPrint('=== Permissions granted to $targetUid - Audio: $audio, Video: $video, ScreenShare: $screenShare ===');
    } catch (e) {
      debugPrint('=== Error granting permissions: $e ===');
      rethrow;
    }
  }

  // NEW: Revoke permissions from user (called by host)
  Future<void> revokePermissions(int targetUid) async {
    try {
      await _sendPermissionUpdate(targetUid, false, false, false);
      debugPrint('=== Permissions revoked from $targetUid ===');
    } catch (e) {
      debugPrint('=== Error revoking permissions: $e ===');
      rethrow;
    }
  }

  Future<void> switchCamera() async {
    try {
      if (!isJoined.value || !isVideoEnabled.value) return;
      await _agoraEngine.switchCamera();
      isFrontCamera.value = !isFrontCamera.value;
    } catch (e) {
      debugPrint('=== Error switching camera: $e ===');
      rethrow;
    }
  }

  void _dispose() {
    try {
      debugPrint('=== Disposing Agora Engine ===');
      if (_isInitialized.value) {
        _agoraEngine.leaveChannel();
        _agoraEngine.release();
        _isInitialized.value = false;
      }
    } catch (e) {
      debugPrint('=== Error disposing Agora Engine: $e ===');
    }
  }

  // Get user name by UID
  String getUserName(int uid) {
    if (uid == localUserId) {
      return _localUserName.value;
    }
    return userNames[uid] ?? 'User $uid';
  }

  List<int> get remoteUserIds => remoteUsers.keys.toList();
  int get totalParticipants => remoteUsers.length + (isJoined.value ? 1 : 0);

  void _notifyParticipantsUpdate() {
    if (Get.isRegistered<AgoraViewModel>()) {
      Get.find<AgoraViewModel>().refreshParticipants();
    }
  }

  // CHAT MESSAGE METHODS (keep existing)
  Future<void> sendChatMessage(String message, String senderName, bool isHost) async {
    try {
      if (!isJoined.value) return;
      if (_dataStreamId == 0) return;

      final messageData = {
        'type': 'chat',
        'senderId': localUserId,
        'senderName': senderName,
        'message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'isHost': isHost,
      };

      final encodedData = utf8.encode(json.encode(messageData));
      await _agoraEngine.sendStreamMessage(
        streamId: _dataStreamId,
        data: encodedData,
        length: encodedData.length,
      );
    } catch (e) {
      debugPrint('=== Error sending chat message: $e ===');
      _chatMessages.add(ChatMessage(
        senderId: localUserId,
        senderName: senderName,
        message: message,
        timestamp: DateTime.now(),
        type: MessageType.user,
        isHost: isHost,
      ));

      if (Get.isRegistered<AgoraViewModel>()) {
        Get.find<AgoraViewModel>().onChatMessageReceived(_chatMessages.last);
      }
    }
  }

  Future<void> leaveChannel() async {
    try {
      debugPrint('=== Leaving channel ===');
      await _agoraEngine.stopPreview();
      if (isScreenSharing.value) {
        await _agoraEngine.stopScreenCapture();
      }
      await _agoraEngine.leaveChannel();

      isJoined.value = false;
      isVideoEnabled.value = false;
      isAudioEnabled.value = true;
      isScreenSharing.value = false;
      remoteUsers.clear();
      userStates.clear();
      userNames.clear();
      _chatMessages.clear();
      debugPrint('=== Channel left successfully ===');
    } catch (e) {
      debugPrint('=== Error leaving channel: $e ===');
    }
  }
}

class RemoteUser {
  final int uid;
  final String name;
  RemoteUser({required this.uid, required this.name});
}

class UserState {
  final bool hasAudio;
  final bool hasVideo;
  final bool isOnline;

  UserState({required this.hasAudio, required this.hasVideo, required this.isOnline});

  UserState copyWith({bool? hasAudio, bool? hasVideo, bool? isOnline}) {
    return UserState(
      hasAudio: hasAudio ?? this.hasAudio,
      hasVideo: hasVideo ?? this.hasVideo,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}





// // services/live_streaming_services/agora_services.dart
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:get/get.dart';
// import 'package:flutter/foundation.dart';
// import '../../view_model/live_streaming_viewmodel/agora_viewmodel.dart';
//
// class AgoraService extends GetxService {
//   static AgoraService get to => Get.find();
//
//   late RtcEngine _agoraEngine;
//   final _isInitialized = false.obs;
//   final _localUserId = 0.obs;
//   final _localUserName = ''.obs;
//
//   // Track states
//   final isJoined = false.obs;
//   final isAudioEnabled = true.obs;
//   final isVideoEnabled = false.obs;
//   final isScreenSharing = false.obs;
//   final isFrontCamera = true.obs;
//   final connectionState = ConnectionStateType.connectionStateDisconnected.obs;
//
//   // Remote users management
//   final remoteUsers = <int, RemoteUser>{}.obs;
//   final userStates = <int, UserState>{}.obs;
//   final userNames = <int, String>{}.obs;
//
//   // Chat management
//   final RxList<ChatMessage> _chatMessages = <ChatMessage>[].obs;
//   List<ChatMessage> get chatMessages => _chatMessages;
//   int _dataStreamId = 0;
//
//   RtcEngine get engine => _agoraEngine;
//   int get localUserId => _localUserId.value;
//   String get localUserName => _localUserName.value;
//   bool get isInitialized => _isInitialized.value;
//
//   @override
//   void onInit() {
//     super.onInit();
//     debugPrint('=== AgoraService initialized ===');
//   }
//
//   @override
//   void onClose() {
//     _dispose();
//     super.onClose();
//   }
//
//   Future<void> initializeAgoraEngine() async {
//     try {
//       if (_isInitialized.value) {
//         debugPrint('=== Agora Engine already initialized ===');
//         return;
//       }
//
//       debugPrint('=== Initializing Agora Engine ===');
//
//       _agoraEngine = createAgoraRtcEngine();
//
//       await _agoraEngine.initialize(const RtcEngineContext(
//         appId: 'bc95ca12d08b4233babfb9a7803b59b7',
//         channelProfile: ChannelProfileType.channelProfileCommunication,
//       ));
//
//       _registerEventHandlers();
//
//       await _agoraEngine.enableVideo();
//       await _agoraEngine.enableAudio();
//
//       await _agoraEngine.setVideoEncoderConfiguration(
//         const VideoEncoderConfiguration(
//           dimensions: VideoDimensions(width: 640, height: 360),
//           frameRate: 15,
//           bitrate: 1000,
//           orientationMode: OrientationMode.orientationModeAdaptive,
//         ),
//       );
//
//       _isInitialized.value = true;
//       debugPrint('=== Agora Engine initialized successfully ===');
//     } catch (e) {
//       debugPrint('=== Error initializing Agora Engine: $e ===');
//       rethrow;
//     }
//   }
//
//   void _registerEventHandlers() {
//     debugPrint('=== Registering Agora event handlers ===');
//
//     _agoraEngine.registerEventHandler(
//       RtcEngineEventHandler(
//         onConnectionStateChanged: (connection, state, reason) {
//           debugPrint('=== Connection state: $state, reason: $reason ===');
//           connectionState.value = state;
//         },
//
//         onJoinChannelSuccess: (connection, elapsed) {
//           debugPrint('=== Joined channel successfully, UID: ${connection.localUid} ===');
//           isJoined.value = true;
//           if (connection.localUid != null) {
//             _localUserId.value = connection.localUid!;
//           }
//           _notifyParticipantsUpdate();
//         },
//
//         onUserJoined: (connection, remoteUid, elapsed) {
//           debugPrint('=== REMOTE USER JOINED: $remoteUid ===');
//
//           _sendUserInfo(remoteUid);
//
//           remoteUsers[remoteUid] = RemoteUser(uid: remoteUid, name: 'Loading...');
//           userStates[remoteUid] = UserState(hasAudio: true, hasVideo: false, isOnline: true);
//           userNames[remoteUid] = 'Loading...';
//
//           _notifyParticipantsUpdate();
//
//           _agoraEngine.muteRemoteAudioStream(uid: remoteUid, mute: false);
//           _agoraEngine.muteRemoteVideoStream(uid: remoteUid, mute: false);
//         },
//
//         onUserOffline: (connection, remoteUid, reason) {
//           debugPrint('=== Remote user offline: $remoteUid ===');
//           remoteUsers.remove(remoteUid);
//           userStates.remove(remoteUid);
//           userNames.remove(remoteUid);
//           _notifyParticipantsUpdate();
//         },
//
//         onRemoteAudioStateChanged: (connection, remoteUid, state, reason, elapsed) {
//           debugPrint('=== User $remoteUid audio state: $state, reason: $reason ===');
//           if (userStates.containsKey(remoteUid)) {
//             final hasAudio = state == RemoteAudioState.remoteAudioStateDecoding;
//             userStates[remoteUid] = userStates[remoteUid]!.copyWith(hasAudio: hasAudio);
//             _notifyParticipantsUpdate();
//           }
//         },
//
//         onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
//           debugPrint('=== User $remoteUid video state: $state, reason: $reason ===');
//           if (userStates.containsKey(remoteUid)) {
//             final hasVideo = state == RemoteVideoState.remoteVideoStateDecoding;
//             userStates[remoteUid] = userStates[remoteUid]!.copyWith(hasVideo: hasVideo);
//             _notifyParticipantsUpdate();
//           }
//         },
//
//         onAudioVolumeIndication: (connection, speakers, speakerNumber, totalVolume) {
//           for (final speaker in speakers) {
//             final speakerUid = speaker.uid;
//             final volume = speaker.volume ?? 0;
//
//             if (speakerUid == 0) {
//               debugPrint('=== Local user volume: $volume ===');
//             } else if (speakerUid != null) {
//               debugPrint('=== Remote user $speakerUid volume: $volume ===');
//               if (userStates.containsKey(speakerUid)) {
//                 userStates[speakerUid] = userStates[speakerUid]!.copyWith(
//                   hasAudio: volume > 3,
//                 );
//                 _notifyParticipantsUpdate();
//               }
//             }
//           }
//         },
//
//         // CHAT AND USER INFO MESSAGES
//         onStreamMessage: (connection, remoteUid, streamId, data, length, sentTs) {
//           try {
//             final messageString = utf8.decode(data);
//             final messageData = json.decode(messageString) as Map<String, dynamic>;
//
//             if (messageData['type'] == 'chat') {
//               debugPrint('=== Received chat message from $remoteUid ===');
//
//               final chatMessage = ChatMessage(
//                 senderId: messageData['senderId'] ?? remoteUid,
//                 senderName: messageData['senderName'] ?? 'User $remoteUid',
//                 message: messageData['message'] ?? '',
//                 timestamp: DateTime.fromMillisecondsSinceEpoch(
//                   messageData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
//                 ),
//                 type: MessageType.user,
//                 isHost: messageData['isHost'] ?? false,
//               );
//
//               _chatMessages.add(chatMessage);
//
//               if (Get.isRegistered<AgoraViewModel>()) {
//                 final viewModel = Get.find<AgoraViewModel>();
//                 viewModel.onChatMessageReceived(chatMessage);
//               }
//             }
//             else if (messageData['type'] == 'user_info') {
//               debugPrint('=== Received user info from $remoteUid ===');
//               final userName = messageData['userName'] ?? 'User $remoteUid';
//               final isHost = messageData['isHost'] ?? false;
//
//               userNames[remoteUid] = userName;
//               if (remoteUsers.containsKey(remoteUid)) {
//                 remoteUsers[remoteUid] = RemoteUser(uid: remoteUid, name: userName);
//               }
//
//               _notifyParticipantsUpdate();
//               debugPrint('=== Updated user $remoteUid name to: $userName, isHost: $isHost ===');
//             }
//           } catch (e) {
//             debugPrint('=== Error processing stream message: $e ===');
//           }
//         },
//
//         onStreamMessageError: (connection, remoteUid, streamId, error, missed, cached) {
//           debugPrint('=== Stream message error: $error, missed: $missed ===');
//         },
//
//         onError: (errorCode, msg) {
//           debugPrint('=== Agora error: $errorCode, $msg ===');
//         },
//
//         onLeaveChannel: (connection, stats) {
//           debugPrint('=== Left channel ===');
//           isJoined.value = false;
//           remoteUsers.clear();
//           userStates.clear();
//           userNames.clear();
//           _chatMessages.clear();
//           _notifyParticipantsUpdate();
//         },
//
//         onLocalVideoStateChanged: (source, state, reason) {
//           debugPrint('=== Local video state: $state, reason: $reason ===');
//           // Handle screen sharing state changes here
//           if (source == VideoSourceType.videoSourceScreen && state == LocalVideoStreamState.localVideoStreamStateCapturing) {
//             isScreenSharing.value = true;
//             _notifyParticipantsUpdate();
//             debugPrint('=== Screen sharing started ===');
//           } else if (source == VideoSourceType.videoSourceScreen && state == LocalVideoStreamState.localVideoStreamStateStopped) {
//             isScreenSharing.value = false;
//             _notifyParticipantsUpdate();
//             debugPrint('=== Screen sharing stopped ===');
//           }
//         },
//
//         onLocalAudioStateChanged: (connection, state, reason) {
//           debugPrint('=== Local audio state: $state, reason: $reason ===');
//         },
//
//         onFirstRemoteVideoFrame: (connection, remoteUid, width, height, elapsed) {
//           debugPrint('=== First remote video frame from $remoteUid ===');
//           if (userStates.containsKey(remoteUid)) {
//             userStates[remoteUid] = userStates[remoteUid]!.copyWith(hasVideo: true);
//             _notifyParticipantsUpdate();
//           }
//         },
//
//         // FIXED: Use correct event handlers for older Agora SDK
//         onRemoteVideoStats: (connection, stats) {
//           // Can be used to monitor remote video quality
//         },
//
//         onRtcStats: (connection, stats) {
//           // General stats handler
//         },
//       ),
//     );
//   }
//
//   Future<void> _sendUserInfo(int? targetUid) async {
//     try {
//       if (_dataStreamId == 0) return;
//
//       final userInfo = {
//         'type': 'user_info',
//         'userId': localUserId,
//         'userName': _localUserName.value,
//         'isHost': Get.isRegistered<AgoraViewModel>() ? Get.find<AgoraViewModel>().isHost : false,
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//       };
//
//       final encodedData = utf8.encode(json.encode(userInfo));
//       await _agoraEngine.sendStreamMessage(
//         streamId: _dataStreamId,
//         data: encodedData,
//         length: encodedData.length,
//       );
//
//       debugPrint('=== Sent user info: ${_localUserName.value} ===');
//     } catch (e) {
//       debugPrint('=== Error sending user info: $e ===');
//     }
//   }
//
//   Future<void> joinChannel({
//     required String token,
//     required String channelName,
//     required int uid,
//     required String userRole,
//     required String userName,
//   }) async {
//     try {
//       debugPrint('=== Joining channel: $channelName, uid: $uid, role: $userRole, name: $userName ===');
//
//       if (!_isInitialized.value) {
//         await initializeAgoraEngine();
//       }
//
//       _localUserId.value = uid;
//       _localUserName.value = userName;
//
//       await _agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//
//       _dataStreamId = await _agoraEngine.createDataStream(
//         DataStreamConfig(syncWithAudio: false, ordered: true),
//       );
//       debugPrint('=== Data stream created with ID: $_dataStreamId ===');
//
//       await _agoraEngine.enableAudio();
//       await _agoraEngine.enableVideo();
//
//       await _agoraEngine.enableLocalAudio(true);
//       await _agoraEngine.muteLocalAudioStream(true);
//       await _agoraEngine.enableLocalVideo(false);
//
//       if (userRole == 'host') {
//         await _agoraEngine.muteLocalAudioStream(false);
//         await _agoraEngine.enableLocalVideo(true);
//         await _agoraEngine.muteLocalVideoStream(false);
//         await _agoraEngine.startPreview();
//         isVideoEnabled.value = true;
//         isAudioEnabled.value = true;
//       } else {
//         isAudioEnabled.value = false;
//         isVideoEnabled.value = false;
//       }
//
//       await _agoraEngine.setAudioProfile(
//         profile: AudioProfileType.audioProfileDefault,
//         scenario: AudioScenarioType.audioScenarioChatroom,
//       );
//
//       await _agoraEngine.enableAudioVolumeIndication(
//         interval: 200,
//         smooth: 3,
//         reportVad: true,
//       );
//
//       final options = ChannelMediaOptions(
//         channelProfile: ChannelProfileType.channelProfileCommunication,
//         publishCameraTrack: userRole == 'host',
//         publishMicrophoneTrack: userRole == 'host',
//         autoSubscribeAudio: true,
//         autoSubscribeVideo: true,
//         enableAudioRecordingOrPlayout: true,
//       );
//
//       await _agoraEngine.joinChannel(
//         token: token,
//         channelId: channelName,
//         uid: uid,
//         options: options,
//       );
//
//       _sendUserInfo(null);
//
//       debugPrint('=== Channel join request sent ===');
//     } catch (e) {
//       debugPrint('=== Error joining channel: $e ===');
//       rethrow;
//     }
//   }
//
//   Future<void> upgradeToCoHost() async {
//     try {
//       await _agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//
//       await _agoraEngine.enableLocalAudio(true);
//       await _agoraEngine.enableLocalVideo(true);
//
//       await _agoraEngine.updateChannelMediaOptions(ChannelMediaOptions(
//         publishCameraTrack: true,
//         publishMicrophoneTrack: true,
//         publishScreenCaptureVideo: true,
//         publishScreenCaptureAudio: true,
//       ));
//
//       debugPrint('=== User upgraded to Co-Host ===');
//     } catch (e) {
//       debugPrint('=== Error upgrading to co-host: $e ===');
//       rethrow;
//     }
//   }
//
//   // CHAT MESSAGE METHODS
//   Future<void> sendChatMessage(String message, String senderName, bool isHost) async {
//     try {
//       if (!isJoined.value) {
//         debugPrint('=== Cannot send message - not joined to channel ===');
//         return;
//       }
//
//       if (_dataStreamId == 0) {
//         debugPrint('=== Data stream not initialized ===');
//         return;
//       }
//
//       final messageData = {
//         'type': 'chat',
//         'senderId': localUserId,
//         'senderName': senderName,
//         'message': message,
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//         'isHost': isHost,
//       };
//
//       final encodedData = utf8.encode(json.encode(messageData));
//       await _agoraEngine.sendStreamMessage(
//         streamId: _dataStreamId,
//         data: encodedData,
//         length: encodedData.length,
//       );
//
//       debugPrint('=== Chat message sent via data stream ===');
//     } catch (e) {
//       debugPrint('=== Error sending chat message: $e ===');
//       _chatMessages.add(ChatMessage(
//         senderId: localUserId,
//         senderName: senderName,
//         message: message,
//         timestamp: DateTime.now(),
//         type: MessageType.user,
//         isHost: isHost,
//       ));
//
//       if (Get.isRegistered<AgoraViewModel>()) {
//         final viewModel = Get.find<AgoraViewModel>();
//         viewModel.onChatMessageReceived(_chatMessages.last);
//       }
//     }
//   }
//
//   void _notifyParticipantsUpdate() {
//     if (Get.isRegistered<AgoraViewModel>()) {
//       Get.find<AgoraViewModel>().refreshParticipants();
//     }
//   }
//
//   Future<void> leaveChannel() async {
//     try {
//       debugPrint('=== Leaving channel ===');
//       await _agoraEngine.stopPreview();
//       if (isScreenSharing.value) {
//         await _agoraEngine.stopScreenCapture();
//       }
//       await _agoraEngine.leaveChannel();
//
//       isJoined.value = false;
//       isVideoEnabled.value = false;
//       isAudioEnabled.value = true;
//       isScreenSharing.value = false;
//       remoteUsers.clear();
//       userStates.clear();
//       userNames.clear();
//       _chatMessages.clear();
//       debugPrint('=== Channel left successfully ===');
//     } catch (e) {
//       debugPrint('=== Error leaving channel: $e ===');
//     }
//   }
//
//   Future<void> toggleAudio() async {
//     try {
//       if (!isJoined.value) return;
//
//       final newState = !isAudioEnabled.value;
//       await _agoraEngine.enableLocalAudio(newState);
//       await _agoraEngine.muteLocalAudioStream(!newState);
//
//       isAudioEnabled.value = newState;
//       _notifyParticipantsUpdate();
//       debugPrint('=== Audio toggled to: $newState ===');
//     } catch (e) {
//       debugPrint('=== Error toggling audio: $e ===');
//       rethrow;
//     }
//   }
//
//   Future<void> toggleVideo() async {
//     try {
//       if (!isJoined.value || isScreenSharing.value) return;
//
//       final newState = !isVideoEnabled.value;
//       debugPrint('=== Toggling video to $newState ===');
//
//       if (newState) {
//         await _agoraEngine.enableLocalVideo(true);
//         await _agoraEngine.muteLocalVideoStream(false);
//         if (!isVideoEnabled.value) {
//           await _agoraEngine.startPreview();
//         }
//       } else {
//         await _agoraEngine.muteLocalVideoStream(true);
//       }
//
//       isVideoEnabled.value = newState;
//       _notifyParticipantsUpdate();
//     } catch (e) {
//       debugPrint('=== Error toggling video: $e ===');
//       rethrow;
//     }
//   }
//
//   // FIXED SCREEN SHARING - SIMPLIFIED AND ROBUST
//   Future<void> startScreenSharing() async {
//     try {
//       if (!isJoined.value) {
//         throw Exception('Not joined to channel');
//       }
//
//       debugPrint('=== Starting screen sharing ===');
//
//       // Ensure co-host permissions
//       await upgradeToCoHost();
//
//       // Stop camera preview if active
//       if (isVideoEnabled.value) {
//         await _agoraEngine.muteLocalVideoStream(true);
//         await _agoraEngine.stopPreview();
//         isVideoEnabled.value = false;
//       }
//
//       // SIMPLIFIED: Use basic screen capture parameters
//       await _agoraEngine.startScreenCapture(
//         const ScreenCaptureParameters2(
//           captureAudio: true,
//           captureVideo: true,
//           videoParams: ScreenVideoParameters(
//             dimensions: VideoDimensions(width: 1280, height: 720),
//             frameRate: 15,
//             bitrate: 2000,
//           ),
//         ),
//       );
//
//       // Update media options for screen sharing
//       await _agoraEngine.updateChannelMediaOptions(ChannelMediaOptions(
//         publishScreenCaptureVideo: true,
//         publishScreenCaptureAudio: true,
//         publishCameraTrack: false, // Disable camera when screen sharing
//         publishMicrophoneTrack: isAudioEnabled.value,
//       ));
//
//       // Manually set screen sharing state since we don't have the specific event
//       isScreenSharing.value = true;
//       _notifyParticipantsUpdate();
//
//       debugPrint('=== Screen sharing started successfully ===');
//
//     } catch (e) {
//       debugPrint('=== Error starting screen share: $e ===');
//
//       // Restore camera on error
//       if (!isScreenSharing.value && isVideoEnabled.value) {
//         await _agoraEngine.muteLocalVideoStream(false);
//         await _agoraEngine.startPreview();
//       }
//
//       rethrow;
//     }
//   }
//
//   Future<void> stopScreenSharing() async {
//     try {
//       if (!isJoined.value || !isScreenSharing.value) return;
//
//       debugPrint('=== Stopping screen sharing ===');
//
//       await _agoraEngine.stopScreenCapture();
//
//       // Restore media options for camera
//       await _agoraEngine.updateChannelMediaOptions(ChannelMediaOptions(
//         publishScreenCaptureVideo: false,
//         publishScreenCaptureAudio: false,
//         publishCameraTrack: isVideoEnabled.value,
//         publishMicrophoneTrack: isAudioEnabled.value,
//       ));
//
//       // Restart camera preview if video was enabled
//       if (isVideoEnabled.value) {
//         await _agoraEngine.muteLocalVideoStream(false);
//         await _agoraEngine.startPreview();
//       }
//
//       isScreenSharing.value = false;
//       _notifyParticipantsUpdate();
//
//       debugPrint('=== Screen sharing stopped successfully ===');
//     } catch (e) {
//       debugPrint('=== Error stopping screen share: $e ===');
//     }
//   }
//
//   Future<void> switchCamera() async {
//     try {
//       if (!isJoined.value || !isVideoEnabled.value) return;
//       await _agoraEngine.switchCamera();
//       isFrontCamera.value = !isFrontCamera.value;
//     } catch (e) {
//       debugPrint('=== Error switching camera: $e ===');
//       rethrow;
//     }
//   }
//
//   void _dispose() {
//     try {
//       debugPrint('=== Disposing Agora Engine ===');
//       if (_isInitialized.value) {
//         _agoraEngine.leaveChannel();
//         _agoraEngine.release();
//         _isInitialized.value = false;
//       }
//     } catch (e) {
//       debugPrint('=== Error disposing Agora Engine: $e ===');
//     }
//   }
//
//   // Get user name by UID
//   String getUserName(int uid) {
//     if (uid == localUserId) {
//       return _localUserName.value;
//     }
//     return userNames[uid] ?? 'User $uid';
//   }
//
//   // Check if user is host
//   bool isUserHost(int uid) {
//     if (uid == localUserId) {
//       return Get.isRegistered<AgoraViewModel>() ? Get.find<AgoraViewModel>().isHost : false;
//     }
//     return false;
//   }
//
//   List<int> get remoteUserIds => remoteUsers.keys.toList();
//   int get totalParticipants => remoteUsers.length + (isJoined.value ? 1 : 0);
// }
//
// class RemoteUser {
//   final int uid;
//   final String name;
//   RemoteUser({required this.uid, required this.name});
// }
//
// class UserState {
//   final bool hasAudio;
//   final bool hasVideo;
//   final bool isOnline;
//
//   UserState({required this.hasAudio, required this.hasVideo, required this.isOnline});
//
//   UserState copyWith({bool? hasAudio, bool? hasVideo, bool? isOnline}) {
//     return UserState(
//       hasAudio: hasAudio ?? this.hasAudio,
//       hasVideo: hasVideo ?? this.hasVideo,
//       isOnline: isOnline ?? this.isOnline,
//     );
//   }
// }
//
//







// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:get/get.dart';
// import 'package:flutter/foundation.dart';
//
// import '../../view_model/live_streaming_viewmodel/agora_viewmodel.dart';
//
// class AgoraService extends GetxService {
//   static AgoraService get to => Get.find();
//
//   late RtcEngine _agoraEngine;
//   final _isInitialized = false.obs;
//   final _localUserId = 0.obs;
//
//   // Track states
//   final isJoined = false.obs;
//   final isAudioEnabled = true.obs;
//   final isVideoEnabled = false.obs;
//   final isScreenSharing = false.obs;
//   final isFrontCamera = true.obs;
//   final connectionState = ConnectionStateType.connectionStateDisconnected.obs;
//
//   // Remote users management
//   final remoteUsers = <int, RemoteUser>{}.obs;
//   final userStates = <int, UserState>{}.obs;
//
//   RtcEngine get engine => _agoraEngine;
//   int get localUserId => _localUserId.value;
//   bool get isInitialized => _isInitialized.value;
//
//   @override
//   void onInit() {
//     super.onInit();
//     debugPrint('=== AgoraService initialized ===');
//   }
//
//   @override
//   void onClose() {
//     _dispose();
//     super.onClose();
//   }
//
//   Future<void> initializeAgoraEngine() async {
//     try {
//       if (_isInitialized.value) {
//         debugPrint('=== Agora Engine already initialized ===');
//         return;
//       }
//
//       debugPrint('=== Initializing Agora Engine ===');
//
//       _agoraEngine = createAgoraRtcEngine();
//       await _agoraEngine.initialize(const RtcEngineContext(
//         appId: 'bc95ca12d08b4233babfb9a7803b59b7',
//         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//       ));
//
//       _registerEventHandlers();
//
//       await _agoraEngine.enableVideo();
//       await _agoraEngine.enableAudio();
//
//       await _agoraEngine.setVideoEncoderConfiguration(
//         const VideoEncoderConfiguration(
//           dimensions: VideoDimensions(width: 640, height: 360),
//           frameRate: 15,
//           bitrate: 1000,
//           orientationMode: OrientationMode.orientationModeAdaptive,
//         ),
//       );
//
//       _isInitialized.value = true;
//       debugPrint('=== Agora Engine initialized successfully ===');
//     } catch (e) {
//       debugPrint('=== Error initializing Agora Engine: $e ===');
//       rethrow;
//     }
//   }
//
//   // In AgoraService - Update event handlers for better remote user detection:
//
//   void _registerEventHandlers() {
//     debugPrint('=== Registering Agora event handlers ===');
//
//     _agoraEngine.registerEventHandler(
//       RtcEngineEventHandler(
//         onConnectionStateChanged: (connection, state, reason) {
//           debugPrint('=== Connection state: $state, reason: $reason ===');
//           connectionState.value = state;
//         },
//
//         onJoinChannelSuccess: (connection, elapsed) {
//           debugPrint('=== Joined channel successfully, UID: ${connection.localUid} ===');
//           isJoined.value = true;
//           if (connection.localUid != null) {
//             _localUserId.value = connection.localUid!;
//           }
//           _notifyParticipantsUpdate();
//         },
//
//         onUserJoined: (connection, remoteUid, elapsed) {
//           debugPrint('=== REMOTE USER JOINED: $remoteUid ===');
//           remoteUsers[remoteUid] = RemoteUser(uid: remoteUid, name: 'User $remoteUid');
//           userStates[remoteUid] = UserState(hasAudio: true, hasVideo: false, isOnline: true);
//           _notifyParticipantsUpdate();
//
//           // Auto-subscribe to remote user's audio/video
//           _agoraEngine.muteRemoteAudioStream(uid: remoteUid, mute: false);
//           _agoraEngine.muteRemoteVideoStream(uid: remoteUid, mute: false);
//         },
//
//         onUserOffline: (connection, remoteUid, reason) {
//           debugPrint('=== Remote user offline: $remoteUid ===');
//           remoteUsers.remove(remoteUid);
//           userStates.remove(remoteUid);
//           _notifyParticipantsUpdate();
//         },
//
//         // IMPROVED AUDIO STATE DETECTION
//         onRemoteAudioStateChanged: (connection, remoteUid, state, reason, elapsed) {
//           debugPrint('=== User $remoteUid audio state: $state, reason: $reason ===');
//           if (userStates.containsKey(remoteUid)) {
//             final hasAudio = state == RemoteAudioState.remoteAudioStateDecoding;
//             userStates[remoteUid] = userStates[remoteUid]!.copyWith(hasAudio: hasAudio);
//             _notifyParticipantsUpdate();
//           }
//         },
//
//         onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
//           debugPrint('=== User $remoteUid video state: $state, reason: $reason ===');
//           if (userStates.containsKey(remoteUid)) {
//             final hasVideo = state == RemoteVideoState.remoteVideoStateDecoding;
//             userStates[remoteUid] = userStates[remoteUid]!.copyWith(hasVideo: hasVideo);
//             _notifyParticipantsUpdate();
//           }
//         },
//
//         // FIXED AUDIO VOLUME INDICATION
//         onAudioVolumeIndication: (connection, speakers, speakerNumber, totalVolume) {
//           for (final speaker in speakers) {
//             final speakerUid = speaker.uid;
//             final volume = speaker.volume ?? 0;
//
//             if (speakerUid == 0) {
//               debugPrint('=== Local user volume: $volume ===');
//             } else if (speakerUid != null) {
//               debugPrint('=== Remote user $speakerUid volume: $volume ===');
//               if (userStates.containsKey(speakerUid)) {
//                 userStates[speakerUid] = userStates[speakerUid]!.copyWith(
//                   hasAudio: volume > 3, // Lower threshold for better detection
//                 );
//                 _notifyParticipantsUpdate();
//               }
//             }
//           }
//         },
//
//         onError: (errorCode, msg) {
//           debugPrint('=== Agora error: $errorCode, $msg ===');
//         },
//
//         onLeaveChannel: (connection, stats) {
//           debugPrint('=== Left channel ===');
//           isJoined.value = false;
//           remoteUsers.clear();
//           userStates.clear();
//           _notifyParticipantsUpdate();
//         },
//
//         onLocalVideoStateChanged: (source, state, reason) {
//           debugPrint('=== Local video state: $state, reason: $reason ===');
//         },
//
//         onLocalAudioStateChanged: (connection, state, reason) {
//           debugPrint('=== Local audio state: $state, reason: $reason ===');
//         },
//
//         // ADD THIS FOR BETTER REMOTE USER HANDLING
//         onFirstRemoteVideoFrame: (connection, remoteUid, width, height, elapsed) {
//           debugPrint('=== First remote video frame from $remoteUid ===');
//           if (userStates.containsKey(remoteUid)) {
//             userStates[remoteUid] = userStates[remoteUid]!.copyWith(hasVideo: true);
//             _notifyParticipantsUpdate();
//           }
//         },
//       ),
//     );
//   }
//
//   void _notifyParticipantsUpdate() {
//     if (Get.isRegistered<AgoraViewModel>()) {
//       Get.find<AgoraViewModel>().refreshParticipants();
//     }
//   }
//   Future<void> joinChannel({
//     required String token,
//     required String channelName,
//     required int uid,
//     required ClientRoleType role,
//   }) async {
//     try {
//       debugPrint('=== Joining channel: $channelName, uid: $uid, role: $role ===');
//
//       if (!_isInitialized.value) {
//         await initializeAgoraEngine();
//       }
//
//       _localUserId.value = uid;
//
//       await _agoraEngine.setClientRole(role: role);
//
//       // CRITICAL FIX: Enable audio for audience to speak
//       await _agoraEngine.enableAudio();
//
//       if (role == ClientRoleType.clientRoleBroadcaster) {
//         // Host configuration
//         await _agoraEngine.enableLocalAudio(true);
//         await _agoraEngine.muteLocalAudioStream(false);
//         await _agoraEngine.enableVideo();
//         await _agoraEngine.enableLocalVideo(true);
//         await _agoraEngine.muteLocalVideoStream(false);
//         await _agoraEngine.startPreview();
//         isVideoEnabled.value = true;
//       } else {
//         // Audience configuration - enable audio but not video by default
//         await _agoraEngine.enableLocalAudio(true); // Allow audience to speak
//         await _agoraEngine.muteLocalAudioStream(true); // Muted by default
//         await _agoraEngine.enableLocalVideo(false); // No video for audience
//         isAudioEnabled.value = false; // Start muted
//         isVideoEnabled.value = false;
//       }
//
//       // Set audio profile for optimal voice quality
//       await _agoraEngine.setAudioProfile(
//         profile: AudioProfileType.audioProfileDefault,
//         scenario: AudioScenarioType.audioScenarioChatroom, // Changed for better voice
//       );
//
//       // Enable audio volume indication
//       await _agoraEngine.enableAudioVolumeIndication(
//         interval: 200,
//         smooth: 3,
//         reportVad: true,
//       );
//
//       final options = ChannelMediaOptions(
//         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//         clientRoleType: role,
//         autoSubscribeAudio: true,
//         autoSubscribeVideo: true,
//         publishCameraTrack: role == ClientRoleType.clientRoleBroadcaster,
//         publishMicrophoneTrack: role == ClientRoleType.clientRoleBroadcaster,
//         enableAudioRecordingOrPlayout: true,
//       );
//
//       await _agoraEngine.joinChannel(
//         token: token,
//         channelId: channelName,
//         uid: uid,
//         options: options,
//       );
//
//       debugPrint('=== Channel join request sent ===');
//     } catch (e) {
//       debugPrint('=== Error joining channel: $e ===');
//       rethrow;
//     }
//   }
//
//
//   // Add this method to AgoraService
//   Future<void> leaveChannel() async {
//     try {
//       debugPrint('=== Leaving channel ===');
//       await _agoraEngine.stopPreview();
//       await _agoraEngine.leaveChannel();
//
//       isJoined.value = false;
//       isVideoEnabled.value = false;
//       isAudioEnabled.value = true;
//       isScreenSharing.value = false;
//       remoteUsers.clear();
//       userStates.clear();
//       debugPrint('=== Channel left successfully ===');
//     } catch (e) {
//       debugPrint('=== Error leaving channel: $e ===');
//     }
//   }
//
// // Add this method to AgoraService
//   Future<void> toggleAudio() async {
//     try {
//       if (!isJoined.value) return;
//
//       final newState = !isAudioEnabled.value;
//       await _agoraEngine.enableLocalAudio(newState);
//       await _agoraEngine.muteLocalAudioStream(!newState);
//
//       isAudioEnabled.value = newState;
//       _notifyParticipantsUpdate();
//       debugPrint('=== Audio toggled to: $newState ===');
//     } catch (e) {
//       debugPrint('=== Error toggling audio: $e ===');
//       rethrow;
//     }
//   }
//
//   Future<void> toggleVideo() async {
//     try {
//       if (!isJoined.value || isScreenSharing.value) return;
//
//       final newState = !isVideoEnabled.value;
//       debugPrint('=== Toggling video to $newState ===');
//
//       if (newState) {
//         await _agoraEngine.enableVideo();
//         await _agoraEngine.enableLocalVideo(true);
//         await _agoraEngine.muteLocalVideoStream(false);
//         await _agoraEngine.startPreview();
//       } else {
//         await _agoraEngine.muteLocalVideoStream(true);
//         await _agoraEngine.stopPreview();
//       }
//
//       isVideoEnabled.value = newState;
//       _notifyParticipantsUpdate();
//     } catch (e) {
//       debugPrint('=== Error toggling video: $e ===');
//       rethrow;
//     }
//   }
//
//   // In AgoraService - Update screen share methods:
//
//   Future<void> startScreenSharing() async {
//     try {
//       if (!isJoined.value) return;
//
//       // Request screen share permission first
//       try {
//         // Stop current video if enabled
//         if (isVideoEnabled.value) {
//           await _agoraEngine.muteLocalVideoStream(true);
//           await _agoraEngine.stopPreview();
//         }
//
//         await _agoraEngine.startScreenCapture(
//           const ScreenCaptureParameters2(
//             captureAudio: true,
//             captureVideo: true,
//             videoParams: ScreenVideoParameters(
//               dimensions: VideoDimensions(width: 1280, height: 720),
//               frameRate: 15,
//               bitrate: 1000,
//             ),
//           ),
//         );
//
//         isScreenSharing.value = true;
//         _notifyParticipantsUpdate();
//         debugPrint('=== Screen sharing started successfully ===');
//       } catch (e) {
//         debugPrint('=== Screen share permission error: $e ===');
//         // Fallback: restart camera
//         if (isVideoEnabled.value) {
//           await _agoraEngine.muteLocalVideoStream(false);
//           await _agoraEngine.startPreview();
//         }
//         rethrow;
//       }
//     } catch (e) {
//       debugPrint('=== Error starting screen share: $e ===');
//       rethrow;
//     }
//   }
//   // Future<void> startScreenSharing() async {
//   //   try {
//   //     if (!isJoined.value) return;
//   //
//   //     if (isVideoEnabled.value) {
//   //       await _agoraEngine.muteLocalVideoStream(true);
//   //       await _agoraEngine.stopPreview();
//   //     }
//   //
//   //     await _agoraEngine.startScreenCapture(
//   //       const ScreenCaptureParameters2(captureAudio: true, captureVideo: true),
//   //     );
//   //
//   //     isScreenSharing.value = true;
//   //     _notifyParticipantsUpdate();
//   //   } catch (e) {
//   //     debugPrint('=== Error starting screen share: $e ===');
//   //     rethrow;
//   //   }
//   // }
//
//   Future<void> stopScreenSharing() async {
//     try {
//       if (!isJoined.value) return;
//
//       await _agoraEngine.stopScreenCapture();
//
//       if (isVideoEnabled.value) {
//         await _agoraEngine.muteLocalVideoStream(false);
//         await _agoraEngine.startPreview();
//       }
//
//       isScreenSharing.value = false;
//       _notifyParticipantsUpdate();
//     } catch (e) {
//       debugPrint('=== Error stopping screen share: $e ===');
//     }
//   }
//
//   Future<void> switchCamera() async {
//     try {
//       if (!isJoined.value || !isVideoEnabled.value) return;
//       await _agoraEngine.switchCamera();
//       isFrontCamera.value = !isFrontCamera.value;
//     } catch (e) {
//       debugPrint('=== Error switching camera: $e ===');
//       rethrow;
//     }
//   }
//
//   void _dispose() {
//     try {
//       debugPrint('=== Disposing Agora Engine ===');
//       if (_isInitialized.value) {
//         _agoraEngine.leaveChannel();
//         _agoraEngine.release();
//         _isInitialized.value = false;
//       }
//     } catch (e) {
//       debugPrint('=== Error disposing Agora Engine: $e ===');
//     }
//   }
//
//   List<int> get remoteUserIds => remoteUsers.keys.toList();
//   int get totalParticipants => remoteUsers.length + (isJoined.value ? 1 : 0);
// }
//
// class RemoteUser {
//   final int uid;
//   final String name;
//   RemoteUser({required this.uid, required this.name});
// }
//
// class UserState {
//   final bool hasAudio;
//   final bool hasVideo;
//   final bool isOnline;
//
//   UserState({required this.hasAudio, required this.hasVideo, required this.isOnline});
//
//   UserState copyWith({bool? hasAudio, bool? hasVideo, bool? isOnline}) {
//     return UserState(
//       hasAudio: hasAudio ?? this.hasAudio,
//       hasVideo: hasVideo ?? this.hasVideo,
//       isOnline: isOnline ?? this.isOnline,
//     );
//   }
// }
//

