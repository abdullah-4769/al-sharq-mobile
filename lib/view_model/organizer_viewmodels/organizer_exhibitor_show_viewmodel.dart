import 'package:get/get.dart';
import '../../data/response_models/organizer_response_models/organizer_exhibitor_show_model.dart';
import '../../repository/organizer_repo/organizer_exhibitor_show_repository.dart';

class OrganizerExhibitorShowViewModel extends GetxController {
  final OrganizerExhibitorShowRepository _repository = OrganizerExhibitorShowRepository();

  var isLoading = false.obs;
  var error = ''.obs;
  var exhibitorsData = Rxn<OrganizerExhibitorShowModel>();

  // Getter for all exhibitors
  List<OrganizerExhibitor> get allExhibitors {
    return exhibitorsData.value?.exhibitors ?? [];
  }

  // Getter for exhibitors with booths
  List<OrganizerExhibitor> get exhibitorsWithBooths {
    return allExhibitors.where((exhibitor) => exhibitor.booths.isNotEmpty).toList();
  }

  // Getter for exhibitors without booths
  List<OrganizerExhibitor> get exhibitorsWithoutBooths {
    return allExhibitors.where((exhibitor) => exhibitor.booths.isEmpty).toList();
  }

  // Statistics
  int get totalExhibitors => allExhibitors.length;
  int get exhibitorsWithBoothsCount => exhibitorsWithBooths.length;
  int get exhibitorsWithoutBoothsCount => exhibitorsWithoutBooths.length;
  int get totalProducts {
    return allExhibitors.fold(0, (sum, exhibitor) => sum + exhibitor.products.length);
  }
  int get totalBooths {
    return allExhibitors.fold(0, (sum, exhibitor) => sum + exhibitor.booths.length);
  }

  Future<void> fetchExhibitors() async {
    try {
      isLoading(true);
      error('');

      final data = await _repository.fetchExhibitors();
      exhibitorsData(data);

      print('=== Fetched ${allExhibitors.length} exhibitors ===');
      print('=== Exhibitors with booths: $exhibitorsWithBoothsCount ===');
      print('=== Total products: $totalProducts ===');
    } catch (e) {
      error('Failed to load exhibitors: $e');
      print('Error in OrganizerExhibitorShowViewModel: $e');
    } finally {
      isLoading(false);
    }
  }

  // Search functionality
  List<OrganizerExhibitor> searchExhibitors(String query) {
    if (query.isEmpty) return allExhibitors;

    final lowerQuery = query.toLowerCase();
    return allExhibitors.where((exhibitor) {
      return exhibitor.name.toLowerCase().contains(lowerQuery) ||
          exhibitor.location.toLowerCase().contains(lowerQuery) ||
          exhibitor.description.toLowerCase().contains(lowerQuery) ||
          exhibitor.booths.any((booth) =>
          booth.boothNumber.toLowerCase().contains(lowerQuery) ||
              booth.boothLocation.toLowerCase().contains(lowerQuery)
          );
    }).toList();
  }
}