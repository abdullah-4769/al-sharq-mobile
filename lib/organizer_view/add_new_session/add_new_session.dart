import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';

import '../../data/response_models/organizer_response_models/organizer_all_speaker_get_model.dart';
import '../../data/response_models/organizer_response_models/organizer_event_id_get_model.dart';
import '../../view_model/organizer_viewmodels/organizer_event_id_get_viewmodel.dart';
import '../../view_model/organizer_viewmodels/organizer_all_speaker_get_viewmodel.dart';
import '../../view_model/organizer_viewmodels/organizer_create_session_viewmodel.dart';
import '../../view_model/organizer_viewmodels/organizer_update_session_viewmodel.dart';
import '../../view_model/organizer_viewmodels/organizer_session_details_get_viewmodel.dart';

class AddNewSessionScreen extends StatefulWidget {
  final int? sessionId; // Added for edit mode
  final bool isEditMode;

  const AddNewSessionScreen({super.key, this.sessionId, this.isEditMode = false});

  @override
  State<AddNewSessionScreen> createState() => _AddNewSessionScreenState();
}

class _AddNewSessionScreenState extends State<AddNewSessionScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final OrganizerEventIdGetViewModel _eventsViewModel = Get.put(OrganizerEventIdGetViewModel());
  final OrganizerAllSpeakerGetViewModel _speakersViewModel = Get.put(OrganizerAllSpeakerGetViewModel());
  final OrganizerCreateSessionViewModel _createViewModel = Get.put(OrganizerCreateSessionViewModel());
  final OrganizerUpdateSessionViewModel _updateViewModel = Get.put(OrganizerUpdateSessionViewModel());
  final OrganizerSessionDetailsGetViewModel _sessionDetailsViewModel = Get.put(OrganizerSessionDetailsGetViewModel());

  OrganizerEventIdGetModel? selectedEvent;
  List<OrganizerAllSpeakerGetModel> selectedSpeakers = [];
  List<String> tags = [];

  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String selectedCategory = 'Workshop';
  bool registrationRequired = false;

  final List<String> categories = [
    'Workshop',
    'Keynote',
    'Panel',
    'Presentation',
    'Networking',
    'Breakout Session'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.isEditMode && widget.sessionId != null) {
      _loadSessionData();
    }
  }

  void _loadData() {
    _eventsViewModel.getEventsShortInfo();
    _speakersViewModel.getAllSpeakers();
  }

  void _loadSessionData() {
    _sessionDetailsViewModel.getSessionDetails(widget.sessionId!).then((_) {
      final session = _sessionDetailsViewModel.sessionDetails.value;

      // Populate form with existing data
      titleController.text = session.title;
      descriptionController.text = session.description;
      locationController.text = session.location;
      capacityController.text = session.capacity.toString();
      selectedCategory = session.category;
      registrationRequired = session.registrationRequired;
      tags = List.from(session.tags);

      // Parse and set date/time
      _parseDateTime(session.startTime, true);
      _parseDateTime(session.endTime, false);

      // Set selected event
      if (_eventsViewModel.eventsList.isNotEmpty) {
        selectedEvent = _eventsViewModel.eventsList.firstWhere(
              (event) => event.eventId == session.eventId,
          orElse: () => _eventsViewModel.eventsList.first,
        );
      }

      // Set selected speakers
      _setSelectedSpeakers(session.speakers);

      setState(() {});
    });
  }

  void _parseDateTime(String dateTimeString, bool isStart) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      if (isStart) {
        startDate = dateTime;
        startTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      } else {
        endDate = dateTime;
        endTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      }
    } catch (e) {
      print('Error parsing date time: $e');
    }
  }

  void _setSelectedSpeakers(List speakers) {
    selectedSpeakers.clear();
    for (var speaker in speakers) {
      final speakerId = speaker['id'];
      final matchingSpeaker = _speakersViewModel.speakersList.firstWhere(
            (s) => s.speakerId == speakerId,
        orElse: () => _speakersViewModel.speakersList.firstWhere(
              (s) => s.user.id == speaker['user']['id'],
          orElse: () => OrganizerAllSpeakerGetModel(
            speakerId: speakerId,
            designations: [],
            user: OrganizerSpeakerUser(
              id: speaker['user']['id'],
              name: speaker['user']['name'],
              email: speaker['user']['email'],
              file: speaker['user']['file'],
            ),
          ),
        ),
      );
      selectedSpeakers.add(matchingSpeaker);
    }
  }

  Future<void> _selectStartDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: startTime ?? TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          startDate = pickedDate;
          startTime = pickedTime;
        });
      }
    }
  }

  Future<void> _selectEndDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? (startDate ?? DateTime.now()),
      firstDate: startDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: endTime ?? TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          endDate = pickedDate;
          endTime = pickedTime;
        });
      }
    }
  }

  void _addTag() {
    final tag = tagController.text.trim();
    if (tag.isNotEmpty && !tags.contains(tag)) {
      setState(() {
        tags.add(tag);
        tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  String get _formattedStartDateTime {
    if (startDate == null || startTime == null) return 'Select start date & time';
    final dateTime = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      startTime!.hour,
      startTime!.minute,
    );
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }

  String get _formattedEndDateTime {
    if (endDate == null || endTime == null) return 'Select end date & time';
    final dateTime = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00.000Z';
  }

  String get _startTimeISO {
    if (startDate == null || startTime == null) return '';
    final dateTime = DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      startTime!.hour,
      startTime!.minute,
    );
    return '${_formatDate(dateTime)}T${_formatTime(dateTime)}';
  }

  String get _endTimeISO {
    if (endDate == null || endTime == null) return '';
    final dateTime = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );
    return '${_formatDate(dateTime)}T${_formatTime(dateTime)}';
  }

  void _saveSession() async {
    if (titleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter session title',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedEvent == null) {
      Get.snackbar('Error', 'Please select an event',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (startDate == null || endDate == null) {
      Get.snackbar('Error', 'Please select start and end time',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedSpeakers.isEmpty) {
      Get.snackbar('Error', 'Please select at least one speaker',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (locationController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter location link',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final sessionData = {
      "title": titleController.text.trim(),
      "description": descriptionController.text.trim(),
      "startTime": _startTimeISO,
      "endTime": _endTimeISO,
      "location": locationController.text.trim(),
      "category": selectedCategory,
      "capacity": int.tryParse(capacityController.text) ?? 50,
      "tags": tags,
      "eventId": selectedEvent!.eventId,
      "speakerIds": selectedSpeakers.map((speaker) => speaker.speakerId).toList(),
      "registrationRequired": registrationRequired,
    };

    bool success;
    if (widget.isEditMode && widget.sessionId != null) {
      success = await _updateViewModel.updateSession(widget.sessionId!, sessionData);
    } else {
      success = await _createViewModel.createSession(sessionData);
    }

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          text: widget.isEditMode ? 'Edit Session' : 'Add New Session',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Obx(() {
        if (widget.isEditMode && _sessionDetailsViewModel.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session Title
              const AppText(
                text: 'Session Title*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: titleController,
                hintText: 'Enter session title',
              ),

              const SizedBox(height: 20),

              // Event Selection
              const AppText(
                text: 'Event*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
              const SizedBox(height: 8),
              _buildEventDropdown(),

              const SizedBox(height: 20),

              // Category
              const AppText(
                text: 'Category*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
              const SizedBox(height: 8),
              _buildCategoryDropdown(),

              const SizedBox(height: 20),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          text: 'Start Date & Time*',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 8),
                        _buildDateTimeField(_formattedStartDateTime, _selectStartDateTime),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          text: 'End Date & Time*',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 8),
                        _buildDateTimeField(_formattedEndDateTime, _selectEndDateTime),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Location Link
              const AppText(
                text: 'Location Link*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: locationController,
                hintText: 'https://maps.google.com/?q=123+Main+St',
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 20),

              // Capacity
              const AppText(
                text: 'Capacity',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: capacityController,
                hintText: '50',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              // Speakers Selection
              const AppText(
                text: 'Speakers*',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
              const SizedBox(height: 8),
              _buildSpeakersSelection(),

              // Selected Speakers
              if (selectedSpeakers.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildSelectedSpeakers(),
              ],

              const SizedBox(height: 20),

              // Description
              const AppText(
                text: 'Description',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.lightGreyColor,
                  border: Border.all(color: AppColors.containerGreyColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: descriptionController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Describe your session in detail',
                    hintStyle: TextStyle(color: AppColors.darkgrey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Tags
              const AppText(
                text: 'Tags',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: tagController,
                      hintText: 'Add a tag (e.g., AI, Workshop)',
                      onChanged: (value) {
                        // Optional: Add real-time validation
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    text: 'Add',
                    onPressed: _addTag,
                    backgroundColor: AppColors.primaryColor,
                    height: 48,
                    width: 80,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) => _buildTagChip(tag)).toList(),
              ),

              const SizedBox(height: 20),

              // Registration Required
              Row(
                children: [
                  Checkbox(
                    value: registrationRequired,
                    onChanged: (value) {
                      setState(() {
                        registrationRequired = value ?? false;
                      });
                    },
                    activeColor: AppColors.primaryColor,
                  ),
                  const AppText(
                    text: 'Registration Required',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blackColor,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Save/Update Button
              CustomButton(
                text: widget.isEditMode ? 'Update Session' : 'Create Session',
                onPressed: _createViewModel.isLoading.value || _updateViewModel.isLoading.value ? null : _saveSession,
                backgroundColor: AppColors.primaryColor,
                height: 48,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEventDropdown() {
    return Obx(() {
      if (_eventsViewModel.isLoading.value) {
        return _buildDropdownLoading('Loading events...');
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.lightGreyColor,
          border: Border.all(color: AppColors.containerGreyColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<OrganizerEventIdGetModel>(
            value: selectedEvent,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            hint: const AppText(
              text: 'Select Event',
              fontSize: 14,
              color: AppColors.darkgrey,
            ),
            items: _eventsViewModel.eventsList.map((event) {
              return DropdownMenuItem<OrganizerEventIdGetModel>(
                value: event,
                child: AppText(
                  text: '${event.title} (ID: ${event.eventId})',
                  fontSize: 14,
                  color: Colors.black,
                ),
              );
            }).toList(),
            onChanged: (OrganizerEventIdGetModel? newValue) {
              setState(() {
                selectedEvent = newValue;
              });
            },
          ),
        ),
      );
    });
  }

  Widget _buildCategoryDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        border: Border.all(color: AppColors.containerGreyColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: AppText(
                text: category,
                fontSize: 14,
                color: Colors.black,
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedCategory = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDateTimeField(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.lightGreyColor,
          border: Border.all(color: AppColors.containerGreyColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                text: text,
                fontSize: 14,
                color: text.startsWith('Select') ? AppColors.darkgrey : Colors.black,
              ),
            ),
            Icon(Icons.calendar_today, size: 16, color: AppColors.darkgrey),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakersSelection() {
    return Obx(() {
      if (_speakersViewModel.isLoading.value) {
        return _buildDropdownLoading('Loading speakers...');
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced vertical padding
        decoration: BoxDecoration(
          color: AppColors.lightGreyColor,
          border: Border.all(color: AppColors.containerGreyColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<OrganizerAllSpeakerGetModel>(
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down),
            hint: Container(
              height: 40, // Fixed height for hint
              alignment: Alignment.centerLeft,
              child: const AppText(
                text: 'Select Speakers',
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ),
            items: _speakersViewModel.speakersList.map((speaker) {
              return DropdownMenuItem<OrganizerAllSpeakerGetModel>(
                value: speaker,
                child: _buildSpeakerDropdownItem(speaker),
              );
            }).toList(),
            onChanged: (OrganizerAllSpeakerGetModel? newValue) {
              if (newValue != null && !selectedSpeakers.contains(newValue)) {
                setState(() {
                  selectedSpeakers.add(newValue);
                });
              }
            },
          ),
        ),
      );
    });
  }
  Widget _buildSpeakerDropdownItem(OrganizerAllSpeakerGetModel speaker) {
    return Container(
      height: 48, // Fixed container height
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryColor.withOpacity(0.1),
            ),
            child: speaker.imageUrl != null && speaker.imageUrl!.isNotEmpty
                ? ClipOval(
              child: Image.network(
                speaker.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, size: 16, color: AppColors.primaryColor);
                },
              ),
            )
                : Icon(Icons.person, size: 16, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              mainAxisSize: MainAxisSize.min, // Use minimum space
              children: [
                AppText(
                  text: speaker.displayName,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                AppText(
                  text: speaker.email,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSpeakers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          text: 'Selected Speakers:',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkgrey,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedSpeakers.map((speaker) {
            return Chip(
              label: AppText(
                text: speaker.displayName,
                fontSize: 12,
                color: Colors.white,
              ),
              backgroundColor: AppColors.primaryColor,
              deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
              onDeleted: () {
                setState(() {
                  selectedSpeakers.remove(speaker);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: AppText(
        text: tag,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
      deleteIcon: Icon(Icons.close, size: 16, color: AppColors.primaryColor),
      onDeleted: () => _removeTag(tag),
    );
  }

  Widget _buildDropdownLoading(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        border: Border.all(color: AppColors.containerGreyColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          AppText(
            text: text,
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    capacityController.dispose();
    tagController.dispose();
    locationController.dispose();
    super.dispose();
  }
}