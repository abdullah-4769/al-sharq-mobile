// lib/view_model/participant_viewmodel/participant_connected_users_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response_models/participant_response_model/participant_networking/participant_connected_usermodel.dart';
import '../../../repository/participants_repository/participant_networking/participant_connected_user_repo.dart';
import '../../../utils/shared_preference.dart';


class ParticipantConnectedUsersViewModel extends GetxController {
  final ParticipantConnectedUsersRepo _repo = ParticipantConnectedUsersRepo();

  final RxList<ParticipantConnectedUsersModel> _connectedUsers = <ParticipantConnectedUsersModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  List<ParticipantConnectedUsersModel> get connectedUsers => _connectedUsers;

  List<ParticipantConnectedUsersModel> get filteredConnectedUsers {
    if (searchQuery.value.isEmpty) {
      return _connectedUsers;
    }
    return _connectedUsers.where((user) =>
    user.user.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        user.user.email.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  Future<void> fetchConnectedUsers(BuildContext context) async {
    try {
      print('=== Fetching connected users ===');
      isLoading.value = true;
      errorMessage.value = '';

      final userId = await SharedPrefsHelper.getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final users = await _repo.getConnectedUsers(userId, context);
      _connectedUsers.assignAll(users);

      print('=== Successfully loaded ${users.length} connected users ===');
    } catch (e) {
      errorMessage.value = 'Failed to load connected users: $e';
      print('=== Error loading connected users: $e ===');

      Get.snackbar(
        'Error',
        'Failed to load connected users: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) {
    searchQuery.value = query;
  }

  void clearData() {
    _connectedUsers.clear();
    errorMessage.value = '';
    searchQuery.value = '';
  }
}