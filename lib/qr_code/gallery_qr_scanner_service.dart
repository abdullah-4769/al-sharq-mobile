import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../qr_code/qr_generator_service.dart';

class GalleryQRScannerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<Map<String, dynamic>?> scanQRFromGallery(BuildContext context) async {
    try {
      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image == null) {
        // User cancelled
        return null;
      }

      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      try {
        // Use mobile_scanner to analyze the image
        final BarcodeCapture? capture = await MobileScannerController()
            .analyzeImage(image.path);

        // Close loading dialog
        Get.back();

        if (capture == null || capture.barcodes.isEmpty) {
          _showNoQRCodeFound();
          return null;
        }

        // Get the first barcode
        final Barcode barcode = capture.barcodes.first;
        final String? rawValue = barcode.rawValue;

        if (rawValue == null) {
          _showNoQRCodeFound();
          return null;
        }

        // Parse the QR data
        final Map<String, dynamic>? qrData = QRGeneratorService.parseQRString(rawValue);

        if (qrData == null) {
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

  static void _showNoQRCodeFound() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('No QR Code Found'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 50, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'No QR code was detected in the selected image.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Please make sure the image contains a clear QR code.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showInvalidQRCode() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Invalid QR Code'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'The QR code is not a valid participant QR code.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showScanError(String error) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Scan Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, size: 50, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to scan QR code from image.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: $error',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
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
  static void showParticipantDetails(Map<String, dynamic> data) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Participant Details'),
        content: _buildDetailsContent(data),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailsContent(Map<String, dynamic> data) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Image
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: ClipOval(
              child: data['file'] != null && data['file'].toString().isNotEmpty
                  ? Image.network(
                data['file'].toString(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
              )
                  : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.person, size: 40, color: Colors.grey),
              ),
            ),
          ),

          // Name
          Text(
            data['name']?.toString() ?? 'Unknown',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Email
          Text(
            data['email']?.toString() ?? 'No email',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (data['role']?.toString() ?? 'participant').toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Details List
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Email detail
                _buildDetailRow('Email', data['email']?.toString() ?? 'Not available'),
                const SizedBox(height: 12),

                // Role detail
                _buildDetailRow('Role', data['role']?.toString() ?? 'Not available'),
                const SizedBox(height: 12),

                // Bio detail (if available)
                if (data['bio'] != null && data['bio'].toString().isNotEmpty)
                  Column(
                    children: [
                      _buildDetailRow('Bio', data['bio'].toString()),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Profile Image Status
                _buildDetailRow(
                  'Profile Image',
                  data['file'] != null && data['file'].toString().isNotEmpty ? 'Available' : 'Not available',
                  isImageAvailable: data['file'] != null && data['file'].toString().isNotEmpty,
                  imageUrl: data['file']?.toString(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Scan Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'Scan Information',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scanned: ${DateTime.now().toString().substring(0, 19)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Source: Gallery',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value, {
    bool isImageAvailable = false,
    String? imageUrl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: isImageAvailable && imageUrl != null
              ? Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipOval(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Available',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
              : Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: value == 'Not available' ? Colors.red : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}