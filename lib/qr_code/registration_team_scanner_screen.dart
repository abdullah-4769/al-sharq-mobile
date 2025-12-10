// lib/qr_code/registration_team_scanner_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import '../qr_code/qr_generator_service.dart';
import '../view_model/registration_team_viewmodels/session_check_viewmodel.dart';

class RegistrationTeamScannerScreen extends StatefulWidget {
  final int? sessionId;
  final String? sessionTitle;
  final String? sessionTime;

  const RegistrationTeamScannerScreen({
    super.key,
    this.sessionId,
    this.sessionTitle,
    this.sessionTime,
  });

  @override
  State<RegistrationTeamScannerScreen> createState() => _RegistrationTeamScannerScreenState();
}

class _RegistrationTeamScannerScreenState extends State<RegistrationTeamScannerScreen> {
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
    cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }



// Update the _onDetect method to handle both modes properly:
  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        print("=== QR CODE RAW DATA ===");
        print(code);
        print("=== END QR DATA ===");

        final now = DateTime.now();
        final shouldProcess = lastScannedCode != code ||
            lastScanTime == null ||
            now.difference(lastScanTime!).inSeconds > 3;

        if (shouldProcess && !isScanned) {
          setState(() {
            isScanned = true;
            lastScannedCode = code;
            lastScanTime = now;
          });

          // Parse QR data
          scannedData = QRGeneratorService.parseQRString(code);
          print("=== PARSED QR DATA ===");
          print(scannedData);
          print("=== END PARSED DATA ===");

          if (scannedData != null && QRGeneratorService.isValidParticipantQR(scannedData)) {
            if (widget.sessionId != null) {
              // Session check mode - IMPORTANT: Check session registration
              _checkSessionRegistration(scannedData!);
            } else {
              // General participant details mode
              _showScannedDetails(scannedData);
            }
          } else {
            _showErrorDialog('Invalid QR code format or missing required data');
          }
        }
      }
    }
  }

// Add this method for session registration check:
  Future<void> _checkSessionRegistration(Map<String, dynamic> participantData) async {
    final userId = participantData['id'] ?? participantData['userId'];
    final userIdInt = userId is int ? userId : int.tryParse(userId?.toString() ?? '');

    if (userIdInt == null) {
      _showErrorDialog('User ID not found in QR code');
      return;
    }

    // Show loading dialog
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      final result = await checkViewModel.checkSessionRegistration(
        sessionId: widget.sessionId!,
        userId: userIdInt,
        context: context,
      );

      Get.back(); // Close loading dialog
      _showRegistrationResult(participantData, result);
    } catch (e) {
      Get.back();
      _showErrorDialog('Error checking registration: $e');
    }
  }

  void _showRegistrationResult(Map<String, dynamic> participantData, Map<String, dynamic> result) {
    final participantName = participantData['name']?.toString() ?? 'Unknown';
    final participantEmail = participantData['email']?.toString() ?? 'No email';
    final isRegistered = result['isRegistered'] ?? false;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRegistered ? '✅ Registration Confirmed' : '⚠️ Not Registered',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isRegistered ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            if (widget.sessionTitle != null)
              Text(
                'Session: ${widget.sessionTitle}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Participant Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    // Profile Image
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 1),
                      ),
                      child: ClipOval(
                        child: participantData['file'] != null && participantData['file'].toString().isNotEmpty
                            ? Image.network(
                          participantData['file'].toString(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
                        )
                            : _buildDefaultAvatar(),
                      ),
                    ),

                    Text(
                      participantName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      participantEmail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (participantData['role'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          participantData['role'].toString().toUpperCase(),
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
                  color: isRegistered ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isRegistered ? Colors.green : Colors.orange,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isRegistered ? Icons.check_circle : Icons.warning,
                          color: isRegistered ? Colors.green : Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            result['message'],
                            style: TextStyle(
                              fontSize: 14,
                              color: isRegistered ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Session ID: ${widget.sessionId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    if (widget.sessionTime != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Time: ${widget.sessionTime}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Scan Time
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Scanned: ${DateTime.now().toString().substring(0, 19)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => isScanned = false);
              Get.back();
            },
            child: const Text(
              'Scan Another',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => isScanned = false);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showScannedDetails(Map<String, dynamic>? data) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Participant Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: data != null ? _buildDetailsContent(data) : _buildErrorContent(),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => isScanned = false);
              Get.back();
            },
            child: const Text(
              'Close',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
              )
                  : _buildDefaultAvatar(),
            ),
          ),

          Text(
            data['name']?.toString() ?? 'Unknown',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

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

          // Details Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                _buildDetailItem('User ID', data['id']?.toString() ?? data['userId']?.toString() ?? 'Not available'),
                const SizedBox(height: 12),
                _buildDetailItem('Email', data['email']?.toString() ?? 'Not available'),
                const SizedBox(height: 12),
                _buildDetailItem('Role', data['role']?.toString() ?? 'Not available'),
                if (data['bio'] != null && data['bio'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailItem('Bio', data['bio'].toString()),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Scan Time
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Scanned: ${DateTime.now().toString().substring(0, 19)}',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {
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

  Widget _buildErrorContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error,
            color: Colors.red,
            size: 40,
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Invalid QR Code',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'The scanned QR code is not valid or corrupted',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        const Text(
          'Please scan a valid participant QR code',
          style: TextStyle(
            fontSize: 12,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.brown,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 30,
          color: Colors.white,
        ),
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
              setState(() => isScanned = false);
              Get.back();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        title: isSessionMode
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Check Session Registration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (widget.sessionTitle != null)
              Text(
                widget.sessionTitle!.length > 30
                    ? '${widget.sessionTitle!.substring(0, 30)}...'
                    : widget.sessionTitle!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
          ],
        )
            : const Text(
          'Scan Participant QR',
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
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
              cameraController.toggleTorch();
            },
          ),
          IconButton(
            icon: Icon(
              _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isFrontCamera = !_isFrontCamera;
              });
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

          if (isSessionMode)
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
                  border: Border.all(color: AppColors.primaryColor),
                ),
                child: Column(
                  children: [
                    Text(
                      'Scanning for: ${widget.sessionTitle ?? 'Session'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Session ID: ${widget.sessionId}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

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
                        ? 'Scan participant QR code'
                        : 'Align QR code within the frame',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSessionMode
                        ? 'Checking registration for Session #${widget.sessionId}'
                        : 'Scan participant QR code to view details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isSessionMode) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Text(
                        'Registration Check Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
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
                      'Processing QR Code...',
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
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const _ScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    Path hole = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: rect.center,
              width: cutOutSize,
              height: cutOutSize),
          Radius.circular(borderRadius)));
    return Path.combine(PathOperation.difference, path, hole);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final mPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: rect.center,
              width: cutOutSize,
              height: cutOutSize),
          Radius.circular(borderRadius)));

    canvas.clipPath(mPath);
    canvas.drawRect(
        Rect.fromLTWH(0, 0, width, height), Paint()..color = overlayColor);

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final center = rect.center;
    final left = center.dx - cutOutSize / 2;
    final top = center.dy - cutOutSize / 2;
    final right = center.dx + cutOutSize / 2;
    final bottom = center.dy + cutOutSize / 2;

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
    path.moveTo(right, bottom - borderRadius);
    path.lineTo(right, bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return _ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}