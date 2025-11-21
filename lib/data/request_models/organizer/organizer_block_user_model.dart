class OrganizerBlockUserRequestModel {
  final int id;
  final bool isBlocked;

  OrganizerBlockUserRequestModel({
    required this.id,
    required this.isBlocked,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isBlocked': isBlocked,
    };
  }
}

class OrganizerBlockUserResponseModel {
  final bool success;
  final String message;
  final dynamic data;

  OrganizerBlockUserResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory OrganizerBlockUserResponseModel.fromJson(Map<String, dynamic> json) {
    // For this API, if we get a user object back with the updated isBlocked status, it means success
    bool success = json['id'] != null && json['isBlocked'] != null;

    String message = success
        ? 'User ${json['isBlocked'] ? 'blocked' : 'unblocked'} successfully'
        : 'Operation failed';

    return OrganizerBlockUserResponseModel(
      success: success,
      message: message,
      data: json,
    );
  }
}