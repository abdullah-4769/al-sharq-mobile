// lib/qr_code/universal_qr_scanner_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import '../qr_code/qr_generator_service.dart';
import '../view_model/registration_team_viewmodels/session_check_viewmodel.dart';
import 'gallery_qr_scanner_service.dart';

class UniversalQRScannerScreen extends StatefulWidget {
  final int? sessionId;
  final String? sessionTitle;
  final String? sessionTime;
  final bool showGalleryOption;

  const UniversalQRScannerScreen({
    super.key,
    this.sessionId,
    this.sessionTitle,
    this.sessionTime,
    this.showGalleryOption = true,
  });

  @override
  State<UniversalQRScannerScreen> createState() => _UniversalQRScannerScreenState();
}

class _UniversalQRScannerScreenState extends State<UniversalQRScannerScreen> {
  late MobileScannerController cameraController;
  bool isScanned = false;
  String? lastScannedCode;
  DateTime? lastScanTime;
  Map<String, dynamic>? scannedData;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  final SessionCheckViewModel checkViewModel = Get.put(SessionCheckViewModel());

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        debugPrint("=== QR CODE RAW DATA ===");
        debugPrint(code);
        debugPrint("=== END QR DATA ===");

        final now = DateTime.now();
        final shouldProcess = lastScannedCode != code ||
            lastScanTime == null ||
            now.difference(lastScanTime!).inSeconds > 2;

        if (shouldProcess && !isScanned) {
          setState(() {
            isScanned = true;
            lastScannedCode = code;
            lastScanTime = now;
          });

          _processQRCode(code);
        }
      }
    }
  }

// In UniversalQRScannerScreen.dart, update _processQRCode method
  Future<void> _processQRCode(String code) async {
    try {
      // Debug the raw QR data
      QRDebugService.printQRData(code);

      // Parse QR data
      scannedData = QRGeneratorService.parseQRString(code);
      debugPrint("=== PARSED QR DATA ===");
      debugPrint(scannedData.toString());
      debugPrint("=== END PARSED DATA ===");

      if (scannedData != null && QRGeneratorService.isValidParticipantQR(scannedData)) {
        if (widget.sessionId != null) {
          await _checkSessionRegistration(scannedData!);
        } else {
          _showParticipantDetails(scannedData!);
        }
      } else {
        // Show what we got for debugging
        _showDebugInfo(code);
      }
    } catch (e) {
      _showErrorDialog('Error processing QR code: $e\n\nRaw Data: ${code.substring(0, 100)}...');
    } finally {
      if (mounted) {
        setState(() => isScanned = false);
      }
    }
  }

  void _showDebugInfo(String rawCode) {
    Get.dialog(
      AlertDialog(
        title: const Text('QR Code Analysis'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'The QR code format is not recognized as a participant QR.',
                style: TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 16),
              const Text(
                'Raw QR Data:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  rawCode,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Expected Format:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '{"id":123,"userId":123,"name":"John Doe","email":"john@example.com","role":"participant"}',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.green),
                ),
              ),
            ],
          ),
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

