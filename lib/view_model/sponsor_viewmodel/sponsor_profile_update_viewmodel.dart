import 'package:get/get.dart';

import '../../data/response/api_response.dart';
import '../../data/response_models/sponsor_respone_model/sponsor_profile_get_model.dart';
import '../../data/response_models/sponsor_respone_model/sponsor_profile_update_model.dart';
import '../../repository/sponsor_repo/sponsor_profile_update_repository.dart';

class SponsorProfileUpdateViewModel extends GetxController {
  final _repo = SponsorProfileUpdateRepository();

  final Rx<ApiResponse<SponsorProfileGetModel>?> updateResponse = Rx<ApiResponse<SponsorProfileGetModel>?>(null);
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  Future<bool> updateSponsorProfile(SponsorProfileUpdateModel updateData) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      updateResponse.value = ApiResponse.loading();

      final response = await _repo.updateSponsorProfile(updateData);

      if (response.status == Status.COMPLETED) {
        updateResponse.value = response;
        successMessage.value = 'Profile updated successfully!';
        return true;
      } else {
        updateResponse.value = ApiResponse.error(response.message);
        errorMessage.value = response.message ?? 'Failed to update profile';
        return false;
      }
    } catch (e) {
      updateResponse.value = ApiResponse.error(e.toString());
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }
}