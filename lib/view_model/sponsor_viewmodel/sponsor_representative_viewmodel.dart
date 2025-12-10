
import 'package:get/get.dart';
import '../../data/request_models/sponsor/sponsor_representative_model.dart';
import '../../data/response/api_response.dart';
import '../../repository/sponsor_repo/sponsor_representative_repository.dart';

class SponsorRepresentativeViewModel extends GetxController {
  final _repo = SponsorRepresentativeRepository();

  final representatives = <SponsorRepresentative>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  // For button loaders
  final addingRepresentative = false.obs;
  final deletingRepresentativeId = Rx<int?>(null);

  Future<void> loadSponsorRepresentatives(int sponsorId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repo.getSponsorRepresentatives(sponsorId);

      if (response.status == Status.COMPLETED) {
        representatives.value = response.data ?? [];
      } else {
        errorMessage.value = response.message ?? 'Failed to load representatives';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  Future<bool> addSponsorRepresentative(SponsorRepresentativeCreate representative) async {
    try {
      addingRepresentative.value = true;
      errorMessage.value = '';

      final response = await _repo.addSponsorRepresentative(representative);

      if (response.status == Status.COMPLETED) {
        // ✅ Automatically refresh the list after successful addition
        await loadSponsorRepresentatives(representative.sponsorId);
        successMessage.value = 'Representative added successfully!';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to add representative';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      addingRepresentative.value = false;
    }
  }

  Future<bool> deleteSponsorRepresentative(int representativeId) async {
    try {
      deletingRepresentativeId.value = representativeId;
      errorMessage.value = '';

      final response = await _repo.deleteSponsorRepresentative(representativeId);

      if (response.status == Status.COMPLETED) {
        representatives.removeWhere((r) => r.id == representativeId);
        successMessage.value = 'Representative deleted successfully!';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to delete representative';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      deletingRepresentativeId.value = null;
    }
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}