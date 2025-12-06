// lib/qr_code/gallery_qr_scanner_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_generator_service.dart';

class GalleryQRScannerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<Map<String, dynamic>?> scanQRFromGallery(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      try {
        // Create temporary controller to analyze image
        final controller = MobileScannerController();
        final BarcodeCapture? capture = await controller.analyzeImage(image.path);

        // Dispose controller
        controller.dispose();

        if (capture == null || capture.barcodes.isEmpty) {
          Get.back();
          _showNoQRCodeFound();
          return null;
        }

        final String? rawValue = capture.barcodes.first.rawValue;

        if (rawValue == null) {
          Get.back();
          _showNoQRCodeFound();
          return null;
        }

        Get.back();

        // Parse QR data
        final Map<String, dynamic>? qrData = QRGeneratorService.parseQRString(rawValue);

        if (qrData == null || !QRGeneratorService.isValidParticipantQR(qrData)) {
          _showInvalidQRCode();
          return null;
        }

        return qrData;
      } catch (e) {
        Get.back();
        _showScanError(e.toString());
        return null;
      }
    } catch (e) {
      _showPickImageError(e.toString());
      return null;
    }
  }

  static void showParticipantDetails(Map<String, dynamic> data) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Participant Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue),
                ),
                child: ClipOval(
                  child: data['file'] != null && data['file'].toString().isNotEmpty
                      ? Image.network(
                    data['file'].toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                  )
                      : _buildDefaultAvatar(),
                ),
              ),

              // Name
              Text(
                data['name']?.toString() ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // Email
              Text(
                data['email']?.toString() ?? 'No email',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              // Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('User ID', data['id']?.toString() ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Email', data['email']?.toString() ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Role', data['role']?.toString() ?? 'N/A'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  static Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.person, size: 30, color: Colors.white),
    );
  }

  static void _showNoQRCodeFound() {
    Get.snackbar(
      'No QR Code Found',
      'Please select an image containing a QR code',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  static void _showInvalidQRCode() {
    Get.snackbar(
      'Invalid QR Code',
      'This is not a valid participant QR code',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  static void _showScanError(String error) {
    Get.snackbar(
      'Scan Error',
      'Failed to scan QR code: $error',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  static void _showPickImageError(String error) {
    Get.snackbar(
      'Error',
      'Failed to pick image: $error',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

// lib/qr_code/qr_debug_service.dart
class QRDebugService {
  static void printQRData(String rawQRData) {
    print("==========================================");
    print("RAW QR STRING:");
    print(rawQRData);
    print("==========================================");

    try {
      // Try to parse as JSON
      final parsed = jsonDecode(rawQRData);
      print("JSON PARSED SUCCESSFULLY:");
      print(parsed);
      print("Type: ${parsed.runtimeType}");

      if (parsed is Map) {
        print("KEYS IN MAP:");
        parsed.keys.forEach((key) => print("  $key: ${parsed[key]} (${parsed[key].runtimeType})"));
      }
    } catch (e) {
      print("JSON PARSE FAILED: $e");

      // Check if it's just a URL
      if (rawQRData.startsWith('http')) {
        print("Detected URL: $rawQRData");
      }

      // Check if it's just an ID
      final idMatch = RegExp(r'^\d+$').firstMatch(rawQRData);
      if (idMatch != null) {
        print("Detected numeric ID: $rawQRData");
      }

      // Check for other patterns
      print("Trying to split by common delimiters...");
      final parts = rawQRData.split(RegExp(r'[,\|;:/]'));
      print("Split parts: $parts");
    }

    print("==========================================");
  }
}