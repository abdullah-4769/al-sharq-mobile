import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../data/request_models/sponsor/sponsor_product_model.dart';
import '../../view_model/sponsor_viewmodel/sponsor_product_viewmodel.dart';
import 'sponsor_edit_product_widget.dart';

class SponsorShowProductsWidget extends StatelessWidget {
  final int sponsorId;

  const SponsorShowProductsWidget({super.key, required this.sponsorId});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<SponsorProductViewModel>();

    return Obx(() {
      if (viewModel.isLoading.value) {
        return _buildLoadingState();
      }

      if (viewModel.products.isEmpty) {
        return _buildEmptyState();
      }

      return _buildProductsList(viewModel);
    });
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.mediumGreyColor),
          const SizedBox(height: 16),
          AppText(
            text: 'No Products Added Yet',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Add your first product to get started',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(SponsorProductViewModel viewModel) {
    final productCount = viewModel.products.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Your Products ($productCount)',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        const SizedBox(height: 16),

        // Dynamic height based on product count
        if (productCount == 1)
          _buildSingleProduct(viewModel.products.first, viewModel)
        else
          _buildMultipleProducts(viewModel),
      ],
    );
  }

  // For single product - no fixed height, no scroll
  Widget _buildSingleProduct(SponsorProduct product, SponsorProductViewModel viewModel) {
    return _buildProductItem(product, viewModel);
  }

  // For multiple products - fixed height with scroll
  Widget _buildMultipleProducts(SponsorProductViewModel viewModel) {
    // Calculate dynamic height based on product count (max 5 items visible)
    final productCount = viewModel.products.length;
    final maxVisibleItems = 5;
    final itemHeight = 120.0; // Approximate height per item
    final calculatedHeight = (productCount > maxVisibleItems
        ? maxVisibleItems * itemHeight
        : productCount * itemHeight);

    return SizedBox(
      height: calculatedHeight,
      child: Scrollbar(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: viewModel.products.length,
          itemBuilder: (context, index) {
            final product = viewModel.products[index];
            return _buildProductItem(product, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildProductItem(SponsorProduct product, SponsorProductViewModel viewModel) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: product.title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildActionIcons(product, viewModel),
            ],
          ),
          const SizedBox(height: 8),
          AppText(
            text: product.description,
            fontSize: 14,
            color: AppColors.darkgrey,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Added: ${_formatDate(product.createdAt)}',
            fontSize: 12,
            color: AppColors.mediumGreyColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcons(SponsorProduct product, SponsorProductViewModel viewModel) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Icon
        Obx(() {
          final isUpdating = viewModel.updatingProductId.value == product.id;
          return IconButton(
            icon: isUpdating
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            )
                : Icon(Icons.edit, color: AppColors.primaryColor, size: 20),
            onPressed: isUpdating ? null : () => _showEditDialog(product),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          );
        }),
        const SizedBox(width: 4),
        // Delete Icon
        Obx(() {
          final isDeleting = viewModel.deletingProductId.value == product.id;
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
                : Icon(Icons.delete, color: AppColors.errorColor, size: 20),
            onPressed: isDeleting ? null : () => _showDeleteDialog(product, viewModel),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          );
        }),
      ],
    );
  }

  void _showEditDialog(SponsorProduct product) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: AppText(
          text: 'Edit Product',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        content: SponsorEditProductWidget(
          product: product,
          onProductUpdated: () => Get.find<SponsorProductViewModel>().loadSponsorProducts(sponsorId),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  void _showDeleteDialog(SponsorProduct product, SponsorProductViewModel viewModel) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: AppText(
          text: 'Delete Product',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        content: AppText(
          text: 'Are you sure you want to delete "${product.title}"?',
          fontSize: 14,
          color: AppColors.darkgrey,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // This closes only the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // First close the dialog
              Get.back();

              // Then delete the product
              final success = await viewModel.deleteSponsorProduct(product.id);

              // Show success/error message but DON'T navigate back
              if (success) {
                Get.snackbar(
                  'Success',
                  'Product deleted successfully!',
                  backgroundColor: AppColors.successColor,
                  colorText: Colors.white,
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}