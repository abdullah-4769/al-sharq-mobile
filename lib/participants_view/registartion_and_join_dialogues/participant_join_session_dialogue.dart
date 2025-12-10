import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import '../../live_streaming_view/live_streaming_screen.dart';
import '../../repository/live_streaming_repository/agora_token_repository.dart';
import '../../utils/shared_preference.dart';
import '../../view_model/live_streaming_viewmodel/agora_viewmodel.dart';

class JoinSessionDialog extends StatefulWidget {
  final int sessionId;
  final String sessionTitle;

  const JoinSessionDialog({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
  });

  @override
  State<JoinSessionDialog> createState() => _JoinSessionDialogState();
}

class _JoinSessionDialogState extends State<JoinSessionDialog> {

  final AgoraViewModel _agoraViewModel = Get.put(AgoraViewModel());
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('=== JoinSessionDialog init for session: ${widget.sessionId} ===');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
  Future<void> _joinSession() async {
    print('=== Joining session: ${widget.sessionId} with nickname: ${_nicknameController.text} ===');

    if (_nicknameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your display name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Get user data from shared preferences
    final userId = await SharedPrefsHelper.getUserId();
    final userRole = await SharedPrefsHelper.getUserRole();

    if (userId == null) {
      Get.snackbar(
        'Error',
        'User ID not found. Please login again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Generate token for the session
    try {
      final token = await AgoraTokenRepository().generateToken(
        channelName: widget.sessionTitle,
        uid: userId,
        role: userRole?.toLowerCase() == 'speaker' ? 'host' : 'audience',
      );

      // Close dialog first
      Get.back();

      // Navigate to live streaming screen
      print('=== Navigating to LiveStreamingScreen ===');
      Get.to(() => LiveStreamingScreen(
        sessionId: widget.sessionId,
        sessionTitle: widget.sessionTitle,
        userName: _nicknameController.text,
        token: token,
        userId: userId,
        userRole: userRole?.toLowerCase() == 'speaker' ? 'host' : 'audience',
      ));

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate token: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Future<void> _joinSession() async {
  //   print('=== Joining session: ${widget.sessionId} with nickname: ${_nicknameController.text} ===');
  //
  //   if (_nicknameController.text.isEmpty) {
  //     Get.snackbar(
  //       'Error',
  //       'Please enter your display name',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //     return;
  //   }
  //
  //   final success = await _agoraViewModel.joinSession(
  //     sessionId: widget.sessionId,
  //     nickname: _nicknameController.text,
  //     sessionTitle: widget.sessionTitle, // Pass the session title
  //   );
  //
  //   if (success) {
  //     print('=== Join session successful, navigating to live stream ===');
  //     Get.back(); // Close dialog
  //     // Navigate to live streaming screen
  //     Get.to(() => LiveStreamingScreen(
  //       sessionId: widget.sessionId,
  //       sessionTitle: widget.sessionTitle, userName: '', token: '', userId: null,
  //     ));
  //   } else {
  //     Get.snackbar(
  //       'Error',
  //       'Failed to join session: ${_agoraViewModel.errorMessage.value}',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }

  void _skipToSchedule() {
    print('=== Skip to schedule tapped ===');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    text: 'Join Session',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Logo placeholder
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Center(
                child: AppText(
                  text: 'Welcome to ${widget.sessionTitle}',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              const AppText(
                text: 'Enter your display name for this session',
                fontSize: 14,
                color: Colors.black54,
              ),

              const SizedBox(height: 8),

              const AppText(
                text: 'Your nickname',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),

              const SizedBox(height: 8),

              // Nickname input
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  hintText: 'Enter your display name...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.lightGreyColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Join Session button
              Obx(() {
                if (_agoraViewModel.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: _joinSession,
                        text: 'Join Session',
                        backgroundColor: AppColors.primaryColor,
                        textColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: TextButton(
                        onPressed: _skipToSchedule,
                        child: const AppText(
                          text: 'Skip to Schedule',
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}