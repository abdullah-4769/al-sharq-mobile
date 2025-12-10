// lib/qr_code/qr_generator_service.dart
import 'dart:convert';
// lib/qr_code/qr_test_screen.dart
import 'package:al_sharq_conference/qr_code/universal_qr_code_scan.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../custom_widgets/app_text.dart';
class QRGeneratorService {
  // Generate QR code data for a participant
  static Map<String, dynamic> generateParticipantQRData(Map<String, dynamic> participant) {
    final Map<String, dynamic> data = {
      "id": participant['id'] ?? participant['userId'],
      "userId": participant['id'] ?? participant['userId'],
      "name": participant['name'],
      "email": participant['email'],
      "role": participant['role'] ?? 'participant',
      "qrType": "participant", // Add type identifier
    };

    if (participant['file'] != null) {
      data["file"] = participant['file'];
    }

    if (participant['bio'] != null) {
      data["bio"] = participant['bio'];
    }

    if (participant['organization'] != null) {
      data["organization"] = participant['organization'];
    }

    return data;
  }

  // Convert QR data to JSON string
  static String generateQRString(Map<String, dynamic> participant) {
    final qrData = generateParticipantQRData(participant);
    return jsonEncode(qrData);
  }

  // Parse QR string back to data - HANDLE MULTIPLE FORMATS
  static Map<String, dynamic>? parseQRString(String qrString) {
    try {
      // Clean the string - remove any extra quotes or whitespace
      String cleanString = qrString.trim();

      // Try to parse as JSON
      Map<String, dynamic>? parsedData;

      try {
        final decoded = jsonDecode(cleanString);
        if (decoded is Map<String, dynamic>) {
          parsedData = decoded;
        }
      } catch (e) {
        // Not valid JSON, try other formats

        // Format 1: Simple ID (just a number)
        if (RegExp(r'^\d+$').hasMatch(cleanString)) {
          return {
            'id': int.parse(cleanString),
            'userId': int.parse(cleanString),
            'qrFormat': 'numeric_id',
          };
        }

        // Format 2: Key-value pairs separated by commas
        if (cleanString.contains('=')) {
          final Map<String, dynamic> data = {};
          final pairs = cleanString.split(',');

          for (final pair in pairs) {
            final keyValue = pair.split('=');
            if (keyValue.length == 2) {
              final key = keyValue[0].trim();
              final value = keyValue[1].trim();

              // Try to parse numbers
              if (RegExp(r'^\d+$').hasMatch(value)) {
                data[key] = int.parse(value); // Store as int
              } else {
                data[key] = value; // Store as String
              }
            }
          }

          if (data.isNotEmpty) {
            return data;
          }
        }

        // Format 3: URL with query parameters
        if (cleanString.contains('?')) {
          try {
            final uri = Uri.parse(cleanString);
            final Map<String, dynamic> data = {};

            uri.queryParameters.forEach((key, value) {
              // Try to parse numbers
              if (RegExp(r'^\d+$').hasMatch(value)) {
                data[key] = int.parse(value); // Store as int
              } else {
                data[key] = value; // Store as String
              }
            });

            if (data.isNotEmpty) {
              return data;
            }
          } catch (e) {
            // Not a valid URL
          }
        }

        // Format 4: Plain text - check if it's just a name/email
        if (cleanString.contains('@')) {
          // Might be just an email
          return {
            'email': cleanString,
            'qrFormat': 'email_only',
          };
        }

        return null;
      }

      // If we parsed JSON, normalize the data
      if (parsedData != null) {
        return _normalizeQRData(parsedData);
      }

      return null;
    } catch (e) {
      print('Error parsing QR string: $e\nString: $qrString');
      return null;
    }
  }

  // Normalize QR data to standard format
  static Map<String, dynamic> _normalizeQRData(Map<String, dynamic> data) {
    final Map<String, dynamic> normalized = Map.from(data);

    // Ensure ID fields
    int? extractedId;

    // Try to extract ID from common fields
    final List<String> idFields = ['id', 'userId', 'user_id', 'userid', 'participantId', 'participant_id'];

    for (final field in idFields) {
      if (normalized[field] != null) {
        if (normalized[field] is int) {
          extractedId = normalized[field];
          break;
        } else if (normalized[field] is String) {
          extractedId = int.tryParse(normalized[field].toString());
          if (extractedId != null) break;
        }
      }
    }

    // Set ID in standard fields
    if (extractedId != null) {
      normalized['id'] = extractedId;
      normalized['userId'] = extractedId;
    }

    // Ensure name field (check common variations)
    if (normalized['name'] == null) {
      if (normalized['fullName'] != null) {
        normalized['name'] = normalized['fullName'];
      } else if (normalized['full_name'] != null) {
        normalized['name'] = normalized['full_name'];
      } else if (normalized['participantName'] != null) {
        normalized['name'] = normalized['participantName'];
      }
    }

    // Ensure email field
    if (normalized['email'] == null) {
      if (normalized['emailAddress'] != null) {
        normalized['email'] = normalized['emailAddress'];
      } else if (normalized['email_address'] != null) {
        normalized['email'] = normalized['email_address'];
      }
    }

    // Ensure role field
    if (normalized['role'] == null) {
      normalized['role'] = 'participant';
    }

    return normalized;
  }

  // Validate QR data - MORE LENIENT VERSION
  static bool isValidParticipantQR(Map<String, dynamic>? data) {
    if (data == null) return false;

    // Option 1: Has ID and either name or email
    final hasId = data.containsKey('id') || data.containsKey('userId');
    final hasName = data.containsKey('name') && data['name'] != null && data['name'].toString().isNotEmpty;
    final hasEmail = data.containsKey('email') && data['email'] != null;

    // Option 2: Has just ID (we can fetch details from API)
    if (hasId) {
      return true;
    }

    // Option 3: Has name and email (we can still show details)
    if (hasName && hasEmail) {
      return true;
    }

    return false;
  }

  // Try to extract user ID from ANY QR data
  static int? extractUserId(Map<String, dynamic>? data) {
    if (data == null) return null;

    // Check all possible ID fields
    final List<String> idFields = [
      'id', 'userId', 'user_id', 'userid',
      'participantId', 'participant_id', 'uid', 'user'
    ];

    for (final field in idFields) {
      if (data[field] != null) {
        if (data[field] is int) {
          return data[field];
        } else if (data[field] is String) {
          final parsed = int.tryParse(data[field].toString());
          if (parsed != null) return parsed;
        }
      }
    }

    return null;
  }
}



class QRTestScreen extends StatefulWidget {
  const QRTestScreen({super.key});

  @override
  State<QRTestScreen> createState() => _QRTestScreenState();
}

class _QRTestScreenState extends State<QRTestScreen> {
  final TextEditingController _jsonController = TextEditingController(
    text: '{"id":123,"name":"John Doe","email":"john@example.com","role":"participant"}',
  );
  String _qrData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Test Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _jsonController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'JSON Data',
                border: OutlineInputBorder(),
                hintText: 'Enter JSON for QR code',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _qrData = _jsonController.text;
                });
              },
              child: const Text('Generate QR Code'),
            ),
            const SizedBox(height: 20),
            if (_qrData.isNotEmpty)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: QrImageView(
                      data: _qrData,
                      size: 200,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          text: 'QR Data:',
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          _qrData,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => UniversalQRScannerScreen());
                    },
                    child: const Text('Test Scan This QR'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}