import 'package:get/get.dart';
import '../../data/request_models/sponsor/sponsor_product_model.dart';
import '../../data/response/api_response.dart';

import '../../repository/sponsor_repo/sponsor_product_repository.dart';

class SponsorProductViewModel extends GetxController {
  final _repo = SponsorProductRepository();

  final products = <SponsorProduct>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  // For button loaders
  final addingProduct = false.obs;
  final updatingProductId = Rx<int?>(null);
  final deletingProductId = Rx<int?>(null);

  Future<void> loadSponsorProducts(int sponsorId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repo.getSponsorProducts(sponsorId);

      if (response.status == Status.COMPLETED) {
        products.value = response.data ?? [];
      } else {
        errorMessage.value = response.message ?? 'Failed to load products';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addSponsorProduct(SponsorProductCreate product) async {
    try {
      addingProduct.value = true;
      errorMessage.value = '';

      final response = await _repo.addSponsorProduct(product);

      if (response.status == Status.COMPLETED) {
        products.insert(0, response.data!);
        successMessage.value = 'Product added successfully!';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to add product';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      addingProduct.value = false;
    }
  }

  Future<bool> updateSponsorProduct(int productId, SponsorProductCreate product) async {
    try {
      updatingProductId.value = productId;
      errorMessage.value = '';

      final response = await _repo.updateSponsorProduct(productId, product);

      if (response.status == Status.COMPLETED) {
        final index = products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          products[index] = response.data!;
        }
        successMessage.value = 'Product updated successfully!';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to update product';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      updatingProductId.value = null;
    }
  }

  Future<bool> deleteSponsorProduct(int productId) async {
    try {
      deletingProductId.value = productId;
      errorMessage.value = '';

      final response = await _repo.deleteSponsorProduct(productId);

      if (response.status == Status.COMPLETED) {
        products.removeWhere((p) => p.id == productId);
        successMessage.value = 'Product deleted successfully!';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to delete product';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      deletingProductId.value = null;
    }
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}