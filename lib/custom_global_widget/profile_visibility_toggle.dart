import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_colors/app_colors.dart';
import '../custom_widgets/app_text.dart';
import '../view_model/profile_visibility_viewmodel.dart';

class ProfileVisibilityToggle extends StatelessWidget {
  const ProfileVisibilityToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<ProfileVisibilityViewModel>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mediumGreyColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Row with Title, Description and Toggle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // Info Icon
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.visibility_outlined,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            AppText(
                              text: 'Profile Visibility',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blackColor,
                            ),
                            const SizedBox(width: 58),

                            // Toggle Switch with loading state
                            _buildToggleSwitch(viewModel),
                          ],
                        ),
                      ),

                     // const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: AppText(
                          text: 'Control who can view your profile in this venue',
                          fontSize: 13,
                          color: AppColors.darkgrey,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),

            // Loading Indicator only (no success/error messages)
            if (viewModel.isLoading.value) ...[
             // const SizedBox(height: 12),
              //_buildLoadingIndicator(),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildToggleSwitch(ProfileVisibilityViewModel viewModel) {
    return Stack(
      children: [
        // Toggle Switch
        Transform.scale(
          scale: 0.7,
          child: Switch(
            value: viewModel.isOptedIn.value,
            onChanged: viewModel.isLoading.value
                ? null
                : (value) async {
              final success = await viewModel.toggleProfileVisibility(value);
              if (!success) {
                // Show error snackbar if toggle fails
                Get.snackbar(
                  'Error',
                  viewModel.errorMessage.value,
                  backgroundColor: AppColors.errorColor,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
              // Removed success snackbar as per requirement
            },
            activeColor: AppColors.primaryColor,
            activeTrackColor: AppColors.primaryColor.withOpacity(0.4),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.mediumGreyColor.withOpacity(0.6),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),

        // Loading overlay
        if (viewModel.isLoading.value)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Widget _buildLoadingIndicator() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       SizedBox(
  //         width: 16,
  //         height: 16,
  //         child: CircularProgressIndicator(
  //           strokeWidth: 2,
  //           valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
  //         ),
  //       ),
  //       const SizedBox(width: 8),
  //       // AppText(
  //       //   text: 'Updating visibility...',
  //       //   fontSize: 12,
  //       //   color: AppColors.darkgrey,
  //       //   fontWeight: FontWeight.w500,
  //       // ),
  //     ],
  //   );
  // }
}




