
class AnnouncementModel {
  final int? id;
  final String title;
  final String message;
  final List<String> roles;
  final DateTime? scheduledAt;
  final bool isSent;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? sentTo;

  AnnouncementModel({
    this.id,
    required this.title,
    required this.message,
    required this.roles,
    this.scheduledAt,
    this.isSent = false,
    this.createdAt,
    this.updatedAt,
    this.sentTo,
  });

  // Get status based on isSent and scheduledAt
  String get status {
    if (isSent) {
      return 'sent';
    } else if (scheduledAt != null) {
      return 'scheduled';
    } else {
      return 'draft';
    }
  }

  // Get formatted date string
  String get formattedDate {
    if (scheduledAt != null) {
      return _formatDateTime(scheduledAt!);
    } else if (createdAt != null) {
      return _formatDateTime(createdAt!);
    }
    return '';
  }

  String _formatDateTime(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month $day, $hour:$minute';
  }

  // Get audience display text
  String get audienceDisplay {
    if (roles.contains('all')) {
      return 'All Users';
    } else if (roles.length == 1) {
      return _capitalizeRole(roles[0]);
    } else {
      return '${roles.length} roles';
    }
  }

  String _capitalizeRole(String role) {
    if (role.isEmpty) return role;
    return role[0].toUpperCase() + role.substring(1);
  }

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : null,
      isSent: json['isSent'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      sentTo: json['sentTo'],
    );
  }

  Map<String, dynamic> toJson({bool forCreate = false}) {
    final Map<String, dynamic> data = {
      'title': title,
      'message': message,
      'roles': roles,
    };

    if (scheduledAt != null) {
      data['scheduledAt'] = scheduledAt!.toIso8601String();
      data['sendNow'] = false;
    } else if (forCreate && isSent) {
      data['sendNow'] = true;
    } else {
      data['sendNow'] = false;
    }

    return data;
  }

  AnnouncementModel copyWith({
    int? id,
    String? title,
    String? message,
    List<String>? roles,
    DateTime? scheduledAt,
    bool? isSent,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sentTo,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      roles: roles ?? this.roles,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isSent: isSent ?? this.isSent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sentTo: sentTo ?? this.sentTo,
    );
  }
}