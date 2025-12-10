// qr_pass_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_drawer.dart';
import '../../utils/shared_preference.dart';
import '../../view_model/participant_viewmodel/participant_profile/participant_profile_get_viewmodel.dart';
import '../../view_model/speaker_viewmodels/speaker_profile_show_on_dashboard_viewmodel.dart';


class QRPassScreen extends StatefulWidget {
  const QRPassScreen({super.key});

  @override
  State<QRPassScreen> createState() => _QRPassScreenState();
}

class _QRPassScreenState extends State<QRPassScreen> {
  bool _isRefreshing = false;
  String? _qrData;
  Map<String, dynamic>? _displayData;

  final ParticipantProfileGetViewModel _participantVM = Get.put(ParticipantProfileGetViewModel());
  final SpeakerProfileShowOnDashboardViewModel _speakerVM = Get.put(SpeakerProfileShowOnDashboardViewModel());

  late String _role;
  late int _userId;
  String? _speakerId;

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndId().then((_) => _loadProfile());
  }

  Future<void> _loadUserRoleAndId() async {
    final role = await SharedPrefsHelper.getUserRole() ?? 'participant';
    final userId = await SharedPrefsHelper.getUserId() ?? 20;
    final speakerId = await SharedPrefsHelper.getSpeakerId();

    setState(() {
      _role = role.toLowerCase();
      _userId = userId;
      _speakerId = speakerId?.toString();
    });
  }

  Future<void> _loadProfile() async {
    if (_role == 'participant') {
      await _participantVM.fetchProfile();
      if (_participantVM.profile != null) _buildQrAndDisplay(_participantVM.profile!);
    } else if (_role == 'speaker') {
      final speakerId = int.tryParse(_speakerId ?? '') ?? 0;
      if (speakerId == 0) return;
      await _speakerVM.fetchSpeakerProfile(speakerId);
      if (_speakerVM.speakerProfile != null) _buildQrAndDisplay(_speakerVM.speakerProfile!);
    }
  }

  void _buildQrAndDisplay(dynamic profile) {
    // Build complete user data for QR code
    Map<String, dynamic> qrPayload = {
      "userId": _userId,
      "role": _role,
      "badge": "AS2025-$_userId",
    };

    Map<String, dynamic> displayData = {
      "badge": "AS2025-$_userId",
      "role": _role,
    };

    if (_role == 'speaker') {
      // Speaker data
      qrPayload.addAll({
        "name": profile.user.name,
        "email": profile.user.email,
        "phone": profile.user.phone ?? '',
        "photo": profile.user.file ?? '',
        "organization": profile.country,
        "bio": profile.bio,
        "expertise": profile.expertise.join(', '),
        "designations": profile.designations.join(', '),
        "website": profile.website ?? '',
        "linkedin": profile.linkedin ?? '',
        "twitter": profile.twitter ?? '',
        "facebook": profile.facebook ?? '',
        "youtube": profile.youtube ?? '',
      });

      displayData.addAll({
        "name": profile.user.name,
        "email": profile.user.email,
        "phone": profile.user.phone ?? '',
        "photo": profile.user.file ?? '',
        "organization": profile.country,
        "bio": profile.bio,
        "expertise": profile.expertise.join(', '),
        "designations": profile.designations.join(', '),
        "website": profile.website ?? '',
        "linkedin": profile.linkedin ?? '',
        "twitter": profile.twitter ?? '',
        "facebook": profile.facebook ?? '',
        "youtube": profile.youtube ?? '',
      });
    } else {
      // Participant data
      qrPayload.addAll({
        "name": profile.name,
        "email": profile.email,
        "phone": profile.phone ?? '',
        "photo": profile.photo ?? profile.file ?? '',
        "organization": profile.organization,
      });

      displayData.addAll({
        "name": profile.name,
        "email": profile.email,
        "phone": profile.phone ?? '',
        "photo": profile.photo ?? profile.file ?? '',
        "organization": profile.organization,
      });
    }

    setState(() {
      _qrData = jsonEncode(qrPayload);
      _displayData = displayData;
    });
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await _loadProfile();
    setState(() => _isRefreshing = false);
    Get.snackbar('Success', 'QR refreshed', backgroundColor: Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      drawer: const CustomAppDrawer(),
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: const AppText(text: 'My QR Pass', fontSize: 18, fontWeight: FontWeight.w600),
        centerTitle: true,
      ),
      body: _qrData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // QR Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(_displayData?['photo'] ?? 'https://via.placeholder.com/150'),
                  ),
                  const SizedBox(height: 16),
                  AppText(text: _displayData?['name'] ?? '', fontSize: 20, fontWeight: FontWeight.w600),
                  const SizedBox(height: 4),
                  AppText(text: _displayData?['organization'] ?? '', fontSize: 16, color: AppColors.darkgrey),
                  const SizedBox(height: 4),
                  AppText(text: (_displayData?['role'] ?? '').toString().toUpperCase(), fontSize: 14, color: AppColors.darkgrey),
                  if (_role == 'speaker') ...[
                    const SizedBox(height: 8),
                    AppText(text: 'Expertise: ${_displayData?['expertise'] ?? ''}', fontSize: 13, color: AppColors.darkgrey),
                  ],
                  const SizedBox(height: 24),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.mediumGreyColor),
                    ),
                    child: _isRefreshing
                        ? const CircularProgressIndicator()
                        : QrImageView(
                      data: _qrData!,
                      size: isTablet ? 220 : 180,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AppText(text: 'Show this QR code at check-in', fontSize: 14, color: AppColors.darkgrey),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Column(
                children: [
                  _row('Badge ID', _displayData?['badge'] ?? ''),
                  const Divider(),
                  _row('Role', _displayData?['role']?.toString().toUpperCase() ?? ''),
                  const Divider(),
                  _row('Organization / Country', _displayData?['organization'] ?? ''),
                  if (_role == 'speaker') ...[
                    const Divider(),
                    _row('Bio', _displayData?['bio'] ?? ''),
                    if ((_displayData?['linkedin'] ?? '').isNotEmpty) ...[
                      const Divider(),
                      _row('LinkedIn', _displayData?['linkedin'] ?? ''),
                    ],
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),
            CustomButton(text: 'Refresh QR', onPressed: _refresh, isLoading: _isRefreshing),
            const SizedBox(height: 12),
            CustomButton(text: 'Download QR', onPressed: () {/* add screenshot logic later */}, backgroundColor: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: AppText(text: label, fontSize: 14, color: AppColors.darkgrey),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: AppText(
            text: value,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}