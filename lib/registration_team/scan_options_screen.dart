import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/qr_code/gallery_qr_scanner_service.dart';

import '../qr_code/universal_qr_code_scan.dart';
import 'event_registration_scan_screen.dart';

class ScanOptionsScreen extends StatelessWidget {
  const ScanOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          text: 'Scan Options',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header
            const AppText(
              text: 'Select Scan Type',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            const AppText(
              text: 'Choose how you want to scan QR codes',
              fontSize: 14,
              color: Colors.grey,
            ),

            const SizedBox(height: 32),

            // Scan Options Grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildScanOptionCard(
                  icon: Icons.qr_code_scanner,
                  title: 'Universal Scan',
                  subtitle: 'Scan any participant QR',
                  color: AppColors.primaryColor,
                  onTap: () => Get.to(() => const UniversalQRScannerScreen()),
                ),

                _buildScanOptionCard(
                  icon: Icons.event_available,
                  title: 'Event Registration',
                  subtitle: 'Check event registration',
                  color: Colors.blue,
                  onTap: () => Get.to(() => const EventRegistrationScanScreen()),
                ),

                _buildScanOptionCard(
                  icon: Icons.camera_alt,
                  title: 'Camera Scan',
                  subtitle: 'Scan using camera',
                  color: Colors.green,
                  onTap: () => Get.to(() => const UniversalQRScannerScreen()),
                ),

                _buildScanOptionCard(
                  icon: Icons.photo_library,
                  title: 'Gallery Scan',
                  subtitle: 'Scan from gallery',
                  color: Colors.purple,
                  onTap: () async {
                    final data = await GalleryQRScannerService.scanQRFromGallery(context);
                    if (data != null) {
                      GalleryQRScannerService.showParticipantDetails(data);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Quick Actions
            const AppText(
              text: 'Quick Actions',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildQuickActionRow(
                    icon: Icons.history,
                    title: 'Scan History',
                    onTap: () {
                      // TODO: Navigate to scan history
                      Get.snackbar(
                        'Coming Soon',
                        'Scan history feature will be available soon',
                        backgroundColor: Colors.blue,
                      );
                    },
                  ),
                  const Divider(height: 20),
                  _buildQuickActionRow(
                    icon: Icons.settings,
                    title: 'Scan Settings',
                    onTap: () {
                      // TODO: Navigate to scan settings
                      Get.snackbar(
                        'Coming Soon',
                        'Scan settings will be available soon',
                        backgroundColor: Colors.blue,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 12),
            AppText(
              text: title,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            AppText(
              text: subtitle,
              fontSize: 11,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              text: title,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}