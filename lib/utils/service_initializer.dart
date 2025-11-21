import 'package:get/get.dart';

import '../services/live_streaming_services/agora_services.dart';
import '../view_model/live_streaming_viewmodel/agora_viewmodel.dart';
import '../view_model/participant_viewmodel/participant_chat_viewmodels/participant_chat_viewmodel.dart';

class ServiceInitializer {
  static Future<void> initServices() async {
    print('=== Initializing Services ===');

    try {
      // 1. Initialize AgoraService FIRST (async)
      final agoraService = await Get.putAsync<AgoraService>(
            () async {
          final service = AgoraService();
          await service.initializeAgoraEngine();
          return service;
        },
        permanent: true,
      );
      print('=== AgoraService initialized successfully ===');

      // 2. NOW initialize AgoraViewModel (uses Get.find<AgoraService>())
      Get.put<AgoraViewModel>(AgoraViewModel(), permanent: true);
      print('=== AgoraViewModel initialized successfully ===');

      // 3. Initialize Chat ViewModel
      Get.put<ParticipantChatViewModel>(
        ParticipantChatViewModel(),
        permanent: true,
      );
      print('=== ParticipantChatViewModel initialized successfully ===');

      print('=== All Services Initialized Successfully ===');
    } catch (e) {
      print('=== ERROR Initializing Services: $e ===');
      rethrow;
    }
  }

  static Future<void> disposeServices() async {
    print('=== Disposing Services ===');

    try {
      if (Get.isRegistered<AgoraViewModel>()) {
        Get.delete<AgoraViewModel>();
      }

      if (Get.isRegistered<AgoraService>()) {
        Get.delete<AgoraService>();
      }

      print('=== Services Disposed Successfully ===');
    } catch (e) {
      print('=== ERROR Disposing Services: $e ===');
    }
  }
}