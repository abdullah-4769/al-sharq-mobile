// lib/view_model/participant_viewmodel/participant_pending_connection_show_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/response_models/participant_response_model/participant_networking/participant_pending_connection_show_user_model.dart';
import '../../../repository/participants_repository/participant_networking/participant_pending_connection_show_repo.dart';
import '../../../utils/shared_preference.dart';

class ParticipantPendingConnectionShowViewModel extends GetxController {
  final ParticipantPendingConnectionShowRepo _repo = ParticipantPendingConnectionShowRepo();

  final RxList<ParticipantPendingConnectionShowModel> _pendingConnections = <ParticipantPendingConnectionShowModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  List<ParticipantPendingConnectionShowModel> get pendingConnections => _pendingConnections;

  Future<void> fetchPendingConnections(BuildContext context) async {
    try {
      print('=== Fetching pending connections ===');
      isLoading.value = true;
      errorMessage.value = '';

      final userId = await SharedPrefsHelper.getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final connections = await _repo.getPendingConnections(userId, context);
      _pendingConnections.assignAll(connections);

      print('=== Successfully loaded ${connections.length} pending connections ===');
    } catch (e) {
      errorMessage.value = 'Failed to load pending connections: $e';
      print('=== Error loading pending connections: $e ===');

      Get.snackbar(
        'Error',
        'Failed to load pending connections: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void removePendingConnection(int requestId) {
    _pendingConnections.removeWhere((connection) => connection.requestId == requestId);
  }

  void clearData() {
    _pendingConnections.clear();
    errorMessage.value = '';
  }
}