import 'package:get/get.dart';
import 'package:al_sharq_conference/data/response_models/organizer_response_models/organize_see_participants_short_info_model.dart';
import '../../repository/organizer_repo/organize_see_participants_short_info_repo.dart';
import 'package:flutter/material.dart';
class OrganizeSeeParticipantsShortInfoViewModel extends GetxController {
  final _repo = OrganizeSeeParticipantsShortInfoRepo();

  var participantsData = Rx<OrganizeSeeParticipantsShortInfoModel?>(null);
  var isLoading = false.obs;
  var error = ''.obs;

  Future<void> fetchParticipantsData() async {
    try {
      isLoading.value = true;
      error.value = '';

      final data = await _repo.getParticipantsData();
      participantsData.value = data;

    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load participants data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods
  bool get hasData => participantsData.value != null;

  String get formattedTotalParticipants =>
      participantsData.value?.totalParticipants.toString() ?? '0';

  String get formattedTotalBookmarks =>
      participantsData.value?.totalBookmarks.toString() ?? '0';

  String get formattedTotalSessionRegistrations =>
      participantsData.value?.totalSessionRegistrations.toString() ?? '0';

  List<OrganizeSeeParticipantsShortInfoUser> get users =>
      participantsData.value?.users ?? [];

  @override
  void onInit() {
    super.onInit();
    fetchParticipantsData();
  }
}