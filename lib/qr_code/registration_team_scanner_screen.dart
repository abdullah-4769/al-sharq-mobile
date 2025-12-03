import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import '../qr_code/qr_generator_service.dart';

class RegistrationTeamScannerScreen extends StatefulWidget {
  const RegistrationTeamScannerScreen({super.key});

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

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        // Check if this is a new QR code or enough time has passed
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

          // Parse QR data
          scannedData = QRGeneratorService.parseQRString(code);

          // Show details dialog
          _showScannedDetails(scannedData);
        }
      }
    }
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

          // Name
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
                // Email
                _buildDetailItem('Email', data['email']?.toString() ?? 'Not available'),
                const SizedBox(height: 12),

                // Role
                _buildDetailItem('Role', data['role']?.toString() ?? 'Not available'),
                const SizedBox(height: 12),

                // Bio (if available)
                if (data['bio'] != null && data['bio'].toString().isNotEmpty)
                  Column(
                    children: [
                      _buildDetailItem('Bio', data['bio'].toString()),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Profile Image Status
                _buildDetailItem(
                  'Profile Image',
                  data['file'] != null && data['file'].toString().isNotEmpty ? 'Available' : 'Not available',
                  isImageAvailable: data['file'] != null && data['file'].toString().isNotEmpty,
                  imageUrl: data['file']?.toString(),
                ),
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
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),

          // Overlay with scanning frame
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
                    'Align QR code within the frame',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan participant QR code to view details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Processing overlay
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

// Custom scanner overlay
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
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
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