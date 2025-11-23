
import 'package:get/get.dart';

import '../../data/response/api_response.dart';
import '../../data/response_models/sponsor_respone_model/sponsor_profile_get_model.dart';
import '../../repository/sponsor_repo/sponsor_profile_get_repository.dart';

class SponsorProfileGetViewModel extends GetxController {
  final _repo = SponsorProfileGetRepository();

  final Rx<ApiResponse<SponsorProfileGetModel>?> sponsorProfile = Rx<ApiResponse<SponsorProfileGetModel>?>(null);
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> fetchSponsorProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      sponsorProfile.value = ApiResponse.loading();

      final response = await _repo.getSponsorProfile();

      if (response.status == Status.COMPLETED) {
        sponsorProfile.value = response;
      } else {
        sponsorProfile.value = ApiResponse.error(response.message);
        errorMessage.value = response.message ?? 'Unknown error occurred';
      }
    } catch (e) {
      sponsorProfile.value = ApiResponse.error(e.toString());
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void refreshProfile() {
    fetchSponsorProfile();
  }
}