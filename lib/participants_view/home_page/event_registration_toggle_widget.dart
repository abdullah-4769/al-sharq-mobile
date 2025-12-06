import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../utils/shared_preference.dart';
import '../../view_model/participant_viewmodel/event_registration_toggle_status_viewmodel.dart';
import '../../view_model/participant_viewmodel/event_registration_toggle_viewmodel.dart';

class EventRegistrationToggleWidget extends StatefulWidget {
  final int? eventId;
  final int? userId;

  const EventRegistrationToggleWidget({
    Key? key,
    this.eventId,
    this.userId,
  }) : super(key: key);

  @override
  _EventRegistrationToggleWidgetState createState() => _EventRegistrationToggleWidgetState();
}

class _EventRegistrationToggleWidgetState extends State<EventRegistrationToggleWidget> {
  late EventRegistrationToggleViewModel _toggleViewModel;
  late EventRegistrationToggleStatusViewModel _statusViewModel;

  int? _eventId;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _toggleViewModel = Get.put(EventRegistrationToggleViewModel());
    _statusViewModel = Get.put(EventRegistrationToggleStatusViewModel());

    // Initialize IDs
    _initializeIds();
  }

  Future<void> _initializeIds() async {
    // Get event ID from widget or shared preferences
    _eventId = widget.eventId ?? await SharedPrefsHelper.getLatestEventId();

    // Get user ID from widget or shared preferences
    _userId = widget.userId ?? await SharedPrefsHelper.getUserId();

    if (_eventId != null && _userId != null) {
      // Fetch initial registration status
      await _statusViewModel.fetchRegistrationStatus(
        eventId: _eventId!,
        userId: _userId!,
      );

      // Update toggle viewmodel with current status
      _toggleViewModel.setRegistrationStatus(_statusViewModel.isRegistered);
    }
  }

  Future<void> _handleToggle(bool value) async {
    if (_eventId == null || _userId == null) {
      Get.snackbar(
        'Error',
        'User ID or Event ID not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Update the toggle
    await _toggleViewModel.toggleRegistration(
      eventId: _eventId!,
      userId: _userId!,
    );

    // Refresh the status after toggle
    await _statusViewModel.fetchRegistrationStatus(
      eventId: _eventId!,
      userId: _userId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EventRegistrationToggleStatusViewModel>(
      builder: (statusController) {
        return Obx(
              () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.event_available,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: 'Event Registration',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        text: _toggleViewModel.isRegistered
                            ? 'You are registered for this event'
                            : 'You are not registered for this event',
                        fontSize: 11,
                        color: AppColors.darkgrey,
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: _toggleViewModel.isRegistered,
                        onChanged: (_toggleViewModel.isLoading || statusController.isLoading)
                            ? null // Disable switch when loading
                            : _handleToggle,
                        activeColor: AppColors.primaryColor,
                        activeTrackColor: AppColors.primaryColor.withOpacity(0.4),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    // Show loading indicator on top of switch when loading
                    if (_toggleViewModel.isLoading || statusController.isLoading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Remove viewmodels if they're only used in this widget
    Get.delete<EventRegistrationToggleViewModel>();
    Get.delete<EventRegistrationToggleStatusViewModel>();
    super.dispose();
  }
}