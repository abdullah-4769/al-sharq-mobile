import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';

import '../../qr_code/gallery_qr_scanner_service.dart';
import '../../qr_code/registration_team_scanner_screen.dart';


class ScanFABWidget extends StatefulWidget {
  final VoidCallback? onScanComplete;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;

  const ScanFABWidget({
    super.key,
    this.onScanComplete,
    this.tooltip = 'Scan QR Code',
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<ScanFABWidget> createState() => _ScanFABWidgetState();
}

class _ScanFABWidgetState extends State<ScanFABWidget> {
  bool _isScanning = false;

  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Scan QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose how you want to scan the QR code',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildScanOption(
                      icon: Icons.camera_alt,
                      title: 'Camera Scan',
                      subtitle: 'Scan using camera',
                      color: AppColors.primaryColor,
                      onTap: () {
                        Navigator.pop(context);
                        _startCameraScan();
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildScanOption(
                      icon: Icons.photo_library,
                      title: 'Gallery',
                      subtitle: 'Scan from gallery',
                      color: Colors.green,
                      onTap: () async {
                        Navigator.pop(context);
                        await _startGalleryScan();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startCameraScan() async {
    if (_isScanning) return;

    setState(() => _isScanning = true);

    try {
      await Get.to(() => const RegistrationTeamScannerScreen());
      if (widget.onScanComplete != null) {
        widget.onScanComplete!();
      }
    } catch (e) {
      print('Camera scan error: $e');
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _startGalleryScan() async {
    if (_isScanning) return;

    setState(() => _isScanning = true);

    try {
      final data = await GalleryQRScannerService.scanQRFromGallery(context);
      if (data != null) {
        GalleryQRScannerService.showParticipantDetails(data);
        if (widget.onScanComplete != null) {
          widget.onScanComplete!();
        }
      }
    } catch (e) {
      print('Gallery scan error: $e');
      Get.snackbar(
        'Error',
        'Failed to scan from gallery',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _isScanning ? null : _showScanOptions,
      backgroundColor: widget.backgroundColor ?? AppColors.primaryColor,
      foregroundColor: widget.iconColor ?? Colors.white,
      label: _isScanning
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : const AppText(
        text: 'Scan QR',
        fontSize: 14,
        color: Colors.white,
      ),
      icon: _isScanning
          ? const SizedBox()
          : const Icon(Icons.qr_code_scanner),
      tooltip: widget.tooltip,
    );
  }
}

// Optional: App Bar Scan Button Widget
class AppBarScanButton extends StatelessWidget {
  final VoidCallback? onScanComplete;

  const AppBarScanButton({
    super.key,
    this.onScanComplete,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Choose how you want to scan the QR code',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Get.to(() => const RegistrationTeamScannerScreen());
                            if (onScanComplete != null) onScanComplete!();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.camera_alt, color: AppColors.primaryColor, size: 24),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Camera Scan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Scan using camera',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            final data = await GalleryQRScannerService.scanQRFromGallery(context);
                            if (data != null) {
                              GalleryQRScannerService.showParticipantDetails(data);
                              if (onScanComplete != null) onScanComplete!();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.photo_library, color: Colors.green, size: 24),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Gallery',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Scan from gallery',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}