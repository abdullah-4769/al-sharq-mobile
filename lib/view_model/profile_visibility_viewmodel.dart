import 'package:get/get.dart';

import '../data/request_models/profile_visibility_model.dart';
import '../data/response/api_response.dart';
import '../repository/profile_visibility_repository.dart';
import '../utils/shared_preference.dart';


class ProfileVisibilityViewModel extends GetxController {
  final _repository = ProfileVisibilityRepository();

  final isLoading = false.obs;
  final isOptedIn = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileVisibilityStatus();
  }

  Future<void> loadProfileVisibilityStatus() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = await SharedPrefsHelper.getUserId();
      final eventId = await SharedPrefsHelper.getLatestEventId();

      if (userId == null || eventId == null) {
        errorMessage.value = 'User or event information not found';
        isLoading.value = false;
        return;
      }

      final response = await _repository.getProfileVisibilityStatus(userId, eventId);

      if (response.status == Status.COMPLETED) {
        isOptedIn.value = response.data!.optedIn;
      } else {
        errorMessage.value = response.message ?? 'Failed to load visibility status';
        // Default to false if there's an error
        isOptedIn.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Error loading visibility status: $e';
      isOptedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> toggleProfileVisibility(bool newValue) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = await SharedPrefsHelper.getUserId();
      final eventId = await SharedPrefsHelper.getLatestEventId();

      if (userId == null || eventId == null) {
        errorMessage.value = 'User or event information not found';
        return false;
      }

      final request = ProfileVisibilityRequest(
        userId: userId,
        eventId: eventId,
        optedIn: newValue,
      );

      final response = await _repository.updateProfileVisibility(request);

      if (response.status == Status.COMPLETED) {
        isOptedIn.value = newValue;
        successMessage.value = newValue
            ? 'Your profile is now visible to other participants'
            : 'Your profile is now hidden from other participants';
        return true;
      } else {
        errorMessage.value = response.message ?? 'Failed to update visibility';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error updating visibility: $e';
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