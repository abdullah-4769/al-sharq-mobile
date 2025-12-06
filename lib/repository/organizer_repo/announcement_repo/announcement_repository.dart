import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../data/request_models/announcement_model/announcement_model.dart';

class AnnouncementRepository {
  static const String baseUrl = 'http://138.68.104.206:3000/announcements';

  // Get all announcements
  Future<List<AnnouncementModel>> getAllAnnouncements() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => AnnouncementModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load announcements');
      }
    } catch (e) {
      throw Exception('Error fetching announcements: $e');
    }
  }

  // Create announcement
  Future<AnnouncementModel> createAnnouncement(AnnouncementModel announcement) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(announcement.toJson(forCreate: true)),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AnnouncementModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create announcement');
      }
    } catch (e) {
      throw Exception('Error creating announcement: $e');
    }
  }

  // Update announcement
  Future<AnnouncementModel> updateAnnouncement(int id, AnnouncementModel announcement) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(announcement.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AnnouncementModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update announcement');
      } else {
        throw Exception('Failed to update announcement');
      }
    } catch (e) {
      throw Exception('Error updating announcement: $e');
    }
  }

  // Delete announcement
  Future<void> deleteAnnouncement(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (response.statusCode == 404) {
          throw Exception('Announcement not found');
        }
        throw Exception('Failed to delete announcement');
      }
    } catch (e) {
      throw Exception('Error deleting announcement: $e');
    }
  }
}