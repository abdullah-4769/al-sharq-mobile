// lib/view_model/participant_viewmodel/speaker_part_in_participant/speaker_full_detail_viewmodel.dart

import 'package:get/get.dart';
import '../../../data/response_models/participant_response_model/speaker_part_in_participant/speaker_full_detail_response_model.dart';
import '../../../repository/participants_repository/speaker_part_in_participant/speaker_full_detail_repo.dart';

class SpeakerFullDetailViewModel extends GetxController {
  final SpeakerFullDetailRepo _repo = SpeakerFullDetailRepo();

  final Rx<SpeakerFullDetail?> _speaker = Rx<SpeakerFullDetail?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  SpeakerFullDetail? get speaker => _speaker.value;

  Future<void> fetchSpeakerFullDetails(int speakerId) async {
    try {
      print('=== Fetching speaker full details for ID: $speakerId ===');
      isLoading.value = true;
      errorMessage.value = '';

      final speakerDetail = await _repo.getSpeakerFullDetails(speakerId);
      _speaker.value = speakerDetail;

      print('=== Successfully loaded speaker: ${speakerDetail.user.name} ===');
    } catch (e) {
      errorMessage.value = 'Failed to load speaker details: $e';
      print('=== Error loading speaker details: $e ===');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSpeakerData() {
    _speaker.value = null;
    errorMessage.value = '';
  }
}