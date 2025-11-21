import 'package:get/get.dart';
import '../../data/response_models/participant_response_model/session_detail_show_response_model.dart';
import '../../repository/participants_repository/session_detail_show_repository.dart';

class SessionDetailShowViewModel extends GetxController {
  final SessionDetailShowRepository _repository = SessionDetailShowRepository();

  var isLoading = false.obs;
  var sessionDetails = SessionDetailShowResponseModel(
    id: 0,
    title: '',
    description: '',
    startTime: '',
    endTime: '',
    location: '',
    category: '',
    capacity: 0,
    tags: [],
    eventId: 0,
    joinToken: '',
    registrationRequired: false,
    isActive: false,
    createdAt: '',
    updatedAt: '',
    speakers: [],
    event: SessionDetailShowEventModel(
      id: 0,
      title: '',
      description: '',
      location: '',
      googleMapLink: '',
      joinToken: '',
      mapstatus: false,
      createdAt: '',
      updatedAt: '',
    ),
    registeredUsers: [],
    registrationCount: 0,
  ).obs;

  var errorMessage = ''.obs;

  Future<void> fetchSessionDetails(int sessionId) async {
    try {
      isLoading(true);
      errorMessage('');

      final details = await _repository.fetchSessionDetails(sessionId);
      sessionDetails(details);
    } catch (e) {
      errorMessage('Failed to load session details: $e');
      print('Error in SessionDetailShowViewModel: $e');
    } finally {
      isLoading(false);
    }
  }

  // Helper methods for formatted data
  String get formattedDate {
    if (sessionDetails.value.startTime.isEmpty) return 'TBD';
    final dateTime = DateTime.parse(sessionDetails.value.startTime);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String get formattedTime {
    if (sessionDetails.value.startTime.isEmpty) return 'TBD';
    final startTime = DateTime.parse(sessionDetails.value.startTime);
    final endTime = DateTime.parse(sessionDetails.value.endTime);
    return '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  String get availableSpots {
    final capacity = sessionDetails.value.capacity;
    final registered = sessionDetails.value.registrationCount;
    return '${capacity - registered} spots available';
  }

  bool get isRegistrationOpen {
    return sessionDetails.value.registrationRequired &&
        sessionDetails.value.registrationCount < sessionDetails.value.capacity;
  }
}


