import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _generateQR();
  }

  void _generateQR() {
    // Generate QR data with ONLY 5 FIELDS
    final simplifiedData = {
      "name": widget.participant.name,
      "email": widget.participant.email,
      "role": widget.participant.role,
      "file": widget.participant.file ?? "",
      "bio": widget.participant.bio ?? "",
    };

    _qrData = jsonEncode(simplifiedData);
    _parsedData = simplifiedData;
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

              // Copy Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Copy QR data to clipboard
                    Get.snackbar(
                      'Copied',
                      'QR code data copied to clipboard',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.content_copy, size: 18),
                  label: const AppText(
                    text: 'Copy QR Data',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
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

        // User Info - Column to prevent overflow
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
          Container(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Profile Image', 'Available', isLink: true),
                const SizedBox(height: 8),
              ],
            ),

          // User ID
          _buildInfoRow('User ID', widget.participant.id.toString()),
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