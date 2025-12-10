// lib/data/response_models/make_session_bookmarked_response_model.dart

class MakeSessionBookmarkedResponseModel {
  final String message;

  MakeSessionBookmarkedResponseModel({
    required this.message,
  });

  factory MakeSessionBookmarkedResponseModel.fromJson(Map<String, dynamic> json) {
    return MakeSessionBookmarkedResponseModel(
      message: json['message'] ?? '',
    );
  }

  @override
  String toString() {
    return 'MakeSessionBookmarkedResponseModel{message: $message}';
  }
}