import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';

import 'package:al_sharq_conference/qr_code/qr_generator_service.dart';

import '../data/response_models/registration_team_model/event_registration_check_model.dart';
import '../view_model/registration_team_viewmodels/event_registration_viewmodel.dart';

class EventRegistrationScanScreen extends StatefulWidget {
  final String? eventId;

  const EventRegistrationScanScreen({super.key, this.eventId});

  @override
  State<EventRegistrationScanScreen> createState() => _EventRegistrationScanScreenState();
}

class _EventRegistrationScanScreenState extends State<EventRegistrationScanScreen> {
  late MobileScannerController cameraController;
  bool isScanned = false;
  String? lastScannedCode;
  DateTime? lastScanTime;
  Map<String, dynamic>? scannedData;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;

  final EventRegistrationViewModel registrationViewModel = Get.put(EventRegistrationViewModel());
  final TextEditingController _eventIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );

    if (widget.eventId != null) {
      _eventIdController.text = widget.eventId!;
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    _eventIdController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
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

  Future<void> _processQRCode(String code) async {
    try {
      // Parse QR data
      scannedData = QRGeneratorService.parseQRString(code);

      if (scannedData != null && QRGeneratorService.isValidParticipantQR(scannedData)) {
        final String? userId = QRGeneratorService.extractUserId(scannedData)?.toString();
        final String eventId = _eventIdController.text.trim();

        if (userId != null && eventId.isNotEmpty) {
          await _checkEventRegistration(eventId, userId);
        } else {
          _showManualInputDialog(scannedData!);
        }
      } else {
        _showErrorDialog('Invalid QR code format');
      }
    } catch (e) {
      _showErrorDialog('Error processing QR code: $e');
    } finally {
      if (mounted) {
        setState(() => isScanned = false);
      }
    }
  }

  Future<void> _checkEventRegistration(String eventId, String userId) async {
    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await registrationViewModel.checkRegistrationRequirement(eventId, userId);
      Get.back();

      _showRegistrationResult();
    } catch (e) {
      Get.back();
      _showErrorDialog('Error checking registration: $e');
    }
  }

  void _showRegistrationResult() {
    final result = registrationViewModel.registrationCheck;
    final participantName = scannedData?['name']?.toString() ?? 'Unknown';
    final participantEmail = scannedData?['email']?.toString() ?? 'No email';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(
              result!.isRegistered ? Icons.check_circle :
              result.required ? Icons.warning : Icons.info,
              size: 50,
              color: result.isRegistered ? Colors.green :
              result.required ? Colors.orange : Colors.blue,
            ),
            const SizedBox(height: 8),
            Text(
              result.isRegistered ? 'Registered' :
              result.required ? 'Registration Required' : 'No Registration Needed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: result.isRegistered ? Colors.green :
                result.required ? Colors.orange : Colors.blue,
              ),
            ),
          ],
        ),
        content: _buildResultContent(result, participantName, participantEmail),
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

  Widget _buildResultContent(
      EventRegistrationCheckModel result,
      String participantName,
      String participantEmail,
      ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Participant Info
          Container(
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
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: ClipOval(
                    child: scannedData?['file'] != null && scannedData?['file'].toString().isNotEmpty == true
                        ? Image.network(
                      scannedData!['file'].toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    )
                        : _buildDefaultAvatar(),
                  ),
                ),

                // Name
                Text(
                  participantName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // Email
                Text(
                  participantEmail,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 8),

                // Role
                if (scannedData?['role'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      scannedData!['role'].toString().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Registration Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: result.isRegistered ? Colors.green.withOpacity(0.1) :
              result.required ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: result.isRegistered ? Colors.green :
                result.required ? Colors.orange : Colors.blue,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      result.isRegistered ? Icons.check_circle :
                      result.required ? Icons.warning : Icons.info,
                      color: result.isRegistered ? Colors.green :
                      result.required ? Colors.orange : Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: result.isRegistered ? Colors.green :
                          result.required ? Colors.orange : Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Event ID: ${_eventIdController.text}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog(Map<String, dynamic> participantData) {
    Get.dialog(
      AlertDialog(
        title: const Text('Enter Event ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter the Event ID to check registration:'),
            const SizedBox(height: 16),
            TextField(
              controller: _eventIdController,
              decoration: const InputDecoration(
                labelText: 'Event ID',
                border: OutlineInputBorder(),
                hintText: 'Enter event ID',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final eventId = _eventIdController.text.trim();
              final userId = QRGeneratorService.extractUserId(participantData)?.toString();

              if (eventId.isNotEmpty && userId != null) {
                Get.back();
                _checkEventRegistration(eventId, userId);
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter a valid Event ID',
                  backgroundColor: Colors.red,
                );
              }
            },
            child: const Text('Check'),
          ),
        ],
      ),
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

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 30, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Check Event Registration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
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
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 5,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),

          // Event ID Input
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                children: [
                  const Text(
                    'Scanning for Event Registration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _eventIdController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: 'Enter Event ID',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.event, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Scan participant QR code',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Event registration check mode',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Text(
                      'Registration Check',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
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
                      'Checking registration...',
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