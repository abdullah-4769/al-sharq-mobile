import 'package:get/get.dart';
import 'package:al_sharq_conference/data/response_models/participant_detail_response_model.dart';
import 'package:flutter/material.dart';
import '../repository/participant_detail_repository.dart';

class ParticipantDetailViewModel extends GetxController {
  final ParticipantDetailRepository _repository = ParticipantDetailRepository();

  // Observables
  var participant = ParticipantDetailResponse(
    id: 0,
    email: '',
    name: '',
    role: '',
    isBlocked: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ).obs;

  var isLoading = true.obs;
  var errorMessage = ''.obs;

  Future<void> fetchParticipantById(int userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.getParticipantById(userId);
      participant.value = response;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load participant details',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshParticipant(int userId) async {
    await fetchParticipantById(userId);
  }

  @override
  void onClose() {
    super.onClose();
  }
}