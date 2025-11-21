class OrganizerDeleteSpeakerRequestModel {
  final int speakerId;

  OrganizerDeleteSpeakerRequestModel({
    required this.speakerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'speakerId': speakerId,
    };
  }
}

class OrganizerDeleteSpeakerResponseModel {
  final String message;

  OrganizerDeleteSpeakerResponseModel({
    required this.message,
  });

  factory OrganizerDeleteSpeakerResponseModel.fromJson(Map<String, dynamic> json) {
    return OrganizerDeleteSpeakerResponseModel(
      message: json['message'] ?? 'Speaker deleted successfully',
    );
  }
}