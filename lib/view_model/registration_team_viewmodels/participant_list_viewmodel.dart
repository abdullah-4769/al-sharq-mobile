import 'package:get/get.dart';
import 'package:al_sharq_conference/data/response_models/registration_team_model/participant_response_model.dart';
import 'package:flutter/material.dart';
import '../../repository/registration_team_repo/participant_repository.dart';

class ParticipantListViewModel extends GetxController {
  final ParticipantRepository _repository = ParticipantRepository();

  // Observables
  var participants = <Participant>[].obs;
  var filteredParticipants = <Participant>[].obs; // Add this for filtered results
  var isLoading = false.obs;
  var totalParticipants = 0.obs;
  var totalBookmarks = 0.obs;
  var totalSessionRegistrations = 0.obs;
  var searchQuery = ''.obs;
  var selectedFilter = 4.obs; // Default: All Time (index 4)
  var hasMore = true.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;

  // Store all participants for filtering
  var allParticipants = <Participant>[];

  @override
  void onInit() {
    super.onInit();
    print('ParticipantListViewModel onInit() called');
    fetchParticipants();
  }

  Future<void> fetchParticipants() async {
    print('fetchParticipants() called - Page: ${currentPage.value}, Search: "${searchQuery.value}"');
    try {
      isLoading.value = true;
      print('isLoading set to true');
      currentPage.value = 1;
      print('Current page reset to 1');

      final response = await _repository.getParticipants(
        page: currentPage.value,
        search: searchQuery.value,
        // Remove filter parameter if API doesn't support it
      );

      print('API Response received');
      print('Total participants in response: ${response.users.length}');
      print('Total participants count: ${response.totalParticipants}');
      print('Total bookmarks: ${response.totalBookmarks}');
      print('Total session registrations: ${response.totalSessionRegistrations}');

      allParticipants = response.users; // Store all participants
      print('allParticipants assigned with ${allParticipants.length} items');

      participants.value = response.users;
      print('participants observable updated with ${participants.length} items');

      filteredParticipants.value = response.users; // Initialize filtered list
      print('filteredParticipants initialized with ${filteredParticipants.length} items');

      totalParticipants.value = response.totalParticipants;
      totalBookmarks.value = response.totalBookmarks;
      totalSessionRegistrations.value = response.totalSessionRegistrations;

      totalPages.value = (totalParticipants.value / 10).ceil();
      print('Total pages calculated: $totalPages.value (${totalParticipants.value}/10)');

      hasMore.value = currentPage.value < totalPages.value;
      print('hasMore set to ${hasMore.value} (${currentPage.value} < ${totalPages.value})');

      // Apply filter after fetching
      applyFilter();

    } catch (e) {
      print('Error in fetchParticipants: $e');
      print('Error stack trace: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to fetch participants',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      print('isLoading set to false in finally block');
    }
  }

  Future<void> loadMoreParticipants() async {
    print('loadMoreParticipants() called - Current page: ${currentPage.value}, hasMore: ${hasMore.value}, isLoading: ${isLoading.value}');

    if (!hasMore.value || isLoading.value) {
      print('Skipping loadMore - hasMore: ${hasMore.value}, isLoading: ${isLoading.value}');
      return;
    }

    try {
      isLoading.value = true;
      print('isLoading set to true for loadMore');

      currentPage.value++;
      print('Incremented current page to: ${currentPage.value}');

      final response = await _repository.getParticipants(
        page: currentPage.value,
        search: searchQuery.value,
      );

      print('LoadMore API Response received');
      print('New participants in response: ${response.users.length}');

      allParticipants.addAll(response.users);
      print('Added ${response.users.length} items to allParticipants, total now: ${allParticipants.length}');

      participants.addAll(response.users);
      print('Added ${response.users.length} items to participants, total now: ${participants.length}');

      filteredParticipants.addAll(response.users);
      print('Added ${response.users.length} items to filteredParticipants, total now: ${filteredParticipants.length}');

      hasMore.value = currentPage.value < totalPages.value;
      print('Updated hasMore to ${hasMore.value} (${currentPage.value} < ${totalPages.value})');

      // Apply filter to newly loaded data
      applyFilter();

    } catch (e) {
      currentPage.value--;
      print('Error in loadMoreParticipants, rolling back page to ${currentPage.value}: $e');
      print('Error stack trace: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to load more participants',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      print('isLoading set to false after loadMore');
    }
  }

  Future<void> searchParticipants() async {
    print('searchParticipants() called - Query: "${searchQuery.value}"');

    try {
      isLoading.value = true;
      print('isLoading set to true for search');

      currentPage.value = 1;
      print('Current page reset to 1 for search');

      final response = await _repository.getParticipants(
        page: currentPage.value,
        search: searchQuery.value,
      );

      print('Search API Response received');
      print('Search results count: ${response.users.length}');

      allParticipants = response.users;
      print('allParticipants updated with ${allParticipants.length} search results');

      participants.value = response.users;
      print('participants updated with ${participants.length} items');

      filteredParticipants.value = response.users;
      print('filteredParticipants updated with ${filteredParticipants.length} items');

      totalPages.value = (response.users.length / 10).ceil();
      print('Total pages for search results: ${totalPages.value}');

      hasMore.value = false; // Don't load more for search results
      print('hasMore set to false for search results');

      // Apply filter after search
      applyFilter();

    } catch (e) {
      print('Error in searchParticipants: $e');
      print('Error stack trace: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to search participants',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      print('isLoading set to false after search');
    }
  }

  void applyFilter() {
    print('applyFilter() called - Filter index: ${selectedFilter.value}, Filter name: ${_getFilterName()}');
    print('Total participants before filter: ${allParticipants.length}');

    final now = DateTime.now();
    List<Participant> filteredList = [];

    switch (selectedFilter.value) {
      case 0: // Daily
        print('Applying DAILY filter');
        filteredList = allParticipants.where((participant) {
          final diff = now.difference(participant.createdAt);
          final isWithinDay = diff.inDays < 1;
          if (isWithinDay) {
            print('Participant "${participant.name}" created ${diff.inHours} hours ago - INCLUDED');
          }
          return isWithinDay;
        }).toList();
        break;

      case 1: // Weekly
        print('Applying WEEKLY filter');
        filteredList = allParticipants.where((participant) {
          final diff = now.difference(participant.createdAt);
          final isWithinWeek = diff.inDays < 7;
          if (isWithinWeek) {
            print('Participant "${participant.name}" created ${diff.inDays} days ago - INCLUDED');
          }
          return isWithinWeek;
        }).toList();
        break;

      case 2: // 10 Days
        print('Applying 10 DAYS filter');
        filteredList = allParticipants.where((participant) {
          final diff = now.difference(participant.createdAt);
          final isWithin10Days = diff.inDays < 10;
          if (isWithin10Days) {
            print('Participant "${participant.name}" created ${diff.inDays} days ago - INCLUDED');
          }
          return isWithin10Days;
        }).toList();
        break;

      case 3: // 90 Days
        print('Applying 90 DAYS filter');
        filteredList = allParticipants.where((participant) {
          final diff = now.difference(participant.createdAt);
          final isWithin90Days = diff.inDays < 90;
          if (isWithin90Days) {
            print('Participant "${participant.name}" created ${diff.inDays} days ago - INCLUDED');
          }
          return isWithin90Days;
        }).toList();
        break;

      case 4: // All Time
      default:
        print('Applying ALL TIME filter');
        filteredList = List.from(allParticipants);
        break;
    }

    print('Participants after time filter: ${filteredList.length}');

    // Apply search filter if search query exists
    if (searchQuery.value.isNotEmpty) {
      print('Applying search filter for query: "${searchQuery.value}"');
      filteredList = filteredList.where((participant) {
        final matchesName = participant.name.toLowerCase().contains(searchQuery.value.toLowerCase());
        final matchesEmail = participant.email.toLowerCase().contains(searchQuery.value.toLowerCase());
        final matchesOrg = (participant.organization?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);

        final isIncluded = matchesName || matchesEmail || matchesOrg;

        if (isIncluded) {
          print('Participant "${participant.name}" matches search - INCLUDED');
        }

        return isIncluded;
      }).toList();

      print('Participants after search filter: ${filteredList.length}');
    }

    filteredParticipants.value = filteredList;
    print('filteredParticipants updated with ${filteredParticipants.length} items');
  }

  // Helper method to get filter name for logging
  String _getFilterName() {
    switch (selectedFilter.value) {
      case 0:
        return 'Daily';
      case 1:
        return 'Weekly';
      case 2:
        return '10 Days';
      case 3:
        return '90 Days';
      case 4:
        return 'All Time';
      default:
        return 'Unknown';
    }
  }

  // Helper method to calculate time-based filtering
  DateTime _getFilterStartDate() {
    final now = DateTime.now();
    switch (selectedFilter.value) {
      case 0: // Daily
        return DateTime(now.year, now.month, now.day);
      case 1: // Weekly
        return now.subtract(const Duration(days: 7));
      case 2: // 10 Days
        return now.subtract(const Duration(days: 10));
      case 3: // 90 Days
        return now.subtract(const Duration(days: 90));
      case 4: // All Time
      default:
        return DateTime(2000); // Very old date
    }
  }

  @override
  void onClose() {
    print('ParticipantListViewModel onClose() called');
    super.onClose();
  }
}