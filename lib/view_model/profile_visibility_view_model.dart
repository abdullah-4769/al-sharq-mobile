import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../utils/api_constants.dart';
import '../utils/shared_preference.dart';

class ProfileVisibilityViewModel extends GetxController {
  final Dio _dio = Dio();
  RxBool isVisible = false.obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  int? _cachedUserId;
  int? _cachedEventId;

  @override
  void onInit() {
    super.onInit();
    print('🟡 ProfileVisibilityViewModel initialized');
    _fetchProfileVisibility();
  }

  Future<void> _fetchProfileVisibility() async {
    try {
      print('🟡 Starting to fetch profile visibility...');
      isLoading.value = true;
      errorMessage.value = '';

      _cachedUserId ??= await SharedPrefsHelper.getUserId();
      _cachedEventId ??= await SharedPrefsHelper.getLatestEventId();

      print('🔵 User ID: $_cachedUserId, Event ID: $_cachedEventId');

      if (_cachedUserId == null || _cachedEventId == null) {
        errorMessage.value = 'User or Event ID not found';
        isLoading.value = false;
        print('🔴 Error: User or Event ID not found');
        return;
      }

      final url = ApiConstants.getProfileVisibility(_cachedUserId!, _cachedEventId!);
      print('🟡 API URL: $url');

      final response = await _dio.get(url);
      print('🟢 API Response Status: ${response.statusCode}');
      print('🟢 API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        isVisible.value = data['optedIn'] ?? false;
        print('✅ Profile visibility fetched: ${isVisible.value}');
      } else {
        print('🔴 API returned non-200 status: ${response.statusCode}');
        isVisible.value = false;
      }
    } catch (e) {
      print('🔴 Error fetching profile visibility: $e');
      errorMessage.value = 'Failed to fetch profile visibility';
      isVisible.value = false;
    } finally {
      isLoading.value = false;
      print('🟡 Fetch profile visibility completed');
    }
  }

  Future<void> updateProfileVisibility(bool visible) async {
    try {
      print('🟡 Starting to update profile visibility to: $visible');

      // ✅ OPTIMISTIC UPDATE: Update UI immediately
      final previousValue = isVisible.value;
      isVisible.value = visible;
      print('🟡 UI updated optimistically to: $visible');

      _cachedUserId ??= await SharedPrefsHelper.getUserId();
      _cachedEventId ??= await SharedPrefsHelper.getLatestEventId();

      print('🔵 User ID: $_cachedUserId, Event ID: $_cachedEventId');

      if (_cachedUserId == null || _cachedEventId == null) {
        errorMessage.value = 'User or Event ID not found';
        isVisible.value = previousValue; // Revert on error
        print('🔴 Error: User or Event ID not found, reverting UI');
        return;
      }

      final body = {
        'userId': _cachedUserId,
        'eventId': _cachedEventId,
        'optedIn': visible,
      };

      print('🟡 Request Body: $body');
      print('🟡 API URL: ${ApiConstants.updateProfileVisibility}');

      // ✅ Send API request in background
      _dio.post(
        ApiConstants.updateProfileVisibility,
        data: body,
      ).then((response) {
        print('🟢 API Response Status: ${response.statusCode}');
        print('🟢 API Response Data: ${response.data}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success
          print('✅ Profile visibility updated successfully to: $visible');
          Get.snackbar(
            'Success',
            visible ? 'Your profile is now visible' : 'Your profile is now hidden',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primaryColor,
            colorText: AppColors.white,
          );
        } else {
          // API error
          print('🔴 API returned error status: ${response.statusCode}');
          isVisible.value = previousValue; // Revert on error
          Get.snackbar(
            'Error',
            'Failed to update profile visibility',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primaryColor,
            colorText: AppColors.white,
          );
        }
      }).catchError((error) {
        // Network error
        print('🔴 Network error updating profile visibility: $error');
        isVisible.value = previousValue; // Revert on error
        Get.snackbar(
          'Error',
          'Network error: Failed to update profile visibility',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryColor,
          colorText: AppColors.white,
        );
      });

    } catch (e) {
      print('🔴 Unexpected error in updateProfileVisibility: $e');
      isVisible.value = !visible; // Revert on error
    }
  }

  // Utility method to print current state
  void printCurrentState() {
    print('''
📊 ProfileVisibilityViewModel State:
   - isVisible: ${isVisible.value}
   - isLoading: ${isLoading.value}
   - errorMessage: ${errorMessage.value}
   - cachedUserId: $_cachedUserId
   - cachedEventId: $_cachedEventId
''');
  }
}