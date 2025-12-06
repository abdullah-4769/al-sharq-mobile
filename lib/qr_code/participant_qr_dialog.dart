// // lib/qr_code/participant_qr_dialog.dart - UPDATED VERSION
// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui';
// import 'dart:ui' as ui;
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:al_sharq_conference/app_colors/app_colors.dart';
// import 'package:al_sharq_conference/custom_widgets/app_text.dart';
// import 'package:share_plus/share_plus.dart';
// import '../data/response_models/registration_team_model/participant_response_model.dart';
// import '../qr_code/qr_generator_service.dart';
//
// class ParticipantQRDialog extends StatefulWidget {
//   final Participant participant;
//
//   ParticipantQRDialog({super.key, required this.participant});
//
//   @override
//   State<ParticipantQRDialog> createState() => _ParticipantQRDialogState();
// }
//
// class _ParticipantQRDialogState extends State<ParticipantQRDialog> {
//   String? _qrData;
//   Map<String, dynamic>? _parsedData;
//   final GlobalKey _repaintBoundaryKey = GlobalKey(); // Changed to repaint boundary key
//
//   @override
//   void initState() {
//     super.initState();
//     _generateQR();
//   }
//
//   void _generateQR() {
//     try {
//       final participantData = {
//         'id': widget.participant.id,
//         'name': widget.participant.name,
//         'email': widget.participant.email,
//         'role': widget.participant.role,
//         'file': widget.participant.file,
//         'bio': widget.participant.bio,
//         'organization': widget.participant.organization,
//       };
//
//       _qrData = QRGeneratorService.generateQRString(participantData);
//       _parsedData = QRGeneratorService.parseQRString(_qrData!);
//
//       print("=== GENERATED QR DATA ===");
//       print("QR String: $_qrData");
//       print("Parsed Data: $_parsedData");
//       print("=== END QR DATA ===");
//
//       if (_parsedData == null || !QRGeneratorService.isValidParticipantQR(_parsedData)) {
//         print("WARNING: Generated QR is not valid!");
//       }
//     } catch (e) {
//       print("Error generating QR: $e");
//       _qrData = jsonEncode({
//         'id': widget.participant.id,
//         'name': widget.participant.name,
//         'email': widget.participant.email,
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;
//     final qrSize = isTablet ? 200.0 : 160.0;
//
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       backgroundColor: AppColors.whiteColor,
//       child: Container(
//         constraints: BoxConstraints(
//           maxWidth: isTablet ? 450 : 340,
//         ),
//         padding: const EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with close button
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Flexible(
//                     child: AppText(
//                       text: 'Participant QR Code',
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.grey, size: 20),
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
//                     onPressed: () => Get.back(),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 16),
//
//               // Profile Section
//               _buildProfileSection(),
//
//               const SizedBox(height: 20),
//
//               // QR Code Container - FIXED: RepaintBoundary moved to top level
//               _buildQRCodeContainer(qrSize),
//
//               const SizedBox(height: 20),
//
//               // Participant Info
//               _buildParticipantInfo(),
//
//               const SizedBox(height: 16),
//
//               // Download button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _downloadQRCode,
//                   icon: const Icon(Icons.download, size: 18),
//                   label: const AppText(
//                     text: 'Download QR Code',
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileSection() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Profile Image
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: AppColors.primaryColor, width: 1.5),
//           ),
//           child: ClipOval(
//             child: widget.participant.file != null && widget.participant.file!.isNotEmpty
//                 ? Image.network(
//               widget.participant.file!,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
//             )
//                 : _buildDefaultAvatar(),
//           ),
//         ),
//
//         const SizedBox(width: 12),
//
//         // User Info
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               AppText(
//                 text: widget.participant.name,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 2),
//               AppText(
//                 text: widget.participant.email,
//                 fontSize: 12,
//                 color: Colors.grey,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: AppColors.lightred,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: AppText(
//                   text: widget.participant.role.toUpperCase(),
//                   fontSize: 10,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildQRCodeContainer(double qrSize) {
//     return RepaintBoundary( // Moved RepaintBoundary to top level
//       key: _repaintBoundaryKey, // Use the repaint boundary key here
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: AppColors.lightGreyColor, width: 1),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             // Badge ID
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: AppText(
//                 text: 'Badge ID: ASF-${widget.participant.id}',
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.primaryColor,
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             // QR Code
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: AppColors.mediumGreyColor, width: 1),
//               ),
//               child: QrImageView(
//                 data: _qrData ?? '',
//                 version: QrVersions.auto,
//                 size: qrSize,
//                 eyeStyle: const QrEyeStyle(
//                   eyeShape: QrEyeShape.square,
//                   color: AppColors.primaryColor,
//                 ),
//                 dataModuleStyle: const QrDataModuleStyle(
//                   dataModuleShape: QrDataModuleShape.square,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // Scan Instructions
//             const AppText(
//               text: 'Scan to view participant details',
//               fontSize: 11,
//               color: Colors.grey,
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildParticipantInfo() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const AppText(
//             text: 'QR Contains:',
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//
//           const SizedBox(height: 12),
//
//           // User ID (IMPORTANT)
//           _buildInfoRow('User ID', widget.participant.id.toString()),
//           const SizedBox(height: 8),
//
//           // Name
//           _buildInfoRow('Name', widget.participant.name),
//           const SizedBox(height: 8),
//
//           // Email
//           _buildInfoRow('Email', widget.participant.email),
//           const SizedBox(height: 8),
//
//           // Role
//           _buildInfoRow('Role', widget.participant.role),
//           const SizedBox(height: 8),
//
//           // Bio (if available)
//           if (widget.participant.bio != null && widget.participant.bio!.isNotEmpty)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildInfoRow('Bio', widget.participant.bio!),
//                 const SizedBox(height: 8),
//               ],
//             ),
//
//           // File/Image (if available)
//           if (widget.participant.file != null && widget.participant.file!.isNotEmpty)
//             _buildInfoRow('Profile Image', 'Available', isLink: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AppText(
//           text: label,
//           fontSize: 11,
//           fontWeight: FontWeight.w500,
//           color: Colors.grey,
//         ),
//         const SizedBox(height: 4),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(6),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: AppText(
//             text: value,
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//             color: isLink ? Colors.blue : Colors.black87,
//             maxLines: isLink ? 1 : 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Future<Uint8List?> _captureQRImage() async {
//     try {
//       // Wait for the widget to be rendered
//       await Future.delayed(const Duration(milliseconds: 300));
//
//       final BuildContext? context = _repaintBoundaryKey.currentContext;
//       if (context == null) {
//         print("Context is null");
//         return null;
//       }
//
//       final RenderRepaintBoundary? boundary = context.findRenderObject() as RenderRepaintBoundary?;
//       if (boundary == null) {
//         print("RenderRepaintBoundary not found");
//         return null;
//       }
//
//       if (!boundary.debugNeedsPaint) {
//         final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//         final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//
//         if (byteData != null) {
//           return byteData.buffer.asUint8List();
//         }
//       } else {
//         print("Boundary needs paint");
//         // Force a frame
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           setState(() {});
//         });
//         await Future.delayed(const Duration(milliseconds: 100));
//         return _captureQRImage(); // Try again
//       }
//       return null;
//     } catch (e) {
//       print('Error capturing QR image: $e');
//       return null;
//     }
//   }
//
//   Future<Uint8List?> _generateQRImage() async {
//     try {
//       // Create a QrPainter and render it directly
//       final qr = QrPainter(
//         data: _qrData ?? '',
//         version: QrVersions.auto,
//         eyeStyle: const QrEyeStyle(
//           eyeShape: QrEyeShape.square,
//           color: AppColors.primaryColor,
//         ),
//         dataModuleStyle: const QrDataModuleStyle(
//           dataModuleShape: QrDataModuleShape.square,
//           color: Colors.black,
//         ),
//       );
//
//       // Create a picture recorder
//       final recorder = ui.PictureRecorder();
//       final canvas = Canvas(recorder);
//       final size = 300.0;
//       final squareSize = Size(size, size);
//
//       // Draw QR code - FIXED: Pass Size, not Offset
//       qr.paint(canvas, squareSize);
//
//       // Create image
//       final picture = recorder.endRecording();
//       final image = await picture.toImage(size.toInt(), size.toInt());
//       final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//
//       if (byteData != null) {
//         return byteData.buffer.asUint8List();
//       }
//       return null;
//     } catch (e) {
//       print('Error generating QR image: $e');
//       return null;
//     }
//   }
//
//
// // Change the _saveQRCodeToDevice method signature:
//   Future<void> _saveQRCodeToDevice(Uint8List? imageBytes) async {
//     try {
//       // If imageBytes is not provided, generate it
//       if (imageBytes == null) {
//         imageBytes = await _generateQRImage();
//       }
//
//       if (imageBytes == null) {
//         Get.snackbar(
//           '❌ Error',
//           'Failed to generate QR code',
//           backgroundColor: Colors.red,
//         );
//         return;
//       }
//
//       Get.dialog(
//         const Center(child: CircularProgressIndicator()),
//         barrierDismissible: false,
//       );
//
//       try {
//         // Save to gallery using image_gallery_saver
//         final result = await ImageGallerySaver.saveImage(
//           Uint8List.fromList(imageBytes),
//           quality: 100,
//           name: 'QR_${widget.participant.name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}_${widget.participant.id}',
//         );
//
//         Get.back();
//
//         if (result['isSuccess'] == true) {
//           Get.snackbar(
//             '✅ Success',
//             'QR code saved to gallery!',
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             duration: const Duration(seconds: 3),
//           );
//         } else {
//           Get.snackbar(
//             '❌ Error',
//             'Failed to save to gallery: ${result['errorMessage']}',
//             backgroundColor: Colors.red,
//           );
//         }
//       } catch (e) {
//         Get.back();
//         Get.snackbar(
//           '❌ Error',
//           'Failed to save: $e',
//           backgroundColor: Colors.red,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         '❌ Error',
//         'Failed to generate QR: $e',
//         backgroundColor: Colors.red,
//       );
//     }
//   }
//
//   Future<void> _shareQRCode(Uint8List? imageBytes) async {
//     try {
//       // If imageBytes is not provided, generate it
//       if (imageBytes == null) {
//         imageBytes = await _generateQRImage();
//       }
//
//       if (imageBytes == null) return;
//
//       final directory = await getTemporaryDirectory();
//       final fileName = 'QR_${widget.participant.name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}_${widget.participant.id}.png';
//       final filePath = '${directory.path}/$fileName';
//       final File file = File(filePath);
//       await file.writeAsBytes(imageBytes);
//
//       await Share.shareXFiles(
//         [XFile(filePath)],
//         text: 'QR Code for ${widget.participant.name} (ASF-${widget.participant.id})',
//         subject: 'Participant QR Code - ${widget.participant.name}',
//       );
//     } catch (e) {
//       Get.snackbar(
//         '❌ Error',
//         'Failed to share QR code: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//   Future<void> _downloadQRCode() async {
//     try {
//       // Show loading
//       Get.dialog(
//         const Center(
//           child: CircularProgressIndicator(),
//         ),
//         barrierDismissible: false,
//       );
//
//       // Try both methods
//       Uint8List? imageBytes;
//
//       // First try: Capture from widget
//       imageBytes = await _captureQRImage();
//
//       // If that fails, try generating directly
//       if (imageBytes == null) {
//         print('Widget capture failed, trying direct generation...');
//         imageBytes = await _generateQRImage();
//       }
//
//       if (imageBytes == null) {
//         Get.back();
//         Get.snackbar(
//           '❌ Error',
//           'Failed to generate QR code image',
//           backgroundColor: Colors.red,
//         );
//         return;
//       }
//
//       Get.back(); // Close loading dialog
//
//       // Show download options
//       _showDownloadOptions(imageBytes);
//     } catch (e) {
//       Get.back();
//       Get.snackbar(
//         '❌ Error',
//         'Failed to download QR code: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   void _showDownloadOptions(Uint8List imageBytes) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 10),
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Download QR Code',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 '${widget.participant.name} - ASF-${widget.participant.id}',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//
//               // Save to Device
//               // Save to Device
//               ListTile(
//                 leading: const Icon(Icons.save_alt, color: Colors.blue),
//                 title: const Text('Save to Device'),
//                 subtitle: const Text('Save QR code to device storage'),
//                 onTap: () async {
//                   Get.back();
//                   await _saveQRCodeToDevice(imageBytes);
//                 },
//               ),
//
// // Share QR Code
//               ListTile(
//                 leading: const Icon(Icons.share, color: Colors.green),
//                 title: const Text('Share QR Code'),
//                 subtitle: const Text('Share via other apps'),
//                 onTap: () async {
//                   Get.back();
//                   await _shareQRCode(imageBytes);
//                 },
//               ),
//
//               // // Copy QR Data to Clipboard
//               // ListTile(
//               //   leading: const Icon(Icons.content_copy, color: Colors.orange),
//               //   title: const Text('Copy QR Data'),
//               //   subtitle: const Text('Copy QR data text to clipboard'),
//               //   onTap: () {
//               //     Get.back();
//               //     _copyQRDataToClipboard();
//               //   },
//               // ),
//
//               const SizedBox(height: 20),
//               OutlinedButton(
//                 onPressed: () => Get.back(),
//                 style: OutlinedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   side: BorderSide(color: Colors.grey[300]!),
//                 ),
//                 child: const Text('Cancel'),
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<void> _copyQRDataToClipboard() async {
//     try {
//       final qrData = _qrData ?? '';
//       await Clipboard.setData(ClipboardData(text: qrData));
//       Get.snackbar(
//         '✅ Copied',
//         'QR data copied to clipboard',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       Get.snackbar(
//         '❌ Error',
//         'Failed to copy to clipboard: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   Widget _buildDefaultAvatar() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.brown,
//         shape: BoxShape.circle,
//       ),
//       child: const Center(
//         child: Icon(
//           Icons.person,
//           size: 24,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }

// lib/qr_code/participant_qr_dialog.dart
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import '../data/response_models/registration_team_model/participant_response_model.dart';
import '../qr_code/qr_generator_service.dart';

class ParticipantQRDialog extends StatefulWidget {
  final Participant participant;

  ParticipantQRDialog({super.key, required this.participant});

  @override
  State<ParticipantQRDialog> createState() => _ParticipantQRDialogState();
}

class _ParticipantQRDialogState extends State<ParticipantQRDialog> {
  String? _qrData;
  Map<String, dynamic>? _parsedData;
  final GlobalKey _qrKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _generateQR();
  }

// In participant_qr_dialog.dart, update _generateQR method
  void _generateQR() {
    try {
      // Create data map from participant
      final participantData = {
        'id': widget.participant.id,
        'name': widget.participant.name,
        'email': widget.participant.email,
        'role': widget.participant.role,
        'file': widget.participant.file,
        'bio': widget.participant.bio,
        'organization': widget.participant.organization,
      };

      // Generate QR string
      _qrData = QRGeneratorService.generateQRString(participantData);

      // Parse it back to verify
      _parsedData = QRGeneratorService.parseQRString(_qrData!);

      print("=== GENERATED QR DATA ===");
      print("QR String: $_qrData");
      print("Parsed Data: $_parsedData");
      print("=== END QR DATA ===");

      if (_parsedData == null || !QRGeneratorService.isValidParticipantQR(_parsedData)) {
        print("WARNING: Generated QR is not valid!");
      }
    } catch (e) {
      print("Error generating QR: $e");
      // Fallback: create simple JSON
      _qrData = jsonEncode({
        'id': widget.participant.id,
        'name': widget.participant.name,
        'email': widget.participant.email,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final qrSize = isTablet ? 200.0 : 160.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: AppColors.whiteColor,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 450 : 340,
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: AppText(
                      text: 'Participant QR Code',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Profile Section
              _buildProfileSection(),

              const SizedBox(height: 20),

              // QR Code Container
              _buildQRCodeContainer(qrSize),

              const SizedBox(height: 20),

              // Participant Info
              _buildParticipantInfo(),

              const SizedBox(height: 16),

              // Download button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _downloadQRCode,
                  icon: const Icon(Icons.download, size: 18),
                  label: const AppText(
                    text: 'Download QR Code',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Image
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryColor, width: 1.5),
          ),
          child: ClipOval(
            child: widget.participant.file != null && widget.participant.file!.isNotEmpty
                ? Image.network(
              widget.participant.file!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
            )
                : _buildDefaultAvatar(),
          ),
        ),

        const SizedBox(width: 12),

        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: widget.participant.name,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              AppText(
                text: widget.participant.email,
                fontSize: 12,
                color: Colors.grey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.lightred,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText(
                  text: widget.participant.role.toUpperCase(),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodeContainer(double qrSize) {
    return Container(
      key: _qrKey, // Add this key
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreyColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              text: 'Badge ID: ASF-${widget.participant.id}',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // QR Code
          RepaintBoundary( // Wrap with RepaintBoundary for better capture
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.mediumGreyColor, width: 1),
              ),
              child: QrImageView(
                data: _qrData ?? '',
                version: QrVersions.auto,
                size: qrSize,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primaryColor,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Scan Instructions
          const AppText(
            text: 'Scan to view participant details',
            fontSize: 11,
            color: Colors.grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            text: 'QR Contains:',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),

          const SizedBox(height: 12),

          // User ID (IMPORTANT)
          _buildInfoRow('User ID', widget.participant.id.toString()),
          const SizedBox(height: 8),

          // Name
          _buildInfoRow('Name', widget.participant.name),
          const SizedBox(height: 8),

          // Email
          _buildInfoRow('Email', widget.participant.email),
          const SizedBox(height: 8),

          // Role
          _buildInfoRow('Role', widget.participant.role),
          const SizedBox(height: 8),

          // Bio (if available)
          if (widget.participant.bio != null && widget.participant.bio!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Bio', widget.participant.bio!),
                const SizedBox(height: 8),
              ],
            ),

          // File/Image (if available)
          if (widget.participant.file != null && widget.participant.file!.isNotEmpty)
            _buildInfoRow('Profile Image', 'Available', isLink: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: AppText(
            text: value,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isLink ? Colors.blue : Colors.black87,
            maxLines: isLink ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _downloadQRCode() async {
    try {
      Get.snackbar(
        'Coming Soon',
        'QR code download feature will be available in next update',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download QR code: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}