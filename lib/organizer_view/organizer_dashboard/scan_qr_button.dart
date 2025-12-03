import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';

import '../../qr_code/gallery_qr_scanner_service.dart';
import '../../qr_code/registration_team_scanner_screen.dart';


class ScanQRButton extends StatefulWidget {
  final Widget? child;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final EdgeInsets? padding;
  final VoidCallback? onScanComplete;
  final VoidCallback? onScanStart;
  final bool showLoading;
  final bool enabled;

  const ScanQRButton({
    super.key,
    this.child,
    this.tooltip = 'Scan QR Code',
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
    this.padding,
    this.onScanComplete,
    this.onScanStart,
    this.showLoading = true,
    this.enabled = true,
  });

  const ScanQRButton.icon({
    super.key,
    this.child,
    this.tooltip = 'Scan QR Code',
    this.backgroundColor = Colors.transparent,
    this.iconColor = Colors.black87,
    this.iconSize = 24,
    this.padding,
    this.onScanComplete,
    this.onScanStart,
    this.showLoading = true,
    this.enabled = true,
  });

  const ScanQRButton.fab({
    super.key,
    this.child,
    this.tooltip = 'Scan QR Code',
    this.backgroundColor = AppColors.primaryColor,
    this.iconColor = Colors.white,
    this.iconSize = 24,
    this.padding,
    this.onScanComplete,
    this.onScanStart,
    this.showLoading = true,
    this.enabled = true,
  });

  @override
  State<ScanQRButton> createState() => _ScanQRButtonState();
}

class _ScanQRButtonState extends State<ScanQRButton> {
  bool _isScanning = false;

  // Make this method public
  void showScanOptions() {
    if (!widget.enabled || _isScanning) return;

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
    if (widget.onScanStart != null) widget.onScanStart!();

    try {
      await Get.to(() => const RegistrationTeamScannerScreen());
      if (widget.onScanComplete != null) {
        widget.onScanComplete!();
      }
    } catch (e) {
      print('Camera scan error: $e');
      Get.snackbar(
        'Error',
        'Failed to start camera scan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _startGalleryScan() async {
    if (_isScanning) return;

    setState(() => _isScanning = true);
    if (widget.onScanStart != null) widget.onScanStart!();

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
    if (widget.child != null) {
      return GestureDetector(
        onTap: showScanOptions,
        child: widget.child,
      );
    }

    if (widget.padding != null) {
      return Padding(
        padding: widget.padding!,
        child: _buildIconButton(),
      );
    }

    return _buildIconButton();
  }

  Widget _buildIconButton() {
    return IconButton(
      icon: _isScanning && widget.showLoading
          ? SizedBox(
        width: widget.iconSize ?? 24,
        height: widget.iconSize ?? 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.iconColor ?? Colors.black87,
        ),
      )
          : Icon(
        Icons.qr_code_scanner,
        size: widget.iconSize ?? 24,
        color: widget.iconColor ?? Colors.black87,
      ),
      onPressed: showScanOptions,
      tooltip: widget.tooltip,
      color: widget.backgroundColor,
    );
  }
}

// Extension for easy usage
extension ScanQRButtonExtensions on ScanQRButton {
  static Widget appBarIcon({
    Key? key,
    Color iconColor = Colors.black87,
    double iconSize = 24,
    VoidCallback? onScanComplete,
    VoidCallback? onScanStart,
    bool showLoading = true,
    bool enabled = true,
  }) {
    return ScanQRButton.icon(
      key: key,
      iconColor: iconColor,
      iconSize: iconSize,
      onScanComplete: onScanComplete,
      onScanStart: onScanStart,
      showLoading: showLoading,
      enabled: enabled,
    );
  }

  static Widget floatingActionButton({
    Key? key,
    Color backgroundColor = AppColors.primaryColor,
    Color iconColor = Colors.white,
    String? label,
    VoidCallback? onScanComplete,
    VoidCallback? onScanStart,
    bool showLoading = true,
    bool enabled = true,
  }) {
    return FloatingActionButton.extended(
      key: key,
      onPressed: () {
        final context = Get.context!;
        _showScanOptionsDialog(context, onScanComplete, onScanStart);
      },
      backgroundColor: backgroundColor,
      foregroundColor: iconColor,
      icon: const Icon(Icons.qr_code_scanner),
      label: label != null ? Text(label) : const Text('Scan QR'),
    );
  }
}

// Helper function for FAB
void _showScanOptionsDialog(
    BuildContext context,
    VoidCallback? onScanComplete,
    VoidCallback? onScanStart,
    ) {
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
                  child: _buildScanOptionWidget(
                    icon: Icons.camera_alt,
                    title: 'Camera Scan',
                    subtitle: 'Scan using camera',
                    color: AppColors.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      _startCameraScanDialog(context, onScanComplete, onScanStart);
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildScanOptionWidget(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    subtitle: 'Scan from gallery',
                    color: Colors.green,
                    onTap: () async {
                      Navigator.pop(context);
                      await _startGalleryScanDialog(context, onScanComplete, onScanStart);
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

Widget _buildScanOptionWidget({
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

Future<void> _startCameraScanDialog(
    BuildContext context,
    VoidCallback? onScanComplete,
    VoidCallback? onScanStart,
    ) async {
  if (onScanStart != null) onScanStart();

  try {
    await Get.to(() => const RegistrationTeamScannerScreen());
    if (onScanComplete != null) {
      onScanComplete();
    }
  } catch (e) {
    print('Camera scan error: $e');
    Get.snackbar(
      'Error',
      'Failed to start camera scan',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}

Future<void> _startGalleryScanDialog(
    BuildContext context,
    VoidCallback? onScanComplete,
    VoidCallback? onScanStart,
    ) async {
  if (onScanStart != null) onScanStart();

  try {
    final data = await GalleryQRScannerService.scanQRFromGallery(context);
    if (data != null) {
      GalleryQRScannerService.showParticipantDetails(data);
      if (onScanComplete != null) {
        onScanComplete();
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
  }
}


//import 'package:al_sharq_conference/custom_widgets/scan_qr_button.dart';
//
// // In your AppBar:
// appBar: AppBar(
//   // ... other properties ...
//   actions: [
//     ScanQRButton(
//       onScanComplete: () {
//         _viewModel.refreshData(); // Optional: refresh after scan
//       },
//     ),
//   ],
// ),
//
// // For Floating Action Button:
// floatingActionButton: ScanQRButton.fab(
//   onScanComplete: () {
//     _viewModel.refreshData(); // Optional: refresh after scan
//   },
// ),