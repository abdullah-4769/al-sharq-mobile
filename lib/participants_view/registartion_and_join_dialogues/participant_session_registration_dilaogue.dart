import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

import '../../view_model/participant_viewmodel/registration_and _join_viewmodels/participant_session_registration_viewmodel.dart';

class ParticipantSessionRegistrationDialog extends StatefulWidget {
  final int sessionId;
  final Function()? onRegistrationSuccess;

  const ParticipantSessionRegistrationDialog({
    super.key,
    required this.sessionId,
    this.onRegistrationSuccess,
  });

  @override
  State<ParticipantSessionRegistrationDialog> createState() => _ParticipantSessionRegistrationDialogState();
}

class _ParticipantSessionRegistrationDialogState extends State<ParticipantSessionRegistrationDialog> {
  final ParticipantSessionRegistrationViewModel _viewModel = Get.put(ParticipantSessionRegistrationViewModel());
  final TextEditingController _whyJoinController = TextEditingController();
  final TextEditingController _relevantExperienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('=== ParticipantSessionRegistrationDialog init for session: ${widget.sessionId} ===');
  }

  @override
  void dispose() {
    _whyJoinController.dispose();
    _relevantExperienceController.dispose();
    super.dispose();
  }

  Future<void> _registerForSession() async {
    print('=== Starting registration process for session: ${widget.sessionId} ===');

    if (_whyJoinController.text.isEmpty || _relevantExperienceController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _viewModel.registerForSession(
      sessionId: widget.sessionId,
      whyJoin: _whyJoinController.text,
      relevantExperience: _relevantExperienceController.text,
    );

    if (success) {
      print('=== Registration successful for session: ${widget.sessionId} ===');
      Get.back(); // Close dialog
      if (widget.onRegistrationSuccess != null) {
        widget.onRegistrationSuccess!();
      }
      Get.snackbar(
        'Success',
        'Registered for session successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to register for session: ${_viewModel.errorMessage.value}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    text: 'Apply for Session',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () {
                      print('=== Registration dialog closed ===');
                      Get.back();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const AppText(
                text: 'Please fill below information',
                fontSize: 14,
                color: Colors.black54,
              ),

              const SizedBox(height: 24),

              // Why do you want to join field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    text: 'Why do you want to join?',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _whyJoinController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Explain why you want to attend this session...',
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
                ],
              ),

              const SizedBox(height: 20),

              // Relevant experience field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    text: 'Relevant Experience',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _relevantExperienceController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Describe your relevant experience...',
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
                ],
              ),

              const SizedBox(height: 32),

              // Register button
              Obx(() {
                if (_viewModel.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: _registerForSession,
                    text: 'Register',
                    backgroundColor: AppColors.primaryColor,
                    textColor: Colors.white,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}