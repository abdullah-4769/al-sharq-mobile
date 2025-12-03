import 'package:get/get.dart';
import '../../../data/response_models/participant_response_model/participant_profile/participant_profile_update_model.dart';
import '../../../repository/participants_repository/participant_profile/participant_profile_update_repo.dart';
import '../../../utils/shared_preference.dart';

class ParticipantProfileUpdateViewModel extends GetxController {
  final ParticipantProfileUpdateRepository _repository = ParticipantProfileUpdateRepository();

  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _successMessage = ''.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  String get successMessage => _successMessage.value;

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? organization, // Made nullable
    String? filePath,
    String? bio,
  }) async {
    _isLoading.value = true;
    _error.value = '';
    _successMessage.value = '';
    update();

    try {
      final response = await _repository.updateProfile(
        name: name,
        email: email,
        organization: organization, // Can be null
        filePath: filePath,
        bio: bio,
      );

      _successMessage.value = response.message;
      _isLoading.value = false;
      update();

      // Optionally update SharedPreferences with new user data
      await _updateLocalStorage(response.user);

      return true;
    } catch (e) {
      _error.value = e.toString().replaceAll('Exception: ', '');
      _isLoading.value = false;
      update();
      return false;
    }
  }

  // Helper method to update SharedPreferences with new user data
  Future<void> _updateLocalStorage(UpdatedUser user) async {
    try {
      await SharedPrefsHelper.saveUserName(user.name);
      await SharedPrefsHelper.saveUserEmail(user.email);

      // Only save organization if it exists
      if (user.organization != null && user.organization!.isNotEmpty) {
        await SharedPrefsHelper.saveUserOrganization(user.organization!);
      }

      // Save bio if exists
      if (user.bio != null && user.bio!.isNotEmpty) {
        await SharedPrefsHelper.saveUserBio(user.bio!);
      }

      // Save profile image if exists
      if (user.file != null && user.file!.isNotEmpty) {
        await SharedPrefsHelper.saveUserPhoto(user.file!);
      }
    } catch (e) {
      print('Error updating local storage: $e');
    }
  }

  void clearError() {
    _error.value = '';
    update();
  }

  void clearSuccessMessage() {
    _successMessage.value = '';
    update();
  }
}











// import 'package:get/get.dart';
// import '../../../repository/participants_repository/participant_profile/participant_profile_update_repo.dart';
//
// class ParticipantProfileUpdateViewModel extends GetxController {
//   final ParticipantProfileUpdateRepository _repository = ParticipantProfileUpdateRepository();
//
//   final RxBool _isLoading = false.obs;
//   final RxString _error = ''.obs;
//   final RxString _successMessage = ''.obs;
//
//   bool get isLoading => _isLoading.value;
//   String get error => _error.value;
//   String get successMessage => _successMessage.value;
//
//   Future<bool> updateProfile({
//     required String name,
//     required String email,
//     required String organization,
//     String? filePath,
//     String? bio, // Added bio parameter
//   }) async {
//     _isLoading.value = true;
//     _error.value = '';
//     _successMessage.value = '';
//     update();
//
//     try {
//       final response = await _repository.updateProfile(
//         name: name,
//         email: email,
//         organization: organization,
//         filePath: filePath,
//         bio: bio, // Pass bio to repository
//       );
//
//       _successMessage.value = response.message;
//       _isLoading.value = false;
//       update();
//       return true;
//     } catch (e) {
//       _error.value = e.toString();
//       _isLoading.value = false;
//       update();
//       return false;
//     }
//   }
//
//   void clearError() {
//     _error.value = '';
//     update();
//   }
//
//   void clearSuccessMessage() {
//     _successMessage.value = '';
//     update();
//   }
// }