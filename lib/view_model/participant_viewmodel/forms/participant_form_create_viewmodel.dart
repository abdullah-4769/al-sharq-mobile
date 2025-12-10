import 'package:get/get.dart';
import '../../../data/request_models/participant_Request_models/forms/participant_form_create_model.dart';
import '../../../repository/participants_repository/form/participant_form_create_repo.dart';


class ParticipantFormCreateViewModel extends GetxController {
  final ParticipantFormCreateRepository _repository =
  ParticipantFormCreateRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSuccess = false.obs;

  Future<bool> createForum({
    required int sessionId,
    required int userId,
    required String title,
    required String content,
    required String tag,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isSuccess.value = false;

      final forumData = ParticipantFormCreateModel(
        sessionId: sessionId,
        userId: userId,
        title: title,
        content: content,
        tag: tag,
      );

      await _repository.createForum(forumData);

      isSuccess.value = true;
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void resetState() {
    isLoading.value = false;
    errorMessage.value = '';
    isSuccess.value = false;
  }
}