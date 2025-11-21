import 'package:get/get.dart';
import '../../data/response_models/organizer_response_models/organizershowallspeaker_model.dart';
import '../../repository/organizer_repo/organizershowallspeaker_repository.dart';

class OrganizerShowAllSpeakerViewModel extends GetxController {
  final OrganizerShowAllSpeakerRepository _repository = OrganizerShowAllSpeakerRepository();

  var isLoading = false.obs;
  var error = ''.obs;
  var speakersData = Rxn<OrganizerShowAllSpeakerModel>();

  // Search and filter
  var searchQuery = ''.obs;
  var selectedFilter = 0.obs; // 0: All, 1: Featured, 2: Verified, 3: Standard

  // Getter for all speakers
  List<OrganizerSpeaker> get allSpeakers {
    return speakersData.value?.speakers ?? [];
  }

  // Getter for filtered speakers
  List<OrganizerSpeaker> get filteredSpeakers {
    var filtered = allSpeakers;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((speaker) {
        return speaker.user.name.toLowerCase().contains(query) ||
            speaker.bio.toLowerCase().contains(query) ||
            speaker.designations.any((designation) => designation.toLowerCase().contains(query)) ||
            speaker.expertise.any((exp) => exp.toLowerCase().contains(query)) ||
            speaker.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Apply category filter
    switch (selectedFilter.value) {
      case 1: // Featured
        filtered = filtered.where((speaker) => speaker.featured).toList();
        break;
      case 2: // Verified
        filtered = filtered.where((speaker) => speaker.verified).toList();
        break;
      case 3: // Standard
        filtered = filtered.where((speaker) => !speaker.featured && !speaker.verified).toList();
        break;
      default: // All
        break;
    }

    return filtered;
  }

  // Statistics
  int get totalSpeakers => allSpeakers.length;
  int get featuredSpeakers => allSpeakers.where((speaker) => speaker.featured).length;
  int get verifiedSpeakers => allSpeakers.where((speaker) => speaker.verified).length;
  int get standardSpeakers => allSpeakers.where((speaker) => !speaker.featured && !speaker.verified).length;

  Future<void> fetchAllSpeakers() async {
    try {
      isLoading(true);
      error('');

      final data = await _repository.fetchAllSpeakers();
      speakersData(data);

      print('=== Fetched ${allSpeakers.length} speakers ===');
      print('=== Featured: $featuredSpeakers, Verified: $verifiedSpeakers ===');
    } catch (e) {
      error('Failed to load speakers: $e');
      print('Error in OrganizerShowAllSpeakerViewModel: $e');
    } finally {
      isLoading(false);
    }
  }

  void searchSpeakers(String query) {
    searchQuery(query);
  }

  void setFilter(int filterIndex) {
    selectedFilter(filterIndex);
  }

  // Delete speaker (placeholder for future implementation)
  Future<void> deleteSpeaker(int speakerId) async {
    // TODO: Implement delete speaker functionality
    print('=== Deleting speaker with ID: $speakerId ===');
  }

  // Edit speaker (placeholder for future implementation)
  void editSpeaker(OrganizerSpeaker speaker) {
    // TODO: Implement edit speaker functionality
    print('=== Editing speaker: ${speaker.user.name} ===');
  }
}