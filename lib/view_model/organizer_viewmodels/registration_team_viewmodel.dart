import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/response_models/organizer_response_models/registration_team_response_model.dart';
import '../../repository/organizer_repo/organizer_delete_user_repo.dart';
import '../../repository/organizer_repo/registration_team_repository.dart';

class RegistrationTeamViewModel extends GetxController {
  final RegistrationTeamRepository _repository = RegistrationTeamRepository();
  final OrganizerDeleteUserRepo _deleteUserRepo = OrganizerDeleteUserRepo();
  // Observables
  var teamMembers = <RegistrationTeamMember>[].obs;
  var filteredTeamMembers = <RegistrationTeamMember>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var selectedFilter = 4.obs; // Default: All Time (index 4)
  var hasMore = true.obs;
  var currentPage = 1.obs;
  final int limit = 10;

  // Store all team members for filtering
  var allTeamMembers = <RegistrationTeamMember>[];

  @override
  void onInit() {
    super.onInit();
    print('RegistrationTeamViewModel onInit() called');
    fetchRegistrationTeam();
  }

  Future<void> fetchRegistrationTeam() async {
    print('fetchRegistrationTeam() called - Page: ${currentPage.value}, Search: "${searchQuery.value}"');
    try {
      isLoading.value = true;
      print('isLoading set to true');
      currentPage.value = 1;
      print('Current page reset to 1');

      final members = await _repository.getRegistrationTeam(
        page: currentPage.value,
        limit: limit,
        search: searchQuery.value,
      );

      print('API Response received');
      print('Total team members fetched: ${members.length}');

      allTeamMembers = members;
      print('allTeamMembers assigned with ${allTeamMembers.length} items');

      teamMembers.value = members;
      print('teamMembers observable updated with ${teamMembers.length} items');

      filteredTeamMembers.value = members;
      print('filteredTeamMembers initialized with ${filteredTeamMembers.length} items');

      // Check if there are more items to load
      hasMore.value = members.length >= limit;
      print('hasMore set to ${hasMore.value} (${members.length} >= $limit)');

      // Apply filter after fetching
      applyFilter();

    } catch (e) {
      print('Error in fetchRegistrationTeam: $e');
      print('Error stack trace: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to fetch registration team members: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      print('isLoading set to false in finally block');
    }
  }

  Future<void> loadMoreTeamMembers() async {
    print('loadMoreTeamMembers() called - Current page: ${currentPage.value}, hasMore: ${hasMore.value}, isLoading: ${isLoading.value}');

    if (!hasMore.value || isLoading.value) {
      print('Skipping loadMore - hasMore: ${hasMore.value}, isLoading: ${isLoading.value}');
      return;
    }

    try {
      isLoading.value = true;
      print('isLoading set to true for loadMore');

      currentPage.value++;
      print('Incremented current page to: ${currentPage.value}');

      final members = await _repository.getRegistrationTeam(
        page: currentPage.value,
        limit: limit,
        search: searchQuery.value,
      );

      print('LoadMore API Response received');
      print('New team members fetched: ${members.length}');

      allTeamMembers.addAll(members);
      print('Added ${members.length} items to allTeamMembers, total now: ${allTeamMembers.length}');

      teamMembers.addAll(members);
      print('Added ${members.length} items to teamMembers, total now: ${teamMembers.length}');

      filteredTeamMembers.addAll(members);
      print('Added ${members.length} items to filteredTeamMembers, total now: ${filteredTeamMembers.length}');

      // Check if there are more items to load
      hasMore.value = members.length >= limit;
      print('Updated hasMore to ${hasMore.value} (${members.length} >= $limit)');

      // Apply filter to newly loaded data
      applyFilter();

    } catch (e) {
      currentPage.value--;
      print('Error in loadMoreTeamMembers, rolling back page to ${currentPage.value}: $e');
      print('Error stack trace: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to load more team members: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      print('isLoading set to false after loadMore');
    }
  }

  Future<void> searchTeamMembers() async {
    print('searchTeamMembers() called - Query: "${searchQuery.value}"');

    try {
      isLoading.value = true;
      print('isLoading set to true for search');

      currentPage.value = 1;
      print('Current page reset to 1 for search');

      final members = await _repository.getRegistrationTeam(
        page: currentPage.value,
        limit: limit,
        search: searchQuery.value,
      );

      print('Search API Response received');
      print('Search results count: ${members.length}');

      allTeamMembers = members;
      print('allTeamMembers updated with ${allTeamMembers.length} search results');

      teamMembers.value = members;
      print('teamMembers updated with ${teamMembers.length} items');

      filteredTeamMembers.value = members;
      print('filteredTeamMembers updated with ${filteredTeamMembers.length} items');

      hasMore.value = members.length >= limit;
      print('hasMore set to ${hasMore.value} for search results');

      // Apply filter after search
      applyFilter();

    } catch (e) {
      print('Error in searchTeamMembers: $e');
      print('Error stack trace: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to search team members: ${e.toString()}',
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
    print('Total team members before filter: ${allTeamMembers.length}');
    print('Search query: "${searchQuery.value}"');

    final now = DateTime.now();
    List<RegistrationTeamMember> filteredList = [];

    // Apply time-based filter
    switch (selectedFilter.value) {
      case 0: // Daily
        print('Applying DAILY filter');
        filteredList = allTeamMembers.where((member) {
          final diff = now.difference(member.createdAt);
          final isWithinDay = diff.inDays < 1;
          return isWithinDay;
        }).toList();
        break;

      case 1: // Weekly
        print('Applying WEEKLY filter');
        filteredList = allTeamMembers.where((member) {
          final diff = now.difference(member.createdAt);
          final isWithinWeek = diff.inDays < 7;
          return isWithinWeek;
        }).toList();
        break;

      case 2: // 10 Days
        print('Applying 10 DAYS filter');
        filteredList = allTeamMembers.where((member) {
          final diff = now.difference(member.createdAt);
          final isWithin10Days = diff.inDays < 10;
          return isWithin10Days;
        }).toList();
        break;

      case 3: // 90 Days
        print('Applying 90 DAYS filter');
        filteredList = allTeamMembers.where((member) {
          final diff = now.difference(member.createdAt);
          final isWithin90Days = diff.inDays < 90;
          return isWithin90Days;
        }).toList();
        break;

      case 4: // All Time
      default:
        print('Applying ALL TIME filter');
        filteredList = List.from(allTeamMembers);
        break;
    }

    print('Team members after time filter: ${filteredList.length}');

    // Apply search filter if search query exists
    if (searchQuery.value.isNotEmpty) {
      print('Applying search filter for query: "${searchQuery.value}"');
      filteredList = filteredList.where((member) {
        final matchesName = member.name.toLowerCase().contains(searchQuery.value.toLowerCase());
        final matchesEmail = member.email.toLowerCase().contains(searchQuery.value.toLowerCase());
        final matchesOrg = (member.organization?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false);

        return matchesName || matchesEmail || matchesOrg;
      }).toList();

      print('Team members after search filter: ${filteredList.length}');
    }

    filteredTeamMembers.value = filteredList;
    print('filteredTeamMembers updated with ${filteredTeamMembers.length} items');
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

  // Helper method to refresh data
  Future<void> refreshData() async {
    print('refreshData() called');
    await fetchRegistrationTeam();
  }

  // Add new team member
  Future<void> addNewTeamMember(RegistrationTeamMember member) async {
    print('Adding new team member to list: ${member.name}');
    allTeamMembers.insert(0, member);
    teamMembers.insert(0, member);
    applyFilter();
  }

// Replace the removeTeamMember method with this:
  Future<void> removeTeamMember(int memberId) async {
    try {
      print('Attempting to delete team member with ID: $memberId');

      // Call the API to delete the user
      final success = await _deleteUserRepo.deleteUser(memberId);

      if (success) {
        // Remove from local lists only if API call is successful
        allTeamMembers.removeWhere((member) => member.id == memberId);
        teamMembers.removeWhere((member) => member.id == memberId);
        applyFilter();

        print('Successfully deleted team member with ID: $memberId');
      } else {
        print('Failed to delete team member via API');
        Get.snackbar(
          'Error',
          'Failed to delete user',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error in removeTeamMember: $e');
      Get.snackbar(
        'Error',
        'Failed to delete user: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    print('RegistrationTeamViewModel onClose() called');
    super.onClose();
  }
}