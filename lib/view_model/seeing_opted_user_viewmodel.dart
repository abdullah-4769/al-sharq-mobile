import 'package:get/get.dart';
import '../data/response/api_response.dart';
import '../data/response_models/seeing_opted_user_model.dart';
import '../repository/seeing_opted_user_repository.dart';
import '../utils/shared_preference.dart';

class SeeingOptedUserViewModel extends GetxController {
  final _repository = SeeingOptedUserRepository();

  final users = <SeeingOptedUser>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> loadOptedInUsers(int eventId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = await SharedPrefsHelper.getUserId();
      if (userId == null) {
        errorMessage.value = 'User not found';
        return;
      }

      final response = await _repository.getOptedInUsers(eventId, userId);

      if (response.status == Status.COMPLETED) {
        // Filter out duplicate users by ID
        final uniqueUsers = _removeDuplicates(response.data ?? []);
        users.value = uniqueUsers;

        print('📊 Showing ${uniqueUsers.length} unique users');
      } else {
        errorMessage.value = response.message ?? 'Failed to load users';
      }
    } catch (e) {
      errorMessage.value = 'Error loading users: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to remove duplicate users by ID
  List<SeeingOptedUser> _removeDuplicates(List<SeeingOptedUser> users) {
    final Map<int, SeeingOptedUser> uniqueUsers = {};

    for (final user in users) {
      if (!uniqueUsers.containsKey(user.id)) {
        uniqueUsers[user.id] = user;
      }
    }

    return uniqueUsers.values.toList();
  }

  void clearError() {
    errorMessage.value = '';
  }
}


// import 'package:get/get.dart';
// import '../data/response/api_response.dart';
// import '../data/response_models/seeing_opted_user_model.dart';
// import '../repository/seeing_opted_user_repository.dart';
// import '../utils/shared_preference.dart';
//
// class SeeingOptedUserViewModel extends GetxController {
//   final _repository = SeeingOptedUserRepository();
//
//   final users = <SeeingOptedUser>[].obs;
//   final isLoading = false.obs;
//   final errorMessage = ''.obs;
//
//   Future<void> loadOptedInUsers(int eventId) async {
//     try {
//       isLoading.value = true;
//       errorMessage.value = '';
//
//       final userId = await SharedPrefsHelper.getUserId();
//       if (userId == null) {
//         errorMessage.value = 'User not found';
//         return;
//       }
//
//       final response = await _repository.getOptedInUsers(eventId, userId);
//
//       if (response.status == Status.COMPLETED) {
//         users.value = response.data ?? [];
//       } else {
//         errorMessage.value = response.message ?? 'Failed to load users';
//       }
//     } catch (e) {
//       errorMessage.value = 'Error loading users: $e';
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   void clearError() {
//     errorMessage.value = '';
//   }
// }