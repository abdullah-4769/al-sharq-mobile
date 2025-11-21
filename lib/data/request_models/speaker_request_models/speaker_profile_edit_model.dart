import '../../response_models/speaker_response_models/speaker_profile_show_on_dashboard_model.dart';

class SpeakerProfileEditRequestModel {
  final String? bio;
  final String? country;
  final String? website;
  final String? youtube;
  final String? facebook;
  final String? linkedin;
  final String? twitter;
  final List<String>? designations;
  final List<String>? expertise;
  final List<String>? tags;
  final String? category;
  final bool? featured;
  final bool? verified;
  final int? priority;
  final bool? isActive;

  SpeakerProfileEditRequestModel({
    this.bio,
    this.country,
    this.website,
    this.youtube,
    this.facebook,
    this.linkedin,
    this.twitter,
    this.designations,
    this.expertise,
    this.tags,
    this.category,
    this.featured,
    this.verified,
    this.priority,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    // Only include speaker fields (not user fields)
    if (bio != null) data['bio'] = bio;
    if (country != null) data['country'] = country;
    if (website != null) data['website'] = website;
    if (youtube != null) data['youtube'] = youtube;
    if (facebook != null) data['facebook'] = facebook;
    if (linkedin != null) data['linkedin'] = linkedin;
    if (twitter != null) data['twitter'] = twitter;
    if (category != null) data['category'] = category;
    if (featured != null) data['featured'] = featured;
    if (verified != null) data['verified'] = verified;
    if (priority != null) data['priority'] = priority;
    if (isActive != null) data['isActive'] = isActive;

    // Arrays
    if (designations != null) data['designations'] = designations;
    if (expertise != null) data['expertise'] = expertise;
    if (tags != null) data['tags'] = tags;

    return data;
  }
}
class SpeakerProfileEditResponseModel {
  final SpeakerProfileShowOnDashboardModel speaker;

  SpeakerProfileEditResponseModel({
    required this.speaker,
  });

  factory SpeakerProfileEditResponseModel.fromJson(Map<String, dynamic> json) {
    return SpeakerProfileEditResponseModel(
      speaker: SpeakerProfileShowOnDashboardModel.fromJson(json),
    );
  }
}