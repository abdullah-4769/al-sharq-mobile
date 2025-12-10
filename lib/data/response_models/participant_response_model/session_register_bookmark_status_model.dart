// lib/data/response_models/participant_response_model/session_register_bookmark_status_model.dart

class SessionRegisterBookmarkStatusModel {
  final bool isRegistered;
  final bool isBookmarked;

  SessionRegisterBookmarkStatusModel({
    required this.isRegistered,
    required this.isBookmarked,
  });

  factory SessionRegisterBookmarkStatusModel.fromJson(Map<String, dynamic> json) {
    return SessionRegisterBookmarkStatusModel(
      isRegistered: json['isRegistered'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isRegistered': isRegistered,
      'isBookmarked': isBookmarked,
    };
  }

  @override
  String toString() {
    return 'SessionRegisterBookmarkStatusModel{isRegistered: $isRegistered, isBookmarked: $isBookmarked}';
  }
}