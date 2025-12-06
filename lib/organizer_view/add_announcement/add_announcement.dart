import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../data/request_models/announcement_model/announcement_model.dart';
import '../../view_model/organizer_viewmodels/announcement_viewmodel.dart';

class AddAnnouncementScreen extends StatefulWidget {
  final AnnouncementModel? announcement;

  const AddAnnouncementScreen({Key? key, this.announcement}) : super(key: key);

  @override
  _AddAnnouncementScreenState createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final AnnouncementViewModel viewModel = Get.find<AnnouncementViewModel>();
  late final TextEditingController titleController;
  late final TextEditingController messageController;

  final List<String> availableRoles = [
    'all',
    'participant',
    'speaker',
    'exhibitor',
    'sponsor',
    'organizer',
    'registrationteam',
  ];

  List<String> selectedRoles = ['all'];
  DateTime? scheduledDateTime;
  bool isDraft = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 AddAnnouncementScreen initialized');

    // Initialize controllers
    titleController = TextEditingController();
    messageController = TextEditingController();

    if (widget.announcement != null) {
      debugPrint('✏️ Editing announcement: ${widget.announcement!.title}');
      titleController.text = widget.announcement!.title;
      messageController.text = widget.announcement!.message;
      selectedRoles = List.from(widget.announcement!.roles);
      scheduledDateTime = widget.announcement!.scheduledAt;
      isDraft = !widget.announcement!.isSent && widget.announcement!.scheduledAt == null;

      debugPrint('   - Roles: $selectedRoles');
      debugPrint('   - Scheduled: $scheduledDateTime');
      debugPrint('   - Is Draft: $isDraft');
    } else {
      debugPrint('➕ Creating new announcement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkgrey),
          onPressed: () {
            debugPrint('⬅️ Back button pressed');
            Get.back();
          },
        ),
        title: AppText(
          text: widget.announcement != null
              ? 'Edit Announcement'
              : 'Add New Announcement',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkgrey,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            AppText(
              text: 'Title*',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
            SizedBox(height: 8),
            CustomTextField(
              controller: titleController,
              hintText: 'Enter announcement title',
            ),

            SizedBox(height: 24),

            // Message Field
            AppText(
              text: 'Message*',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: messageController,
                maxLines: 5,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkgrey,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your announcement message here...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: AppColors.lightGrey,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 24),

            // Roles Selection
            AppText(
              text: 'Audience*',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
            SizedBox(height: 8),
            AppText(
              text: 'Select roles to send announcement to:',
              fontSize: 12,
              color: AppColors.lightGrey,
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableRoles.map((role) {
                final isSelected = selectedRoles.contains(role);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (role == 'all') {
                        if (isSelected) {
                          selectedRoles.remove('all');
                        } else {
                          selectedRoles = ['all'];
                        }
                      } else {
                        if (selectedRoles.contains('all')) {
                          selectedRoles.remove('all');
                        }
                        if (isSelected) {
                          selectedRoles.remove(role);
                        } else {
                          selectedRoles.add(role);
                        }
                        if (selectedRoles.isEmpty) {
                          selectedRoles = ['all'];
                        }
                      }
                      debugPrint('👥 Selected roles updated: $selectedRoles');
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: AppText(
                      text: role[0].toUpperCase() + role.substring(1),
                      fontSize: 14,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.darkgrey,
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 24),

            // Schedule Section
            AppText(
              text: 'Schedule (Optional)',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: scheduledDateTime != null
                              ? _formatDateTime(scheduledDateTime!)
                              : 'Not scheduled',
                          fontSize: 14,
                          color: AppColors.darkgrey,
                        ),
                        if (scheduledDateTime != null)
                          AppText(
                            text: 'Will be sent automatically at this time',
                            fontSize: 12,
                            color: AppColors.lightGrey,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: AppColors.primaryColor),
                    onPressed: _pickDateTime,
                  ),
                  if (scheduledDateTime != null)
                    IconButton(
                      icon: Icon(Icons.clear, color: AppColors.errorColor),
                      onPressed: () {
                        setState(() {
                          scheduledDateTime = null;
                          debugPrint('📅 Schedule cleared');
                        });
                      },
                    ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Draft Checkbox
            Row(
              children: [
                Checkbox(
                  value: isDraft,
                  onChanged: (value) {
                    setState(() {
                      isDraft = value ?? false;
                      if (isDraft) {
                        scheduledDateTime = null;
                      }
                      debugPrint('📝 Draft mode: $isDraft');
                    });
                  },
                  activeColor: AppColors.primaryColor,
                ),
                Expanded(
                  child: AppText(
                    text: 'Save as draft (don\'t send yet)',
                    fontSize: 14,
                    color: AppColors.darkgrey,
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),

            // Action Buttons with loading states
            Obx(() {
              final isLoading = viewModel.isSending.value;

              if (widget.announcement != null && !widget.announcement!.isSent) {
                return Column(
                  children: [
                    // Send Now Button with loader
                    CustomButton(
                      text: 'Send Now',
                      onPressed: () => _handleSendNow(),
                      backgroundColor: AppColors.primaryColor,
                      isLoading: isLoading,
                    ),
                    SizedBox(height: 12),

                    // Save as Draft/Schedule Button with loader
                    CustomButton(
                      text: scheduledDateTime != null
                          ? 'Save & Schedule'
                          : 'Save as Draft',
                      onPressed: () => _handleSaveOrSchedule(),
                      backgroundColor: AppColors.lightGreyColor,
                      textColor: AppColors.darkgrey,
                      borderColor: AppColors.primaryColor,
                      isLoading: isLoading,
                    ),
                  ],
                );
              } else {
                // For new announcements
                return CustomButton(
                  text: isDraft
                      ? 'Save as Draft'
                      : scheduledDateTime != null
                      ? 'Schedule Announcement'
                      : 'Send Now',
                  onPressed: () => _handleCreate(),
                  backgroundColor: AppColors.primaryColor,
                  isLoading: isLoading,
                );
              }
            }),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month $day, $dateTime.year at $hour:$minute';
  }

  Future<void> _pickDateTime() async {
    debugPrint('📅 Opening date picker...');
    final date = await showDatePicker(
      context: context,
      initialDate: scheduledDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (date != null) {
      debugPrint('📅 Date selected: $date');
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(scheduledDateTime ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          scheduledDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          isDraft = false;
          debugPrint('⏰ Schedule set to: $scheduledDateTime');
        });
      }
    }
  }

  // Handle Send Now for editing
  Future<void> _handleSendNow() async {
    debugPrint('🚀 Handle Send Now triggered');
    if (!_validateForm()) return;
    if (widget.announcement?.id == null) return;

    final announcement = AnnouncementModel(
      id: widget.announcement!.id,
      title: titleController.text.trim(),
      message: messageController.text.trim(),
      roles: selectedRoles,
      scheduledAt: null,
      isSent: true,
    );

    debugPrint('📤 Sending announcement now...');
    final success = await viewModel.updateAnnouncement(widget.announcement!.id!, announcement);
    if (success) {
      _clearFields();
      Get.back();
    }
  }

  // Handle Save as Draft or Schedule for editing
  Future<void> _handleSaveOrSchedule() async {
    debugPrint('💾 Handle Save/Schedule triggered');
    if (!_validateForm()) return;
    if (widget.announcement?.id == null) return;

    final announcement = AnnouncementModel(
      id: widget.announcement!.id,
      title: titleController.text.trim(),
      message: messageController.text.trim(),
      roles: selectedRoles,
      scheduledAt: scheduledDateTime,
      isSent: false,
    );

    if (scheduledDateTime != null) {
      debugPrint('📅 Scheduling announcement for: $scheduledDateTime');
    } else {
      debugPrint('📝 Saving as draft');
    }

    final success = await viewModel.updateAnnouncement(widget.announcement!.id!, announcement);
    if (success) {
      _clearFields();
      Get.back();
    }
  }

  // Handle Create for new announcements
  Future<void> _handleCreate() async {
    debugPrint('✨ Handle Create triggered');
    if (!_validateForm()) return;

    final announcement = AnnouncementModel(
      title: titleController.text.trim(),
      message: messageController.text.trim(),
      roles: selectedRoles,
      scheduledAt: scheduledDateTime,
      isSent: !isDraft && scheduledDateTime == null,
    );

    if (isDraft) {
      debugPrint('📝 Creating as draft');
    } else if (scheduledDateTime != null) {
      debugPrint('📅 Creating with schedule: $scheduledDateTime');
    } else {
      debugPrint('🚀 Creating and sending now');
    }

    final success = await viewModel.createAnnouncement(announcement);
    if (success) {
      _clearFields();
      Get.back();
    }
  }

  bool _validateForm() {
    debugPrint('✅ Validating form...');

    if (titleController.text.trim().isEmpty) {
      debugPrint('❌ Validation failed: Title is empty');
      Get.snackbar(
        'Error',
        'Please enter a title',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor.withOpacity(0.1),
        colorText: AppColors.errorColor,
      );
      return false;
    }

    if (messageController.text.trim().isEmpty) {
      debugPrint('❌ Validation failed: Message is empty');
      Get.snackbar(
        'Error',
        'Please enter a message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor.withOpacity(0.1),
        colorText: AppColors.errorColor,
      );
      return false;
    }

    if (selectedRoles.isEmpty) {
      debugPrint('❌ Validation failed: No roles selected');
      Get.snackbar(
        'Error',
        'Please select at least one audience role',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor.withOpacity(0.1),
        colorText: AppColors.errorColor,
      );
      return false;
    }

    debugPrint('✅ Form validation passed');
    return true;
  }

  void _clearFields() {
    debugPrint('🧹 Clearing form fields');
    titleController.clear();
    messageController.clear();
    setState(() {
      selectedRoles = ['all'];
      scheduledDateTime = null;
      isDraft = false;
    });
  }

  @override
  void dispose() {
    debugPrint('🗑️ Disposing AddAnnouncementScreen controllers');
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }
}