import 'dart:convert';
import '../data/response_models/registration_team_model/participant_response_model.dart';

class QRGeneratorService {

  // Generate QR code data for a participant (ONLY 5 REQUIRED FIELDS)
  static Map<String, dynamic> generateParticipantQRData(Participant participant) {
    return {
      "type": "participant_qr",
      "name": participant.name,
      "email": participant.email,
      "role": participant.role,
      "file": participant.file ?? "",
      "bio": participant.bio ?? "",
      "timestamp": DateTime.now().toIso8601String(),
    };
  }

  // Convert QR data to JSON string
  static String generateQRString(Participant participant) {
    final qrData = generateParticipantQRData(participant);
    return jsonEncode(qrData);
  }

  // Parse QR string back to data
  static Map<String, dynamic>? parseQRString(String qrString) {
    try {
      return jsonDecode(qrString);
    } catch (e) {
      return null;
    }
  }
}