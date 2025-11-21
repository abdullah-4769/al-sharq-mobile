
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../view_model/live_streaming_viewmodel/agora_viewmodel.dart';

class LiveStreamingScreen extends StatefulWidget {
  final int sessionId;
  final String sessionTitle;
  final String userName;
  final String token;
  final int userId;
  final String userRole;

  const LiveStreamingScreen({
    Key? key,
    required this.sessionId,
    required this.sessionTitle,
    required this.userName,
    required this.token,
    required this.userId,
    required this.userRole,
  }) : super(key: key);

  @override
  State<LiveStreamingScreen> createState() => _LiveStreamingScreenState();
}

class _LiveStreamingScreenState extends State<LiveStreamingScreen> {
  final AgoraViewModel _viewModel = Get.find<AgoraViewModel>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('=== LiveStreamingScreen initState ===');
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    if (_isInitialized) {
      debugPrint('=== Already initialized, skipping ===');
      return;
    }

    debugPrint('=== Requesting permissions ===');
    final statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    debugPrint(
        '=== Permission status - Camera: ${statuses[Permission.camera]}, '
            'Microphone: ${statuses[Permission.microphone]} ===');

    if (statuses[Permission.microphone]!.isDenied ||
        statuses[Permission.camera]!.isDenied) {
      _showPermissionDialog();
      return;
    }

    debugPrint(
        '=== Joining session with params: ${widget.sessionId}, ${widget.userName}, ${widget.userRole} ===');

