// lib/view_model/participant_viewmodel/speaker_short_detail_viewmodel.dart

import 'package:get/get.dart';
import '../../../data/response_models/participant_response_model/speaker_part_in_participant/speaker_short_detail_responsemodel.dart';
import '../../../repository/participants_repository/speaker_part_in_participant/speaker_short_detail_repo.dart';

class SpeakerShortDetailViewModel extends GetxController {
  final SpeakerShortDetailRepo _repo = SpeakerShortDetailRepo();

  final RxList<SpeakerShortDetail> _allSpeakers = <SpeakerShortDetail>[].obs;
  final RxList<SpeakerShortDetail> _filteredSpeakers = <SpeakerShortDetail>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedFilter = 0.obs; // 0: All, 1: Keynote, 2: Technology, 3: Business

  List<SpeakerShortDetail> get allSpeakers => _allSpeakers;
  List<SpeakerShortDetail> get filteredSpeakers => _filteredSpeakers;

  Future<void> fetchSpeakerShortDetails(int eventId) async {
    try {
      print('=== Fetching speaker short details for event: $eventId ===');
      isLoading.value = true;
      errorMessage.value = '';

      final speakers = await _repo.getSpeakerShortDetails(eventId);

      _allSpeakers.assignAll(speakers);
      _filteredSpeakers.assignAll(speakers);

      print('=== Successfully loaded ${speakers.length} speakers ===');
    } catch (e) {
      errorMessage.value = 'Failed to load speakers: $e';
      print('=== Error loading speakers: $e ===');
    } finally {
      isLoading.value = false;
    }
  }

  void searchSpeakers(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      _applyFilter(selectedFilter.value);
    } else {
      final filtered = _allSpeakers.where((speaker) =>
      speaker.user.name.toLowerCase().contains(query.toLowerCase()) ||
          speaker.bio.toLowerCase().contains(query.toLowerCase()) ||
          speaker.designations.any((designation) =>
              designation.toLowerCase().contains(query.toLowerCase())
          ) ||
          speaker.expertise.any((exp) =>
              exp.toLowerCase().contains(query.toLowerCase())
          ) ||
          speaker.tags.any((tag) =>
              tag.toLowerCase().contains(query.toLowerCase())
          )
      ).toList();

      _filteredSpeakers.assignAll(filtered);
    }
  }

  void setFilter(int filterIndex) {
    selectedFilter.value = filterIndex;
    _applyFilter(filterIndex);
  }

  void _applyFilter(int filterIndex) {
    List<SpeakerShortDetail> filtered = _allSpeakers;

    if (filterIndex == 1) { // Keynote
      filtered = _allSpeakers.where((speaker) =>
      speaker.hasTag('keynote') ||
          speaker.tags.any((tag) => tag.toLowerCase().contains('keynote'))
      ).toList();
    } else if (filterIndex == 2) { // Technology
      filtered = _allSpeakers.where((speaker) =>
      speaker.hasTag('technology') ||
          speaker.expertise.any((exp) => exp.toLowerCase().contains('tech')) ||
          speaker.tags.any((tag) => tag.toLowerCase().contains('tech'))
      ).toList();
    } else if (filterIndex == 3) { // Business
      filtered = _allSpeakers.where((speaker) =>
      speaker.hasTag('business') ||
          speaker.designations.any((designation) =>
          designation.toLowerCase().contains('business') ||
              designation.toLowerCase().contains('manager') ||
              designation.toLowerCase().contains('director') ||
              designation.toLowerCase().contains('vp') ||
              designation.toLowerCase().contains('ceo')
          )
      ).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((speaker) =>
      speaker.user.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          speaker.bio.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    _filteredSpeakers.assignAll(filtered);
  }

  void clearSpeakers() {
    _allSpeakers.clear();
    _filteredSpeakers.clear();
    errorMessage.value = '';
    searchQuery.value = '';
    selectedFilter.value = 0;
  }
}