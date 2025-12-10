import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../view_model/sponsor_viewmodel/sponsor_representative_viewmodel.dart';

class SponsorShowRepresentativesWidget extends StatelessWidget {
  final int sponsorId;

  const SponsorShowRepresentativesWidget({super.key, required this.sponsorId});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<SponsorRepresentativeViewModel>();

    return Obx(() {
      print('🔄 Building representatives list: ${viewModel.representatives.length} items');

      if (viewModel.isLoading.value) {
        return _buildLoadingState();
      }

      if (viewModel.representatives.isEmpty) {
        return _buildEmptyState();
      }

      return _buildRepresentativesList(viewModel);
    });
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          const SizedBox(height: 16),
          AppText(
            text: 'Loading representatives...',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.mediumGreyColor),
          const SizedBox(height: 16),
          AppText(
            text: 'No Representatives Yet',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Add your first representative to get started',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRepresentativesList(SponsorRepresentativeViewModel viewModel) {
    final representativeCount = viewModel.representatives.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: 'Your Representatives ($representativeCount)',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.primaryColor),
              onPressed: () => viewModel.loadSponsorRepresentatives(sponsorId),
              tooltip: 'Refresh list',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Dynamic height based on representative count
        if (representativeCount == 1)
          _buildSingleRepresentative(viewModel.representatives.first, viewModel)
        else
          _buildMultipleRepresentatives(viewModel),
      ],
    );
  }

  Widget _buildSingleRepresentative(representative, SponsorRepresentativeViewModel viewModel) {
    return _buildRepresentativeItem(representative, viewModel);
  }

  Widget _buildMultipleRepresentatives(SponsorRepresentativeViewModel viewModel) {
    // Calculate dynamic height
    final representativeCount = viewModel.representatives.length;
    final maxVisibleItems = 5;
    final itemHeight = 100.0;
    final calculatedHeight = (representativeCount > maxVisibleItems
        ? maxVisibleItems * itemHeight
        : representativeCount * itemHeight);

    return SizedBox(
      height: calculatedHeight,
      child: Scrollbar(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: viewModel.representatives.length,
          itemBuilder: (context, index) {
            final representative = viewModel.representatives[index];
            return _buildRepresentativeItem(representative, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildRepresentativeItem(representative, SponsorRepresentativeViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Image and Info
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                  ),
                  child: CircleAvatar(
                    backgroundColor: AppColors.mediumGreyColor,
                    backgroundImage: representative.user.file != null
                        ? NetworkImage(representative.user.file!)
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: representative.user.name,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AppText(
                          text: representative.displayTitle,
                          fontSize: 12,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (representative.user.organization != null)
                        AppText(
                          text: representative.user.organization!,
                          fontSize: 12,
                          color: AppColors.darkgrey,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Delete Icon
          Obx(() {
            final isDeleting = viewModel.deletingRepresentativeId.value == representative.id;
            return IconButton(
              icon: isDeleting
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.errorColor),
                ),
              )
                  : Icon(Icons.delete_outline, color: AppColors.errorColor, size: 22),
              onPressed: isDeleting ? null : () => _showDeleteDialog(representative, viewModel),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              tooltip: 'Remove representative',
            );
          }),
        ],
      ),
    );
  }

  void _showDeleteDialog(representative, SponsorRepresentativeViewModel viewModel) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person_remove, color: AppColors.errorColor),
            const SizedBox(width: 8),
            AppText(
              text: 'Remove Representative',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'Are you sure you want to remove the following representative?',
              fontSize: 14,
              color: AppColors.darkgrey,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mediumGreyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: representative.user.name,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: representative.displayTitle,
                    fontSize: 12,
                    color: AppColors.primaryColor,
                  ),
                  if (representative.user.organization != null) ...[
                    const SizedBox(height: 4),
                    AppText(
                      text: representative.user.organization!,
                      fontSize: 12,
                      color: AppColors.darkgrey,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await viewModel.deleteSponsorRepresentative(representative.id);

              if (success) {
                Get.snackbar(
                  'Success',
                  '${representative.user.name} removed as representative',
                  backgroundColor: AppColors.successColor,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              } else {
                Get.snackbar(
                  'Error',
                  viewModel.errorMessage.value,
                  backgroundColor: AppColors.errorColor,
                  colorText: Colors.white,
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorColor,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}