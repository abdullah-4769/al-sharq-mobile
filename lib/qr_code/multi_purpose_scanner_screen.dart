import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/qr_code/qr_generator_service.dart';

import 'package:al_sharq_conference/view_model/registration_team_viewmodels/session_check_viewmodel.dart';

import '../data/response_models/registration_team_model/event_registration_check_model.dart';
import '../utils/shared_preference.dart';
import '../view_model/registration_team_viewmodels/event_registration_viewmodel.dart';

class MultiPurposeScannerScreen extends StatefulWidget {
  final ScanMode scanMode;
  final int? sessionId;
  final String? sessionTitle;
  final String? eventId;
  final String? eventTitle;

  const MultiPurposeScannerScreen({
    super.key,
    required this.scanMode,
    this.sessionId,
    this.sessionTitle,
    this.eventId,
    this.eventTitle,
  });

  @override
  State<MultiPurposeScannerScreen> createState() => _MultiPurposeScannerScreenState();
}

enum ScanMode {
  profile,
  eventRegistration,
  sessionRegistration,
}

class _MultiPurposeScannerScreenState extends State<MultiPurposeScannerScreen> {
  late MobileScannerController cameraController;
  bool isScanned = false;
  String? lastScannedCode;
  DateTime? lastScanTime;
  Map<String, dynamic>? scannedData;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;

  final EventRegistrationViewModel _eventRegistrationViewModel = Get.put(EventRegistrationViewModel());
  final SessionCheckViewModel _sessionCheckViewModel = Get.put(SessionCheckViewModel());

