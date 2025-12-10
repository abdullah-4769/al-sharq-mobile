import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../data/request_models/sponsor/sponsor_product_model.dart';
import '../view_model/sponsor_viewmodel/sponsor_product_viewmodel.dart';

class SponsorAddProductWidget extends StatefulWidget {
  final int sponsorId;
  final VoidCallback onProductAdded;

  const SponsorAddProductWidget({
    super.key,
    required this.sponsorId,
    required this.onProductAdded,
  });

  @override
  State<SponsorAddProductWidget> createState() => _SponsorAddProductWidgetState();
}

class _SponsorAddProductWidgetState extends State<SponsorAddProductWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _viewModel = Get.find<SponsorProductViewModel>();

  void _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final product = SponsorProductCreate(
      sponsorId: widget.sponsorId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    final success = await _viewModel.addSponsorProduct(product);

    if (success) {
      _titleController.clear();
      _descriptionController.clear();
      widget.onProductAdded();
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'Add New Product',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            Obx(() {
              return CustomButton(
                text: _viewModel.addingProduct.value ? 'Adding...' : 'Add Product',
                onPressed: _viewModel.addingProduct.value ? null : _addProduct,
                backgroundColor: AppColors.primaryColor,
                isLoading: _viewModel.addingProduct.value,
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