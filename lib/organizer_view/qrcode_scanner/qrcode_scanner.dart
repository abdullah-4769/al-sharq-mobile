import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanned = false;
  String? lastScannedCode;
  DateTime? lastScanTime;

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
          _showSuccessDialog(code);
        }
      }
    }
  }

  void _showSuccessDialog(String qrData) {
    // Parse QR data and extract details (you can customize this based on your QR format)
    final details = _parseQRData(qrData);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 40,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Access Granted',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Checked in Successfully',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(details['avatar'] ?? 'https://via.placeholder.com/50'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details['name'] ?? 'Unknown User',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Badge ID: ${details['badgeId'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Role: ${details['role'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Location: ${details['location'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Display raw QR data
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                'QR Data: $qrData',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => isScanned = false);
              Get.back();
            },
            child: Text(
              'Close',
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to parse QR data and extract user details
  Map<String, String> _parseQRData(String qrData) {
    Map<String, String> details = {};

    try {
      // If QR data is JSON format
      if (qrData.startsWith('{') && qrData.endsWith('}')) {
        // You can parse JSON here if your QR contains JSON data
        // final jsonData = json.decode(qrData);
        // details = Map<String, String>.from(jsonData);
      }
      // If QR data contains key-value pairs separated by |
      else if (qrData.contains('|')) {
        final parts = qrData.split('|');
        for (String part in parts) {
          if (part.contains(':')) {
            final keyValue = part.split(':');
            if (keyValue.length == 2) {
              details[keyValue[0].trim()] = keyValue[1].trim();
            }
          }
        }
      }
      // If QR data is comma separated
      else if (qrData.contains(',')) {
        final parts = qrData.split(',');
        if (parts.length >= 4) {
          details['name'] = parts[0].trim();
          details['badgeId'] = parts[1].trim();
          details['role'] = parts[2].trim();
          details['location'] = parts[3].trim();
        }
      }
      // Default case - use the QR data as name
      else {
        details['name'] = qrData;
        details['badgeId'] = 'AUTO-${DateTime.now().millisecondsSinceEpoch}';
        details['role'] = 'Visitor';
        details['location'] = 'Main Hall';
      }
    } catch (e) {
      // If parsing fails, use default values
      details = {
        'name': 'User ${DateTime.now().millisecondsSinceEpoch}',
        'badgeId': 'AUTO-${DateTime.now().millisecondsSinceEpoch}',
        'role': 'Guest',
        'location': 'Reception',
      };
    }

    // Set avatar based on name or use random
    final avatars = [
      'https://i.pravatar.cc/150?img=1',
      'https://i.pravatar.cc/150?img=2',
      'https://i.pravatar.cc/150?img=3',
      'https://i.pravatar.cc/150?img=4',
      'https://i.pravatar.cc/150?img=5',
    ];
    details['avatar'] = avatars[DateTime.now().millisecondsSinceEpoch % avatars.length];

    return details;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'QR Scanner',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              shape: QrScannerOverlayShape(
                borderColor: AppColors.primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 5,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),

          // Loading indicator when processing
          if (isScanned)
            Container(
              color: Colors.black54,
              child: Center(
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

// Custom overlay shape for the scanner
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
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

    // Draw corner borders
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
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}