  // If event ID is not provided, try to get from SharedPreferences
  String? _effectiveEventId;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );

    _initializeEventId();
  }

  Future<void> _initializeEventId() async {
    if (widget.scanMode == ScanMode.eventRegistration && (widget.eventId == null || widget.eventId!.isEmpty)) {
      final eventId = await SharedPrefsHelper.getLatestEventId();
      if (eventId != null) {
        setState(() {
          _effectiveEventId = eventId.toString();
        });
      }
    } else {
      _effectiveEventId = widget.eventId;
    }
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
        switch (widget.scanMode) {
          case ScanMode.profile:
            _showParticipantProfile();
            break;
          case ScanMode.eventRegistration:
            await _checkEventRegistration();
            break;
          case ScanMode.sessionRegistration:
            await _checkSessionRegistration();
            break;
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

  void _showParticipantProfile() {
    final participantName = scannedData?['name']?.toString() ?? 'Unknown';
    final participantEmail = scannedData?['email']?.toString() ?? 'No email';
    final participantRole = scannedData?['role']?.toString() ?? 'participant';
    final participantPhoto = scannedData?['file']?.toString();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Participant Profile'),
        content: SingleChildScrollView(
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
                  child: participantPhoto != null && participantPhoto.isNotEmpty
                      ? Image.network(
                    participantPhoto,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // Email
              Text(
                participantEmail,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 8),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  participantRole.toUpperCase(),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('User ID', QRGeneratorService.extractUserId(scannedData)?.toString() ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Email', participantEmail),
                    const SizedBox(height: 8),
                    _buildDetailRow('Role', participantRole),
                    if (scannedData?['organization'] != null) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow('Organization', scannedData!['organization'].toString()),
                    ],
                    if (scannedData?['bio'] != null && scannedData!['bio'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow('Bio', scannedData!['bio'].toString()),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Scan Info
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Profile verified via QR scan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
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

  Future<void> _checkEventRegistration() async {
    final userId = QRGeneratorService.extractUserId(scannedData);

    if (userId == null) {
      _showErrorDialog('User ID not found in QR code');
      return;
    }

    if (_effectiveEventId == null || _effectiveEventId!.isEmpty) {
      _showEventIdInputDialog();
      return;
    }

    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await _eventRegistrationViewModel.checkRegistrationRequirement(
        _effectiveEventId!,
        userId.toString(),
      );
      Get.back();
      _showEventRegistrationResult();
    } catch (e) {
      Get.back();
      _showErrorDialog('Error checking event registration: $e');
    }
  }

  Future<void> _checkSessionRegistration() async {
    final userId = QRGeneratorService.extractUserId(scannedData);

    if (userId == null) {
      _showErrorDialog('User ID not found in QR code');
      return;
    }

    if (widget.sessionId == null) {
      _showErrorDialog('Session ID is required for session registration check');
      return;
    }

    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final result = await _sessionCheckViewModel.checkSessionRegistration(
        sessionId: widget.sessionId!,
        userId: userId,
        context: context,
      );
      Get.back();
      _showSessionRegistrationResult(result);
    } catch (e) {
      Get.back();
      _showErrorDialog('Error checking session registration: $e');
    }
  }

  void _showEventRegistrationResult() {
    final result = _eventRegistrationViewModel.registrationCheck;
    if (result == null) return;

    final participantName = scannedData?['name']?.toString() ?? 'Unknown';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(
              result.isRegistered ? Icons.check_circle :
              result.required ? Icons.warning : Icons.info,
              size: 50,
              color: result.isRegistered ? Colors.green :
              result.required ? Colors.orange : Colors.blue,
            ),
            const SizedBox(height: 8),
            Text(
              result.isRegistered ? 'Event Registered' :
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
        content: _buildEventResultContent(result, participantName),
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

  Widget _buildEventResultContent(EventRegistrationCheckModel result, String participantName) {
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
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participantName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Event ID: $_effectiveEventId',
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
                  'Event ID: $_effectiveEventId',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (widget.eventTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Event: ${widget.eventTitle}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionRegistrationResult(Map<String, dynamic> result) {
    final isRegistered = result['isRegistered'] ?? false;
    final participantName = scannedData?['name']?.toString() ?? 'Unknown';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(
              isRegistered ? Icons.check_circle : Icons.warning,
              size: 50,
              color: isRegistered ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 8),
            Text(
              isRegistered ? 'Session Registered' : 'Not Registered',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isRegistered ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        content: _buildSessionResultContent(result, participantName),
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

  Widget _buildSessionResultContent(Map<String, dynamic> result, String participantName) {
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
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participantName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Session ID: ${widget.sessionId}',
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
          ),

          const SizedBox(height: 16),

          // Registration Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (result['isRegistered'] ?? false) ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (result['isRegistered'] ?? false) ? Colors.green : Colors.orange,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      (result['isRegistered'] ?? false) ? Icons.check_circle : Icons.warning,
                      color: (result['isRegistered'] ?? false) ? Colors.green : Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result['message'] ?? 'Unknown status',
                        style: TextStyle(
                          fontSize: 14,
                          color: (result['isRegistered'] ?? false) ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Session: ${widget.sessionTitle ?? 'Session'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (widget.sessionId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Session ID: ${widget.sessionId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: value == 'N/A' ? Colors.red : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showEventIdInputDialog() {
    final TextEditingController eventIdController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Enter Event ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Event ID is required to check registration.'),
            const SizedBox(height: 16),
            TextField(
              controller: eventIdController,
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
              final eventId = eventIdController.text.trim();
              if (eventId.isNotEmpty) {
                setState(() {
                  _effectiveEventId = eventId;
                });
                // Save to SharedPreferences
                SharedPrefsHelper.saveLatestEventId(eventId);
                Get.back();
                // Retry the check
                _checkEventRegistration();
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter a valid Event ID',
                  backgroundColor: Colors.red,
                );
              }
            },
            child: const Text('Save & Continue'),
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

  String _getScanModeTitle() {
    switch (widget.scanMode) {
      case ScanMode.profile:
        return 'Scan Profile';
      case ScanMode.eventRegistration:
        return 'Check Event Registration';
      case ScanMode.sessionRegistration:
        return 'Check Session Registration';
    }
  }

  String _getScanModeSubtitle() {
    switch (widget.scanMode) {
      case ScanMode.profile:
        return 'Scan participant QR code to view profile';
      case ScanMode.eventRegistration:
        return 'Scan QR to check event registration status';
      case ScanMode.sessionRegistration:
        return 'Scan QR to check session registration status';
    }
  }

  Color _getScanModeColor() {
    switch (widget.scanMode) {
      case ScanMode.profile:
        return Colors.blue;
      case ScanMode.eventRegistration:
        return Colors.purple;
      case ScanMode.sessionRegistration:
        return Colors.orange;
    }
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getScanModeTitle(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              _getScanModeSubtitle(),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
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
                borderColor: _getScanModeColor(),
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 5,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),

          // Info Panel
          if (widget.scanMode == ScanMode.eventRegistration && _effectiveEventId != null)
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
                  border: Border.all(color: _getScanModeColor()),
                ),
                child: Column(
                  children: [
                    Text(
                      'Event ID: $_effectiveEventId',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.eventTitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.eventTitle!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          if (widget.scanMode == ScanMode.sessionRegistration && widget.sessionId != null)
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
                  border: Border.all(color: _getScanModeColor()),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.sessionTitle ?? 'Session',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
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

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    _getScanModeTitle(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getScanModeSubtitle(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getScanModeColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getScanModeColor()),
                    ),
                    child: Text(
                      _getScanModeTitle(),
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