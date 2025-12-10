class SeeingOptedUser {
  final int id;
  final String name;
  final String role;
  final String? file;

  SeeingOptedUser({
    required this.id,
    required this.name,
    required this.role,
    required this.file,
  });

  factory SeeingOptedUser.fromJson(Map<String, dynamic> json) {
    return SeeingOptedUser(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      file: json['file'],
    );
  }
}