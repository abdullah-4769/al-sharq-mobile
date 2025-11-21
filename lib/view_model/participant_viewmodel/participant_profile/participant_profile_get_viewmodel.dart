import 'package:get/get.dart';
import '../../../data/response_models/participant_response_model/participant_profile/participant_profile_get_model.dart';
import '../../../participants_view/profile_screen/edit_profile_view.dart';
import '../../../repository/participants_repository/participant_profile/participant_profile_get_repo.dart';


class ParticipantProfileGetViewModel extends GetxController {
  final ParticipantProfileGetRepository _repository = ParticipantProfileGetRepository();

  final Rx<ParticipantProfileGetModel?> _profile = Rx<ParticipantProfileGetModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  ParticipantProfileGetModel? get profile => _profile.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  Future<void> fetchProfile() async {
    _isLoading.value = true;
    _error.value = '';
    update();

    try {
      _profile.value = await _repository.getProfile();
    } catch (e) {
      _error.value = e.toString();
      print('DEBUG: ViewModel error: $e');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  void clearError() {
    _error.value = '';
    update();
  }
}