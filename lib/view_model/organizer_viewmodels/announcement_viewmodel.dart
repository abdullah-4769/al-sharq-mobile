import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../data/request_models/announcement_model/announcement_model.dart';
import '../../repository/organizer_repo/announcement_repo/announcement_repository.dart';


class AnnouncementViewModel extends GetxController {
  final AnnouncementRepository _repository = AnnouncementRepository();

  final RxList<AnnouncementModel> allAnnouncements = <AnnouncementModel>[].obs;
  final RxList<AnnouncementModel> filteredAnnouncements = <AnnouncementModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs; // For showing sending indicator
  final RxString selectedFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Stats
  int get totalSent => allAnnouncements.where((a) => a.isSent).length;
  int get totalScheduled => allAnnouncements.where((a) => !a.isSent && a.scheduledAt != null).length;
  int get totalDrafts => allAnnouncements.where((a) => !a.isSent && a.scheduledAt == null).length;

  @override
  void onInit() {
    super.onInit();
    debugPrint('✅ AnnouncementViewModel initialized');
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      debugPrint('📡 Fetching announcements from API...');
      isLoading.value = true;
      final announcements = await _repository.getAllAnnouncements();
      debugPrint('✅ Fetched ${announcements.length} announcements');
      allAnnouncements.value = announcements;
      applyFilters();
    } catch (e) {
      debugPrint('❌ Error fetching announcements: $e');
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: Error fetching announcements: Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    debugPrint('🔍 Applying filters: ${selectedFilter.value}, search: "${searchQuery.value}"');
    var filtered = allAnnouncements.toList();

    // Apply status filter
    if (selectedFilter.value == 'sent') {
      filtered = filtered.where((a) => a.isSent).toList();
    } else if (selectedFilter.value == 'scheduled') {
      filtered = filtered.where((a) => !a.isSent && a.scheduledAt != null).toList();
    } else if (selectedFilter.value == 'draft') {
      filtered = filtered.where((a) => !a.isSent && a.scheduledAt == null).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((a) {
        final query = searchQuery.value.toLowerCase();
        return a.title.toLowerCase().contains(query) ||
            a.message.toLowerCase().contains(query);
      }).toList();
    }

    debugPrint('✅ Filtered to ${filtered.length} announcements');
    filteredAnnouncements.value = filtered;
  }

  void setFilter(String filter) {
    debugPrint('🎯 Setting filter to: $filter');
    selectedFilter.value = filter;
    applyFilters();
  }

  void setSearchQuery(String query) {
    debugPrint('🔎 Setting search query to: "$query"');
    searchQuery.value = query;
    applyFilters();
  }

  Future<bool> createAnnouncement(AnnouncementModel announcement) async {
    try {
      debugPrint('📝 Creating announcement: ${announcement.title}');
      debugPrint('   - Roles: ${announcement.roles}');
      debugPrint('   - Is Sent: ${announcement.isSent}');
      debugPrint('   - Scheduled At: ${announcement.scheduledAt}');

      isSending.value = true;
      final result = await _repository.createAnnouncement(announcement);
      debugPrint('✅ Announcement created successfully: ID ${result.id}');

      String message;
      if (announcement.isSent) {
        message = 'Announcement sent successfully!';
      } else if (announcement.scheduledAt != null) {
        message = 'Announcement scheduled successfully!';
      } else {
        message = 'Announcement saved as draft!';
      }

      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      await fetchAnnouncements();
      return true;
    } catch (e) {
      debugPrint('❌ Error creating announcement: $e');
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: Error creating announcement: Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
      return false;
    } finally {
      isSending.value = false;
    }
  }

  Future<bool> updateAnnouncement(int id, AnnouncementModel announcement) async {
    try {
      debugPrint('📝 Updating announcement ID: $id');
      debugPrint('   - Title: ${announcement.title}');
      debugPrint('   - Roles: ${announcement.roles}');
      debugPrint('   - Is Sent: ${announcement.isSent}');
      debugPrint('   - Scheduled At: ${announcement.scheduledAt}');

      isSending.value = true;
      final result = await _repository.updateAnnouncement(id, announcement);
      debugPrint('✅ Announcement updated successfully: ${result.title}');

      String message = announcement.isSent
          ? 'Announcement sent successfully!'
          : announcement.scheduledAt != null
          ? 'Announcement scheduled successfully!'
          : 'Announcement updated successfully!';

      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      await fetchAnnouncements();
      return true;
    } catch (e) {
      debugPrint('❌ Error updating announcement: $e');
      String errorMessage = e.toString();
      if (errorMessage.contains('already sent')) {
        errorMessage = 'This announcement has already been sent and cannot be updated';
      } else {
        errorMessage = errorMessage.replaceAll('Exception: Error updating announcement: Exception: ', '');
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
      return false;
    } finally {
      isSending.value = false;
    }
  }

  Future<void> deleteAnnouncement(int id) async {
    try {
      debugPrint('🗑️ Deleting announcement ID: $id');
      isLoading.value = true;
      await _repository.deleteAnnouncement(id);
      debugPrint('✅ Announcement deleted successfully');

      Get.snackbar(
        'Success',
        'Announcement deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      await fetchAnnouncements();
    } catch (e) {
      debugPrint('❌ Error deleting announcement: $e');
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: Error deleting announcement: Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}