// In UniversalQRScannerScreen.dart, update the check registration method
  Future<void> _checkSessionRegistration(Map<String, dynamic> participantData) async {
    // Try multiple ways to get user ID
    int? userId;

    // Method 1: Use our extraction method
    userId = QRGeneratorService.extractUserId(participantData);

    // Method 2: If we have email but no ID, try to look it up
    if (userId == null && participantData['email'] != null) {
      // You might want to implement an API call to get user ID by email
      // For now, show error
      _showErrorDialog('Cannot check registration: User ID not found in QR code.\n\nAvailable data: ${participantData.keys.join(", ")}');
      return;
    }

    if (userId == null) {
      _showErrorDialog('User ID not found in QR code.\n\nQR Data:\n${participantData.toString()}');
      return;
    }

    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final result = await checkViewModel.checkSessionRegistration(
        sessionId: widget.sessionId!,
        userId: userId,
        context: context,
      );

      Get.back();
      _showRegistrationResult(participantData, result);
    } catch (e) {
      Get.back();
      _showErrorDialog('Error checking registration: $e');
    }
  }

  void _showRegistrationResult(Map<String, dynamic> participantData, Map<String, dynamic> result) {
    final isRegistered = result['isRegistered'] ?? false;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(
              isRegistered ? Icons.check_circle : Icons.warning,
              size: 50,
              color: isRegistered ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 8),
            Text(
              isRegistered ? 'Registration Confirmed' : 'Not Registered',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isRegistered ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        content: _buildResultContent(participantData, result),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              setState(() => isScanned = false);
            },
            child: const Text('Scan Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              setState(() => isScanned = false);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent(Map<String, dynamic> participantData, Map<String, dynamic> result) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Participant Info
          _buildParticipantInfo(participantData),

          const SizedBox(height: 16),

          // Session Info
          if (widget.sessionId != null) _buildSessionInfo(result),
        ],
      ),
    );
  }

  Widget _buildParticipantInfo(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
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

          const SizedBox(height: 8),

          // Name
          Text(
            data['name']?.toString() ?? 'Unknown',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            data['email']?.toString() ?? 'No email',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          // Role
          if (data['role'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                data['role'].toString().toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(Map<String, dynamic> result) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result['isRegistered'] ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            widget.sessionTitle ?? 'Session',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            result['message'] ?? 'Status unknown',
            style: TextStyle(
              fontSize: 13,
              color: result['isRegistered'] ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (widget.sessionTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Time: ${widget.sessionTime}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  void _showParticipantDetails(Map<String, dynamic> data) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Participant Details'),
        content: _buildDetailsContent(data),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              setState(() => isScanned = false);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContent(Map<String, dynamic> data) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildParticipantInfo(data),

          const SizedBox(height: 16),

          // Additional Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildDetailRow('User ID', data['id']?.toString() ?? 'Not available'),
                const SizedBox(height: 8),
                _buildDetailRow('Email', data['email']?.toString() ?? 'Not available'),
                const SizedBox(height: 8),
                _buildDetailRow('Role', data['role']?.toString() ?? 'Not available'),
                if (data['bio'] != null && data['bio'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Bio', data['bio'].toString()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
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

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 30, color: Colors.white),
    );
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              setState(() => isScanned = false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanFromGallery() async {
    final data = await GalleryQRScannerService.scanQRFromGallery(context);
    if (data != null) {
      if (widget.sessionId != null) {
        await _checkSessionRegistration(data);
      } else {
        _showParticipantDetails(data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSessionMode = widget.sessionId != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isSessionMode ? 'Check Registration' : 'Scan QR Code',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.showGalleryOption)
            IconButton(
              icon: const Icon(Icons.photo_library, color: Colors.white),
              onPressed: _scanFromGallery,
              tooltip: 'Scan from Gallery',
            ),
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
            onPressed: () {
              setState(() => _isTorchOn = !_isTorchOn);
              cameraController.toggleTorch();
            },
          ),
          IconButton(
            icon: Icon(_isFrontCamera ? Icons.camera_front : Icons.camera_rear, color: Colors.white),
            onPressed: () {
              setState(() => _isFrontCamera = !_isFrontCamera);
              cameraController.switchCamera();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // Scanner Overlay
          Container(
            decoration: ShapeDecoration(
              shape: _ScannerOverlayShape(
                borderColor: AppColors.primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 5,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),

          // Info Panel
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    isSessionMode
                        ? 'Scan participant QR for: ${widget.sessionTitle ?? "Session"}'
                        : 'Align QR code within frame',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  if (widget.showGalleryOption)
                    OutlinedButton.icon(
                      onPressed: _scanFromGallery,
                      icon: const Icon(Icons.photo_library, size: 16),
                      label: const Text('Pick from Gallery'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (isScanned)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const _ScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path()..addRect(rect);
    final Path hole = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: rect.center,
          width: cutOutSize,
          height: cutOutSize,
        ),
        Radius.circular(borderRadius),
      ));
    return Path.combine(PathOperation.difference, path, hole);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final center = rect.center;
    final left = center.dx - cutOutSize / 2;
    final top = center.dy - cutOutSize / 2;
    final right = center.dx + cutOutSize / 2;
    final bottom = center.dy + cutOutSize / 2;

    final Path path = Path();

    // Top left corner
    path.moveTo(left + borderRadius, top);
    path.lineTo(left + borderLength, top);
    path.moveTo(left, top + borderRadius);
    path.lineTo(left, top + borderLength);

    // Top right corner
    path.moveTo(right - borderLength, top);
    path.lineTo(right - borderRadius, top);
    path.moveTo(right, top + borderRadius);
    path.lineTo(right, top + borderLength);

    // Bottom left corner
    path.moveTo(left + borderRadius, bottom);
    path.lineTo(left + borderLength, bottom);
    path.moveTo(left, bottom - borderLength);
    path.lineTo(left, bottom - borderRadius);

    // Bottom right corner
    path.moveTo(right - borderLength, bottom);
    path.lineTo(right - borderRadius, bottom);
    path.moveTo(right, bottom - borderLength);
    path.lineTo(right, bottom - borderRadius);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}