    try {
      final success = await _viewModel.joinSession(
        sessionId: widget.sessionId,
        nickname: widget.userName,
        sessionTitle: widget.sessionTitle,
        token: widget.token,
        userId: widget.userId,
        role: widget.userRole,
      );

      if (!success && mounted) {
        debugPrint('=== Failed to join session ===');
        Get.snackbar(
          'Error',
          'Failed to join session',
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        _isInitialized = true;
        debugPrint('=== Session initialization completed ===');
      }
    } catch (e) {
      debugPrint('=== Error initializing Agora: $e ===');
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to initialize video: $e',
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Camera and microphone permissions are required for live streaming.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
// In LiveStreamingScreen - Update _buildParticipantListItem
  Widget _buildParticipantListItem(ParticipantInfo p) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: p.isHost ? Colors.red.shade700 : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Avatar with host indicator
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.isHost ? Colors.red.shade700 :
                  p.isLocal ? Colors.blue.shade700 : Colors.green.shade700,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    p.firstChar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (p.isHost)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.star, size: 8, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        p.displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: p.isHost ? FontWeight.bold : FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (p.isHost) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HOST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (p.isLocal) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // NEW: Permission status for audience
                if (!p.isHost && p.isLocal) ...[
                  Row(
                    children: [
                      Icon(
                        p.hasAudioPermission ? Icons.mic : Icons.mic_off,
                        size: 12,
                        color: p.hasAudioPermission ? Colors.green.shade400 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        p.hasVideoPermission ? Icons.videocam : Icons.videocam_off,
                        size: 12,
                        color: p.hasVideoPermission ? Colors.green.shade400 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        p.hasScreenSharePermission ? Icons.screen_share : Icons.screen_share_outlined,
                        size: 12,
                        color: p.hasScreenSharePermission ? Colors.green.shade400 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Permissions',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Audio/Video status and controls
          Column(
            children: [
              // Audio status
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: p.audioEnabled
                      ? Colors.green.shade700.withOpacity(0.2)
                      : Colors.red.shade700.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  p.audioEnabled ? Icons.mic : Icons.mic_off,
                  size: 16,
                  color: p.audioEnabled ? Colors.green.shade400 : Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 4),

              // Video status
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: p.videoEnabled
                      ? Colors.green.shade700.withOpacity(0.2)
                      : Colors.red.shade700.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  p.videoEnabled ? Icons.videocam : Icons.videocam_off,
                  size: 16,
                  color: p.videoEnabled ? Colors.green.shade400 : Colors.red.shade400,
                ),
              ),

              // Host controls for remote users
              if (_viewModel.isHost && !p.isLocal) ...[
                const SizedBox(height: 8),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  color: Colors.grey.shade800,
                  onSelected: (value) {
                    _handleHostControl(value, p);
                  },
                  itemBuilder: (context) => [
                    // Existing mute controls
                    PopupMenuItem(
                      value: p.audioEnabled ? 'mute_audio' : 'unmute_audio',
                      child: Row(
                        children: [
                          Icon(
                            p.audioEnabled ? Icons.mic_off : Icons.mic,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            p.audioEnabled ? 'Mute Audio' : 'Unmute Audio',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: p.videoEnabled ? 'mute_video' : 'unmute_video',
                      child: Row(
                        children: [
                          Icon(
                            p.videoEnabled ? Icons.videocam_off : Icons.videocam,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            p.videoEnabled ? 'Turn Off Video' : 'Turn On Video',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // NEW: Permission controls
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'grant_audio',
                      child: Row(
                        children: [
                          Icon(
                            Icons.mic,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Grant Audio Permission',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'grant_video',
                      child: Row(
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Grant Video Permission',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'grant_screen_share',
                      child: Row(
                        children: [
                          Icon(
                            Icons.screen_share,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Grant Screen Share',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'revoke_permissions',
                      child: Row(
                        children: [
                          Icon(
                            Icons.block,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Revoke All Permissions',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_remove,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Remove User',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // Audience request buttons
              if (!_viewModel.isHost && p.isLocal) ...[
                const SizedBox(height: 8),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  color: Colors.grey.shade800,
                  onSelected: (value) {
                    _handleAudienceRequest(value, p);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'request_audio',
                      child: Row(
                        children: [
                          Icon(
                            Icons.mic,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Request Audio Permission',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'request_video',
                      child: Row(
                        children: [
                          Icon(
                            Icons.videocam,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Request Video Permission',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'request_screen_share',
                      child: Row(
                        children: [
                          Icon(
                            Icons.screen_share,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Request Screen Share',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

// UPDATED: Handle host control actions with permissions
  void _handleHostControl(String action, ParticipantInfo p) {
    switch (action) {
      case 'mute_audio':
        _viewModel.muteUserAudio(p.uid);
        break;
      case 'unmute_audio':
        _viewModel.unmuteUserAudio(p.uid);
        break;
      case 'mute_video':
        _viewModel.muteUserVideo(p.uid);
        break;
      case 'unmute_video':
        _viewModel.unmuteUserVideo(p.uid);
        break;
      case 'grant_audio':
        _viewModel.grantUserPermissions(p.uid, true, false, false);
        break;
      case 'grant_video':
        _viewModel.grantUserPermissions(p.uid, false, true, false);
        break;
      case 'grant_screen_share':
        _viewModel.grantUserPermissions(p.uid, false, false, true);
        break;
      case 'revoke_permissions':
        _viewModel.revokeUserPermissions(p.uid);
        break;
      case 'remove':
        _showRemoveUserDialog(p);
        break;
    }
  }

// UPDATED: Handle audience requests with permissions
  void _handleAudienceRequest(String action, ParticipantInfo p) {
    switch (action) {
      case 'request_audio':
        _viewModel.requestAudioPermission();
        break;
      case 'request_video':
        _viewModel.requestVideoPermission();
        break;
      case 'request_screen_share':
        _viewModel.requestScreenSharePermission();
        break;
    }
  }
// // Add this method to show participant list with host controls
//   Widget _buildParticipantListItem(ParticipantInfo p) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade800,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: p.isHost ? Colors.red.shade700 : Colors.transparent,
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color: p.isHost ? Colors.red.shade700 : Colors.blue.shade700,
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Icon(
//                 p.isHost ? Icons.person : Icons.people,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Flexible(
//                       child: Text(
//                         p.displayName,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     if (p.isHost) ...[
//                       const SizedBox(width: 6),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade700,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: const Text(
//                           'HOST',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 9,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(
//                       p.audioEnabled ? Icons.mic : Icons.mic_off,
//                       size: 14,
//                       color: p.audioEnabled ? Colors.green.shade400 : Colors.grey.shade600,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       p.audioEnabled ? 'Audio on' : 'Audio off',
//                       style: TextStyle(
//                         color: Colors.grey.shade400,
//                         fontSize: 12,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Icon(
//                       p.videoEnabled ? Icons.videocam : Icons.videocam_off,
//                       size: 14,
//                       color: p.videoEnabled ? Colors.green.shade400 : Colors.grey.shade600,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       p.videoEnabled ? 'Video on' : 'Video off',
//                       style: TextStyle(
//                         color: Colors.grey.shade400,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: p.audioEnabled
//                       ? Colors.green.shade700.withOpacity(0.2)
//                       : Colors.red.shade700.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   p.audioEnabled ? Icons.mic : Icons.mic_off,
//                   size: 16,
//                   color: p.audioEnabled ? Colors.green.shade400 : Colors.red.shade400,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: p.videoEnabled
//                       ? Colors.green.shade700.withOpacity(0.2)
//                       : Colors.red.shade700.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   p.videoEnabled ? Icons.videocam : Icons.videocam_off,
//                   size: 16,
//                   color: p.videoEnabled ? Colors.green.shade400 : Colors.red.shade400,
//                 ),
//               ),
//               // Host controls for remote users
//               if (_viewModel.isHost && !p.isLocal) ...[
//                 const SizedBox(height: 8),
//                 // In LiveStreamingScreen - Update the PopupMenuButton in _buildParticipantListItem
//                 PopupMenuButton<String>(
//                   icon: Icon(
//                     Icons.more_vert,
//                     color: Colors.grey.shade400,
//                     size: 20,
//                   ),
//                   color: Colors.grey.shade800,
//                   onSelected: (value) {
//                     switch (value) {
//                       case 'mute_audio':
//                         if (p.audioEnabled) {
//                           _viewModel.muteUserAudio(p.uid);
//                         } else {
//                           _viewModel.unmuteUserAudio(p.uid);
//                         }
//                         break;
//                       case 'mute_video':
//                         if (p.videoEnabled) {
//                           _viewModel.muteUserVideo(p.uid);
//                         } else {
//                           _viewModel.unmuteUserVideo(p.uid);
//                         }
//                         break;
//                       case 'remove':
//                         _showRemoveUserDialog(p);
//                         break;
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     PopupMenuItem(
//                       value: 'mute_audio',
//                       child: Row(
//                         children: [
//                           Icon(
//                             p.audioEnabled ? Icons.mic_off : Icons.mic,
//                             size: 16,
//                             color: Colors.white,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             p.audioEnabled ? 'Mute Audio' : 'Unmute Audio',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: 'mute_video',
//                       child: Row(
//                         children: [
//                           Icon(
//                             p.videoEnabled ? Icons.videocam_off : Icons.videocam,
//                             size: 16,
//                             color: Colors.white,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             p.videoEnabled ? 'Turn Off Video' : 'Turn On Video',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem(
//                       value: 'remove',
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.person_remove,
//                             size: 16,
//                             color: Colors.red,
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             'Remove User',
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 // PopupMenuButton<String>(
//                 //   icon: Icon(
//                 //     Icons.more_vert,
//                 //     color: Colors.grey.shade400,
//                 //     size: 20,
//                 //   ),
//                 //   color: Colors.grey.shade800,
//                 //   onSelected: (value) {
//                 //     switch (value) {
//                 //       case 'mute_audio':
//                 //         _viewModel.muteUserAudio(p.uid);
//                 //         break;
//                 //       case 'unmute_audio':
//                 //         _viewModel.unmuteUserAudio(p.uid);
//                 //         break;
//                 //       case 'mute_video':
//                 //         _viewModel.muteUserVideo(p.uid);
//                 //         break;
//                 //       case 'unmute_video':
//                 //         _viewModel.unmuteUserVideo(p.uid);
//                 //         break;
//                 //       case 'remove':
//                 //         _showRemoveUserDialog(p);
//                 //         break;
//                 //     }
//                 //   },
//                 //   itemBuilder: (context) => [
//                 //     PopupMenuItem(
//                 //       value: p.audioEnabled ? 'mute_audio' : 'unmute_audio',
//                 //       child: Row(
//                 //         children: [
//                 //           Icon(
//                 //             p.audioEnabled ? Icons.mic_off : Icons.mic,
//                 //             size: 16,
//                 //             color: Colors.white,
//                 //           ),
//                 //           const SizedBox(width: 8),
//                 //           Text(
//                 //             p.audioEnabled ? 'Mute Audio' : 'Unmute Audio',
//                 //             style: const TextStyle(
//                 //               color: Colors.white,
//                 //               fontSize: 14,
//                 //             ),
//                 //           ),
//                 //         ],
//                 //       ),
//                 //     ),
//                 //     PopupMenuItem(
//                 //       value: p.videoEnabled ? 'mute_video' : 'unmute_video',
//                 //       child: Row(
//                 //         children: [
//                 //           Icon(
//                 //             p.videoEnabled ? Icons.videocam_off : Icons.videocam,
//                 //             size: 16,
//                 //             color: Colors.white,
//                 //           ),
//                 //           const SizedBox(width: 8),
//                 //           Text(
//                 //             p.videoEnabled ? 'Turn Off Video' : 'Turn On Video',
//                 //             style: const TextStyle(
//                 //               color: Colors.white,
//                 //               fontSize: 14,
//                 //             ),
//                 //           ),
//                 //         ],
//                 //       ),
//                 //     ),
//                 //     const PopupMenuItem(
//                 //       value: 'remove',
//                 //       child: Row(
//                 //         children: [
//                 //           Icon(
//                 //             Icons.person_remove,
//                 //             size: 16,
//                 //             color: Colors.red,
//                 //           ),
//                 //           SizedBox(width: 8),
//                 //           Text(
//                 //             'Remove User',
//                 //             style: TextStyle(
//                 //               color: Colors.red,
//                 //               fontSize: 14,
//                 //             ),
//                 //           ),
//                 //         ],
//                 //       ),
//                 //     ),
//                 //   ],
//                 // ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
  @override
  void dispose() {
    debugPrint('=== LiveStreamingScreen dispose ===');
    super.dispose();
  }
  Widget _buildChatPanel() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Container(
        color: Colors.grey.shade900,
        child: Column(
          children: [
            // Chat Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _viewModel.closeChat,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => Text(
                    '${_viewModel.messages.length} messages',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  )),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: Obx(() => ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: false,
                itemCount: _viewModel.messages.length,
                itemBuilder: (context, index) {
                  final message = _viewModel.messages[index];
                  return _buildChatMessage(message);
                },
              )),
            ),

            // Message Input
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade800,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _viewModel.chatController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade700,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _viewModel.sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.red.shade700,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _viewModel.sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: message.type == MessageType.system
                  ? Colors.orange.shade700
                  : message.isHost
                  ? Colors.red.shade700
                  : Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                message.senderName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      message.senderName,
                      style: TextStyle(
                        color: message.type == MessageType.system
                            ? Colors.orange.shade400
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (message.isHost) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HOST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message.message,
                  style: TextStyle(
                    color: message.type == MessageType.system
                        ? Colors.orange.shade300
                        : Colors.grey.shade300,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildParticipantsPanel() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Container(
        color: Colors.grey.shade900,
        child: Column(
          children: [
            // Participants Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _viewModel.toggleParticipantsPanel,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Participants',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => Text(
                    '${_viewModel.participants.length} online',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  )),
                ],
              ),
            ),

            // Participants List
            Expanded(
              child: Obx(() {
                final participants = _viewModel.participants;
                if (participants.isEmpty) {
                  return Center(
                    child: Text(
                      'No participants yet',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return _buildParticipantListItem(participant);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        debugPrint('=== Back button pressed, leaving session ===');
        await _viewModel.leaveSession();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Main Content
              Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Video Area
                  Expanded(
                    child: Obx(() {
                      if (_viewModel.isLoading.value) return _buildLoadingScreen();
                      if (!_viewModel.isJoined && _viewModel.errorMessage.value.isNotEmpty)
                        return _buildErrorScreen();
                      return _buildVideoArea();
                    }),
                  ),

                  // Controls
                  Obx(() => _viewModel.isJoined ? _buildControls() : const SizedBox()),
                ],
              ),

              // Chat Panel (Overlay)
              Obx(() => _viewModel.showChat.value ? _buildChatPanel() : const SizedBox()),

              // Participants Panel (Overlay)
              Obx(() => _viewModel.showParticipants.value ? _buildParticipantsPanel() : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHeader() => Container(
    padding: const EdgeInsets.all(16),
    color: Colors.black.withOpacity(0.8),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            await _viewModel.leaveSession();
            if (mounted) Navigator.pop(context);
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.sessionTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Obx(() => Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _viewModel.isJoined
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _viewModel.isJoined
                        ? '${_viewModel.participants.length} participants'
                        : 'Connecting...',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade300
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
        // DEBUG BUTTON
        IconButton(
          icon: const Icon(Icons.bug_report, color: Colors.white),
          onPressed: () {
            debugPrint('=== DEBUG INFO ===');
            debugPrint('isJoined: ${_viewModel.isJoined}');
            debugPrint('isLoading: ${_viewModel.isLoading.value}');
            debugPrint('Participants: ${_viewModel.participants.length}');
            _viewModel.checkVideoStatus();
          },
        ),
      ],
    ),
  );

  Widget _buildVideoArea() {
    return Container(
      color: Colors.grey.shade900,
      child: Obx(() {
        final participants = _viewModel.participants;
        debugPrint('=== Video Area - Participants: ${participants.length} ===');

        if (participants.isEmpty) {
          return _buildEmptyState();
        }

        // Show speaker view by default, or grid view if multiple participants
        if (_viewModel.viewMode.value == 'speaker' && participants.isNotEmpty) {
          return _buildSpeakerView(participants);
        } else {
          return _buildGridView(participants);
        }
      }),
    );
  }

  Widget _buildSpeakerView(List<ParticipantInfo> participants) {
    // Find the main speaker (host first, then first participant with video)
    ParticipantInfo mainSpeaker = participants.firstWhere(
          (p) => p.isHost && p.videoEnabled,
      orElse: () => participants.firstWhere(
            (p) => p.videoEnabled,
        orElse: () => participants.first,
      ),
    );

    return Stack(
      children: [
        // Main speaker video
        _buildParticipantView(mainSpeaker),

        // Small video grid at bottom for other participants
        if (participants.length > 1)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            height: 120,
            child: _buildSmallVideoGrid(participants.where((p) => p.uid != mainSpeaker.uid).toList()),
          ),
      ],
    );
  }

  Widget _buildGridView(List<ParticipantInfo> participants) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: participants.length <= 4 ? 2 : 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return GestureDetector(
          onTap: () {
            _viewModel.selectSpeaker(participant);
            _viewModel.viewMode.value = 'speaker';
          },
          child: _buildGridParticipantView(participant),
        );
      },
    );
  }

  Widget _buildSmallVideoGrid(List<ParticipantInfo> participants) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return GestureDetector(
          onTap: () {
            _viewModel.selectSpeaker(participant);
            _viewModel.viewMode.value = 'speaker';
          },
          child: Container(
            width: 160,
            margin: const EdgeInsets.only(right: 8),
            child: _buildGridParticipantView(participant),
          ),
        );
      },
    );
  }

  Widget _buildGridParticipantView(ParticipantInfo participant) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _buildVideoContent(participant),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              participant.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (!participant.audioEnabled)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic_off, color: Colors.white, size: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildParticipantView(ParticipantInfo participant) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildVideoContent(participant),
        Positioned(
          bottom: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              participant.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (!participant.audioEnabled)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic_off, color: Colors.white, size: 20),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoContent(ParticipantInfo participant) {
    final engine = _viewModel.agoraService.engine;

    debugPrint('=== Building video for: ${participant.uid}, '
        'isLocal: ${participant.isLocal}, '
        'videoEnabled: ${participant.videoEnabled} ===');

    try {
      if (participant.videoEnabled) {
        if (participant.isLocal) {
          debugPrint('=== Creating LOCAL video view ===');
          return AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: engine,
              canvas: const VideoCanvas(uid: 0),
            ),
          );
        } else {
          debugPrint('=== Creating REMOTE video view for: ${participant.uid} ===');
          return AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: engine,
              canvas: VideoCanvas(uid: participant.uid),
              connection: RtcConnection(
                channelId: _viewModel.currentChannel.value,
              ),
            ),
          );
        }
      } else {
        return _buildAvatar(participant);
      }
    } catch (e) {
      debugPrint('=== Error creating video view: $e ===');
      return _buildErrorVideoState(participant, e.toString());
    }
  }

  Widget _buildAvatar(ParticipantInfo participant) => Container(
    color: Colors.grey.shade800,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: participant.isHost
                  ? Colors.red.shade700
                  : Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                participant.firstChar,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            participant.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildErrorVideoState(ParticipantInfo participant, String error) => Container(
    color: Colors.grey.shade800,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Video Error',
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.length > 50 ? '${error.substring(0, 50)}...' : error,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

// In LiveStreamingScreen - Replace _buildControls method:
// In LiveStreamingScreen - _buildControls method
  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.black.withOpacity(0.9),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Audio control
            _buildControlButton(
              icon: _viewModel.agoraService.isAudioEnabled.value
                  ? Icons.mic
                  : Icons.mic_off,
              label: 'Mic',
              isActive: _viewModel.agoraService.isAudioEnabled.value,
              onPressed: _viewModel.toggleAudio,
            ),
                 SizedBox(width: 2.w),

            // Video control
            _buildControlButton(
              icon: _viewModel.agoraService.isVideoEnabled.value
                  ? Icons.videocam
                  : Icons.videocam_off,
              label: 'Camera',
              isActive: _viewModel.agoraService.isVideoEnabled.value,
              onPressed: _viewModel.toggleVideo,
            ),
            SizedBox(width: 2.w),
            // Screen share - AVAILABLE FOR EVERYONE
            _buildControlButton(
              icon: Icons.screen_share,
              label: 'Share',
              isActive: _viewModel.agoraService.isScreenSharing.value,
              onPressed: _viewModel.toggleScreenShare,
            ),
            SizedBox(width: 2.w),
            // Switch camera
            if (_viewModel.canSwitchCamera)
              _buildControlButton(
                icon: Icons.flip_camera_ios,
                label: 'Flip',
                onPressed: _viewModel.switchCamera,
              ),
            SizedBox(width: 2.w),
            // Participants panel
            _buildControlButton(
              icon: Icons.people,
              label: 'People',
              badge: _viewModel.participants.length,
              isActive: _viewModel.showParticipants.value,
              onPressed: _viewModel.toggleParticipantsPanel,
            ),
            SizedBox(width: 2.w),
            // Chat panel
            _buildControlButton(
              icon: Icons.chat_bubble,
              label: 'Chat',
              badge: _viewModel.unreadCount.value,
              isActive: _viewModel.showChat.value,
              onPressed: _viewModel.toggleChatPanel,
            ),
            SizedBox(width: 2.w),
            // View mode toggle
            _buildControlButton(
              icon: _viewModel.viewMode.value == 'grid' ? Icons.person : Icons.grid_view,
              label: _viewModel.viewMode.value == 'grid' ? 'Speaker' : 'Grid',
              onPressed: _viewModel.switchViewMode,
            ),
            SizedBox(width: 2.w),
            // Upgrade to Co-Host (for audience)
            if (!_viewModel.isHost)
              _buildControlButton(
                icon: Icons.upgrade,
                label: 'Co-Host',
                onPressed: _viewModel.upgradeToCoHost,
              ),
            SizedBox(width: 2.w),
            // Leave button
            _buildControlButton(
              icon: Icons.call_end,
              label: 'Leave',
              backgroundColor: Colors.red.shade700,
              onPressed: () async {
                await _viewModel.leaveSession();
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

// Update control button to support badges
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    bool isActive = false,
    int? badge,
    Color? backgroundColor,
  }) {
    final btnColor = backgroundColor ?? (isActive ? Colors.white : Colors.grey.shade800);
    final iconColor = backgroundColor != null ? Colors.white :
    (isActive ? Colors.black : Colors.white);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: btnColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(icon, size: 24),
                color: iconColor,
                onPressed: onPressed,
              ),
            ),
            if (badge != null && badge > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Center(
                    child: Text(
                      badge > 99 ? '99+' : badge.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  // Widget _buildControls() => Container(
  //   padding: const EdgeInsets.all(16),
  //   color: Colors.black.withOpacity(0.9),
  //   child: Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       _buildControlButton(
  //         icon: _viewModel.agoraService.isAudioEnabled.value
  //             ? Icons.mic
  //             : Icons.mic_off,
  //         label: 'Mic',
  //         isActive: _viewModel.agoraService.isAudioEnabled.value,
  //         onPressed: _viewModel.toggleAudio,
  //       ),
  //
  //       _buildControlButton(
  //         icon: _viewModel.agoraService.isVideoEnabled.value
  //             ? Icons.videocam
  //             : Icons.videocam_off,
  //         label: 'Camera',
  //         isActive: _viewModel.agoraService.isVideoEnabled.value,
  //         onPressed: _viewModel.isHost ? _viewModel.toggleVideo : null,
  //       ),
  //
  //       _buildControlButton(
  //         icon: Icons.call_end,
  //         label: 'Leave',
  //         backgroundColor: Colors.red.shade700,
  //         onPressed: () async {
  //           await _viewModel.leaveSession();
  //           if (mounted) Navigator.pop(context);
  //         },
  //       ),
  //     ],
  //   ),
  // );
  //
  // Widget _buildControlButton({
  //   required IconData icon,
  //   required String label,
  //   VoidCallback? onPressed,
  //   bool isActive = false,
  //   Color? backgroundColor,
  // }) {
  //   final btnColor = backgroundColor ?? (isActive ? Colors.white : Colors.grey.shade800);
  //   final iconColor = backgroundColor != null ? Colors.white :
  //   (isActive ? Colors.black : Colors.white);
  //
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Container(
  //         width: 60,
  //         height: 60,
  //         decoration: BoxDecoration(
  //           color: btnColor,
  //           shape: BoxShape.circle,
  //         ),
  //         child: IconButton(
  //           icon: Icon(icon, size: 24),
  //           color: iconColor,
  //           onPressed: onPressed,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Text(
  //         label,
  //         style: const TextStyle(
  //           color: Colors.white,
  //           fontSize: 12,
  //         ),
  //       ),
  //     ],
  //   );
  // }
// In LiveStreamingScreen - Add this method:

  void _showRemoveUserDialog(ParticipantInfo p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text('Remove ${p.name}?', style: const TextStyle(color: Colors.white)),
        content: const Text('This user will be removed from the session.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            onPressed: () {
              _viewModel.removeUser(p.uid);
              Navigator.pop(context);
              Get.snackbar(
                'User Removed',
                '${p.name} has been removed from the session',
                backgroundColor: Colors.red.shade700,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.people_outline,
              size: 40, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Text('Waiting for participants...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
      ],
    ),
  );

  Widget _buildLoadingScreen() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade700),
          strokeWidth: 3,
        ),
        const SizedBox(height: 24),
        const Text('Joining session...',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text('Please wait',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
      ],
    ),
  );

  Widget _buildErrorScreen() => Container(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade900.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline,
                color: Colors.red.shade400, size: 40),
          ),
          const SizedBox(height: 24),
          const Text('Connection Failed',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Obx(() => Text(
            _viewModel.errorMessage.value.isNotEmpty
                ? _viewModel.errorMessage.value
                : 'Unable to join the session',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          )),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _initializeAgora,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


















//import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:permission_handler/permission_handler.dart';
// import '../services/live_streaming_services/agora_services.dart';
// import '../view_model/live_streaming_viewmodel/agora_viewmodel.dart';
//
// class LiveStreamingScreen extends StatefulWidget {
//   final int sessionId;
//   final String sessionTitle;
//   final String userName;
//   final String token;
//   final int userId;
//   final String userRole;
//
//   const LiveStreamingScreen({
//     Key? key,
//     required this.sessionId,
//     required this.sessionTitle,
//     required this.userName,
//     required this.token,
//     required this.userId,
//     required this.userRole,
//   }) : super(key: key);
//
//   @override
//   State<LiveStreamingScreen> createState() => _LiveStreamingScreenState();
// }
//
// class _LiveStreamingScreenState extends State<LiveStreamingScreen> {
//   final AgoraViewModel _viewModel = Get.find<AgoraViewModel>();
//   bool _isInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAgora();
//   }
//
//   Future<void> _initializeAgora() async {
//     if (_isInitialized) return;
//
//     final statuses = await [
//       Permission.microphone,
//       Permission.camera,
//     ].request();
//
//     if (statuses[Permission.microphone]!.isDenied ||
//         statuses[Permission.camera]!.isDenied) {
//       _showPermissionDialog();
//       return;
//     }
//
//     try {
//       final success = await _viewModel.joinSession(
//         sessionId: widget.sessionId,
//         nickname: widget.userName,
//         sessionTitle: widget.sessionTitle,
//         token: widget.token,
//         userId: widget.userId,
//         role: widget.userRole,
//       );
//
//       if (!success && mounted) {
//         Get.snackbar('Error', 'Failed to join session');
//       } else {
//         _isInitialized = true;
//       }
//     } catch (e) {
//       if (mounted) {
//         Get.snackbar('Error', 'Failed to initialize video: $e');
//       }
//     }
//   }
//
//   void _showPermissionDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Permissions Required'),
//         content: const Text('Camera and microphone permissions are required.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               openAppSettings();
//             },
//             child: const Text('Open Settings'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         await _viewModel.leaveSession();
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: SafeArea(
//           child: Stack( // Changed from Column to Stack
//             children: [
//               // Main Content
//               Column(
//                 children: [
//                   // Header
//                   _buildHeader(),
//                   // Video Area
//                   Expanded(child: _buildVideoArea()),
//                   // Controls
//                   _buildControls(),
//                 ],
//               ),
//
//               // Chat Panel (Overlay)
//               Obx(() => _viewModel.showChat.value ? _buildChatPanel() : const SizedBox()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//   Widget _buildHeader() => Container(
//     padding: const EdgeInsets.all(16),
//     color: Colors.black,
//     child: Row(
//       children: [
//         IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () async {
//             await _viewModel.leaveSession();
//             if (mounted) Navigator.pop(context);
//           },
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 widget.sessionTitle,
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 4),
//               Obx(() => Text(
//                 _viewModel.isJoined ? 'Connected' : 'Connecting...',
//                 style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
//               )),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _buildVideoArea() {
//     return Obx(() {
//       final participants = _viewModel.participants;
//
//       if (participants.isEmpty) {
//         return _buildEmptyState();
//       }
//
//       if (_viewModel.viewMode.value == 'speaker' && participants.isNotEmpty) {
//         return _buildSpeakerView(participants);
//       } else {
//         return _buildGridView(participants);
//       }
//     });
//   }
//
//   Widget _buildSpeakerView(List<ParticipantInfo> participants) {
//     // Find first user with video, or first participant
//     final mainSpeaker = participants.firstWhere(
//           (p) => p.videoEnabled,
//       orElse: () => participants.first,
//     );
//
//     return Stack(
//       children: [
//         // Main speaker video
//         _buildParticipantView(mainSpeaker, isMain: true),
//
//         // Small grid for other participants
//         if (participants.length > 1)
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             height: 120,
//             child: _buildSmallVideoGrid(
//                 participants.where((p) => p.uid != mainSpeaker.uid).toList()
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildGridView(List<ParticipantInfo> participants) {
//     final crossAxisCount = participants.length <= 4 ? 2 : 3;
//
//     return GridView.builder(
//       padding: const EdgeInsets.all(8),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         crossAxisSpacing: 8,
//         mainAxisSpacing: 8,
//         childAspectRatio: 0.8,
//       ),
//       itemCount: participants.length,
//       itemBuilder: (context, index) {
//         final participant = participants[index];
//         return _buildParticipantView(participant);
//       },
//     );
//   }
//
//   Widget _buildSmallVideoGrid(List<ParticipantInfo> participants) {
//     return ListView.builder(
//       scrollDirection: Axis.horizontal,
//       itemCount: participants.length,
//       itemBuilder: (context, index) {
//         final participant = participants[index];
//         return Container(
//           width: 160,
//           margin: const EdgeInsets.only(right: 8),
//           child: _buildParticipantView(participant),
//         );
//       },
//     );
//   }
//   Widget _buildParticipantView(ParticipantInfo participant, {bool isMain = false}) {
//     final engine = _viewModel.agoraService.engine;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey.shade800,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Stack(
//         children: [
//           // Video or Avatar
//           if (participant.videoEnabled)
//             _buildVideoContent(participant)
//           else
//             _buildAvatar(participant),
//
//           // Name and status overlay
//           Positioned(
//             bottom: 8,
//             left: 8,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.7),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Row(
//                 children: [
//                   Text(
//                     participant.displayName,
//                     style: const TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                   if (!participant.audioEnabled)
//                     const Padding(
//                       padding: EdgeInsets.only(left: 4),
//                       child: Icon(Icons.mic_off, color: Colors.white, size: 12),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildVideoContent(ParticipantInfo participant) {
//     final engine = _viewModel.agoraService.engine;
//
//     debugPrint('=== Building video for: ${participant.uid}, '
//         'isLocal: ${participant.isLocal}, '
//         'videoEnabled: ${participant.videoEnabled} ===');
//
//     try {
//       if (participant.isLocal) {
//         debugPrint('=== Creating LOCAL video view ===');
//         return AgoraVideoView(
//           controller: VideoViewController(
//             rtcEngine: engine,
//             canvas: const VideoCanvas(uid: 0),
//           ),
//         );
//       } else {
//         debugPrint('=== Creating REMOTE video view for: ${participant.uid} ===');
//         return AgoraVideoView(
//           controller: VideoViewController.remote(
//             rtcEngine: engine,
//             canvas: VideoCanvas(uid: participant.uid),
//             connection: RtcConnection(channelId: 'ai_and_ml_workshop'), // Use actual channel
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('=== Error creating video view: $e ===');
//       return _buildErrorVideoState(participant, e.toString());
//     }
//   }
//
//   Widget _buildErrorVideoState(ParticipantInfo participant, String error) => Container(
//     color: Colors.grey.shade800,
//     child: Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, color: Colors.red, size: 40),
//           const SizedBox(height: 8),
//           Text(
//             'Video Error',
//             style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
//           ),
//         ],
//       ),
//     ),
//   );
//   Widget _buildAvatar(ParticipantInfo participant) => Container(
//     color: Colors.grey.shade800,
//     child: Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: participant.isHost ? Colors.red : Colors.blue,
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 participant.firstChar,
//                 style: const TextStyle(color: Colors.white, fontSize: 24),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             participant.displayName,
//             style: const TextStyle(color: Colors.white, fontSize: 14),
//           ),
//         ],
//       ),
//     ),
//   );
//
//   Widget _buildControls() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: Colors.black.withOpacity(0.9),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildControlButton(
//             icon: _viewModel.agoraService.isAudioEnabled.value
//                 ? Icons.mic
//                 : Icons.mic_off,
//             label: 'Mic',
//             isActive: _viewModel.agoraService.isAudioEnabled.value,
//             onPressed: _viewModel.toggleAudio,
//           ),
//
//           _buildControlButton(
//             icon: _viewModel.agoraService.isVideoEnabled.value
//                 ? Icons.videocam
//                 : Icons.videocam_off,
//             label: 'Camera',
//             isActive: _viewModel.agoraService.isVideoEnabled.value,
//             onPressed: _viewModel.toggleVideo,
//           ),
//
//           _buildControlButton(
//             icon: Icons.chat,
//             label: 'Chat',
//             onPressed: _viewModel.toggleChatPanel,
//           ),
//           _buildControlButton(
//             icon: _viewModel.viewMode.value == 'grid' ? Icons.person : Icons.grid_view,
//             label: _viewModel.viewMode.value == 'grid' ? 'Speaker' : 'Grid',
//             onPressed: _viewModel.switchViewMode,
//           ),
//           _buildControlButton(
//             icon: Icons.call_end,
//             label: 'Leave',
//             backgroundColor: Colors.red,
//             onPressed: () async {
//               await _viewModel.leaveSession();
//               if (mounted) Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildControlButton({
//     required IconData icon,
//     required String label,
//     VoidCallback? onPressed,
//     bool isActive = false,
//     Color? backgroundColor,
//   }) {
//     final btnColor = backgroundColor ?? (isActive ? Colors.white : Colors.grey.shade800);
//     final iconColor = backgroundColor != null ? Colors.white : (isActive ? Colors.black : Colors.white);
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: btnColor,
//             shape: BoxShape.circle,
//           ),
//           child: IconButton(
//             icon: Icon(icon, size: 24),
//             color: iconColor,
//             onPressed: onPressed,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: const TextStyle(color: Colors.white, fontSize: 12),
//         ),
//       ],
//     );
//   }
//   Widget _buildChatPanel() {
//     return Positioned(
//       right: 0,
//       top: 0,
//       bottom: 0,
//       width: MediaQuery.of(context).size.width * 0.85,
//       child: Container(
//         color: Colors.grey.shade900,
//         child: Column(
//           children: [
//             // Chat Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               color: Colors.black,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: _viewModel.toggleChatPanel,
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Chat',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   Obx(() => Text(
//                     '${_viewModel.messages.length} messages',
//                     style: TextStyle(
//                       color: Colors.grey.shade400,
//                       fontSize: 12,
//                     ),
//                   )),
//                 ],
//               ),
//             ),
//
//             // Messages List
//             Expanded(
//               child: Obx(() => ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 reverse: false,
//                 itemCount: _viewModel.messages.length,
//                 itemBuilder: (context, index) {
//                   final message = _viewModel.messages[index];
//                   return _buildChatMessage(message);
//                 },
//               )),
//             ),
//
//             // Message Input
//             Container(
//               padding: const EdgeInsets.all(16),
//               color: Colors.grey.shade800,
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _viewModel.chatController,
//                       style: const TextStyle(color: Colors.white),
//                       decoration: InputDecoration(
//                         hintText: 'Type a message...',
//                         hintStyle: TextStyle(color: Colors.grey.shade500),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(25),
//                           borderSide: BorderSide.none,
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey.shade700,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       onSubmitted: (_) => _viewModel.sendMessage(),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   CircleAvatar(
//                     backgroundColor: Colors.red.shade700,
//                     child: IconButton(
//                       icon: const Icon(Icons.send, color: Colors.white, size: 20),
//                       onPressed: _viewModel.sendMessage,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildChatMessage(ChatMessage message) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: message.senderId == 0 ? Colors.blue.shade700 : Colors.green.shade700,
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Text(
//                 message.senderName[0].toUpperCase(),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       message.senderName,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
//                       style: TextStyle(
//                         color: Colors.grey.shade500,
//                         fontSize: 10,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   message.message,
//                   style: TextStyle(
//                     color: Colors.grey.shade300,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   Widget _buildEmptyState() => Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.people_outline, size: 60, color: Colors.grey.shade600),
//         const SizedBox(height: 16),
//         Text('Waiting for participants...',
//             style: TextStyle(color: Colors.grey.shade500)),
//       ],
//     ),
//   );
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
// }