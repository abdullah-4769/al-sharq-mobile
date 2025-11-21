import 'package:get/get.dart';
import '../../../repository/participants_repository/form/forums_list_repo.dart';


class ForumsListViewModel extends GetxController {
  final ForumsListRepository _repository = ForumsListRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ForumsData> forumsData = ForumsData(
    id: 0,
    title: '',
    tags: [],
    forums: [],
  ).obs;

  Future<void> fetchForums(int sessionId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('=== Fetching forums for session: $sessionId ===');

      final data = await _repository.getForumsBySession(sessionId);
      forumsData.value = data;

      print('=== Successfully loaded ${data.forums.length} forums ===');

    } catch (e) {
      errorMessage.value = 'Failed to load discussions: $e';
      print('=== Error loading forums: $e ===');
    } finally {
      isLoading.value = false;
    }
  }

  void refreshForums(int sessionId) {
    fetchForums(sessionId);
  }
}