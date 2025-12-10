import 'package:get/get.dart';
import '../data/request_models/connection_request_send_model.dart';
import '../data/response/api_response.dart';
import '../repository/connection_request_send_repository.dart';
import '../utils/shared_preference.dart';

class ConnectionRequestSendViewModel extends GetxController {
  final _repository = ConnectionRequestSendRepository();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final sendingRequestIds = <int>{}.obs;

  Future<Map<String, dynamic>> sendConnectionRequest(int receiverId) async {
    try {
      final senderId = await SharedPrefsHelper.getUserId();
      if (senderId == null) {
        return {
          'success': false,
          'message': 'User not found',
          'type': 'error'
        };
      }

      sendingRequestIds.add(receiverId);
      isLoading.value = true;
      errorMessage.value = '';

      final request = ConnectionRequestSend(
        senderId: senderId,
        receiverId: receiverId,
      );

      final response = await _repository.sendConnectionRequest(request);

      if (response.status == Status.COMPLETED) {
        return {
          'success': true,
          'message': 'Connection request sent successfully!',
          'type': 'success'
        };
      } else {
        // Parse error message to provide user-friendly feedback
        String message = response.message ?? 'Failed to send connection request';
        String type = 'error';

        // Check for common error patterns from API
        if (message.toLowerCase().contains('already') ||
            message.toLowerCase().contains('pending') ||
            message.toLowerCase().contains('sent') ||
            message.toLowerCase().contains('exists')) {
          type = 'warning';
        } else if (message.toLowerCase().contains('connected')) {
          type = 'info';
        } else if (message.toLowerCase().contains('invalid') ||
            message.toLowerCase().contains('not found')) {
          type = 'error';
        }

        return {
          'success': false,
          'message': message,
          'type': type
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error sending connection request: $e',
        'type': 'error'
      };
    } finally {
      sendingRequestIds.remove(receiverId);
      isLoading.value = false;
    }
  }

  // Helper method to check specific error conditions
  bool _isAlreadySentError(String message) {
    final lowerMessage = message.toLowerCase();
    return lowerMessage.contains('already') ||
        lowerMessage.contains('pending') ||
        lowerMessage.contains('sent before') ||
        lowerMessage.contains('exists');
  }

  bool _isAlreadyConnectedError(String message) {
    return message.toLowerCase().contains('connected') ||
        message.toLowerCase().contains('friend');
  }

  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  bool isSendingRequest(int receiverId) {
    return sendingRequestIds.contains(receiverId);
  }
}