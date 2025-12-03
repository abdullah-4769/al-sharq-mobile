import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ImageCaptureService {

  // Capture widget as image
  static Future<Uint8List?> captureWidget(GlobalKey widgetKey) async {
    try {
      final RenderRepaintBoundary boundary =
      widgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
      return null;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Save image to device
  static Future<void> saveImageToDevice(
      Uint8List imageBytes,
      String fileName,
      BuildContext context
      ) async {
    try {
      // Check and request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }

      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final safeFileName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final filePath = '${directory.path}/$safeFileName.png';
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      Get.snackbar(
        'Success',
        'QR code saved: $safeFileName.png',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Share image
  static Future<void> shareImage(
      Uint8List imageBytes,
      String fileName,
      String participantName,
      BuildContext context
      ) async {
    try {
      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final safeFileName = fileName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final filePath = '${directory.path}/$safeFileName.png';
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Share the image
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'QR Code for $participantName',
        subject: 'Participant QR Code',
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}