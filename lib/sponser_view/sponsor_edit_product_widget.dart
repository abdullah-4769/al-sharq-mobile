import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../data/request_models/sponsor/sponsor_product_model.dart';
import '../view_model/sponsor_viewmodel/sponsor_product_viewmodel.dart';

class SponsorEditProductWidget extends StatefulWidget {
  final SponsorProduct product;
  final VoidCallback onProductUpdated;

  const SponsorEditProductWidget({
    super.key,
    required this.product,
    required this.onProductUpdated,
  });

  @override
  State<SponsorEditProductWidget> createState() => _SponsorEditProductWidgetState();
}

class _SponsorEditProductWidgetState extends State<SponsorEditProductWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _viewModel = Get.find<SponsorProductViewModel>();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.product.title;
    _descriptionController.text = widget.product.description;
  }

  void _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final product = SponsorProductCreate(
      sponsorId: widget.product.sponsorId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    final success = await _viewModel.updateSponsorProduct(widget.product.id, product);

    if (success) {
      widget.onProductUpdated();
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _titleController,
              hintText: 'Enter product title',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter product title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              hintText: 'Enter product description',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter product description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Obx(() {
              final isUpdating = _viewModel.updatingProductId.value == widget.product.id;
              return CustomButton(
                text: isUpdating ? 'Updating...' : 'Update Product',
                onPressed: isUpdating ? null : _updateProduct,
                backgroundColor: AppColors.primaryColor,
                isLoading: isUpdating,
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}