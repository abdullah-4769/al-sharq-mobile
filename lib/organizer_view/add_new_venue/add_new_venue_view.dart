import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';

import '../../data/response_models/organizer_response_models/organizer_show_list_sponsors_model.dart';
import '../../data/response_models/organizer_response_models/organizer_showlist_exhibitors_model.dart';
import '../../view_model/organizer_viewmodels/organizer_create_event_venue_viewmodel.dart';
import '../../view_model/organizer_viewmodels/organizer_showlist_exhibitors_viewmodel.dart';
import '../../view_model/organizer_viewmodels/organizer_showlist_sponsors_viewmodel.dart';

class AddNewVenueScreen extends StatefulWidget {
  final int? eventId;

  const AddNewVenueScreen({super.key, this.eventId});

  @override
  _AddNewVenueScreenState createState() => _AddNewVenueScreenState();
}

class _AddNewVenueScreenState extends State<AddNewVenueScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController googleMapLinkController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  final OrganizerCreateEventVenueViewModel _createViewModel = Get.put(OrganizerCreateEventVenueViewModel());
  final OrganizerShowListSponsorsViewModel _sponsorsViewModel = Get.put(OrganizerShowListSponsorsViewModel());
  final OrganizerShowListExhibitorsViewModel _exhibitorsViewModel = Get.put(OrganizerShowListExhibitorsViewModel());

  bool isVisibleToParticipants = false;
  List<File> selectedImages = [];
  List<int> selectedSponsors = [];
  List<int> selectedExhibitors = [];

  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      await _loadSponsorsAndExhibitors();

      if (widget.eventId != null) {
        await _loadEventData();
      }
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final DateTime dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        startTimeController.text = dateTime.toIso8601String();
      }
    }
  }

  Future<void> _selectEndTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final DateTime dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        endTimeController.text = dateTime.toIso8601String();
      }
    }
  }

  Future<void> _loadSponsorsAndExhibitors() async {
    await Future.wait([
      _sponsorsViewModel.getSponsorsList(),
      _exhibitorsViewModel.getExhibitorsList(),
    ]);
  }

  Future<void> _loadEventData() async {
    await _createViewModel.getEvent(widget.eventId!);
    final event = _createViewModel.eventData.value;

    titleController.text = event.title;
    locationController.text = event.location;
    descriptionController.text = event.description;
    googleMapLinkController.text = event.googleMapLink;
    isVisibleToParticipants = event.mapstatus;

    if (event.startTime != null) {
      startTimeController.text = event.startTime!;
    }
    if (event.endTime != null) {
      endTimeController.text = event.endTime!;
    }

    selectedSponsors = event.sponsors.map((sponsor) => sponsor.id).toList();
    selectedExhibitors = event.exhibitors.map((exhibitor) => exhibitor.id).toList();
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
          onPressed: () => Get.back(),
        ),
        title: AppText(
          text: widget.eventId != null ? 'Edit Venue' : 'Add New Venue',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkgrey,
        ),
        centerTitle: true,
      ),
      body: _isLoadingData
          ? _buildLoadingIndicator('Loading venue data...')
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            _buildTextFieldSection(
              label: 'Title*',
              controller: titleController,
              hintText: 'Enter a clear title',
            ),

            SizedBox(height: 24),

            // Location Field
            _buildTextFieldSection(
              label: 'Location*',
              controller: locationController,
              hintText: 'New York, USA',
            ),

            SizedBox(height: 24),

            // Google Maps Link Field
            _buildTextFieldSection(
              label: 'Google Maps Link*',
              controller: googleMapLinkController,
              hintText: 'https://maps.google.com/?q=123+Main+St',
            ),

            SizedBox(height: 24),

            // Start Time and End Time Fields
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeField(
                    label: 'Start Time',
                    controller: startTimeController,
                    onTap: _selectStartTime,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDateTimeField(
                    label: 'End Time',
                    controller: endTimeController,
                    onTap: _selectEndTime,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Description Field
            _buildDescriptionField(),

            SizedBox(height: 24),

            // Sponsors Selection
            _buildSponsorsDropdown(),

            SizedBox(height: 24),

            // Exhibitors Selection
            _buildExhibitorsDropdown(),

            SizedBox(height: 24),

            // Visibility Toggle
            _buildVisibilityToggle(),

            SizedBox(height: 40),

            // Add/Update Button with loading state
            _buildActionButton(),

            // Add some bottom padding for safety
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          SizedBox(height: 16),
          AppText(
            text: text,
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldSection({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.darkgrey,
        ),
        SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hintText: hintText,
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.darkgrey,
        ),
        SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          hintText: 'Select date and time',
          readOnly: true,
          onTap: onTap,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Description',
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
            controller: descriptionController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.darkgrey,
            ),
            decoration: InputDecoration(
              hintText: 'Describe your topic in detail',
              hintStyle: TextStyle(
                fontSize: 16,
                color: AppColors.lightGrey,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSponsorsDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: 'Select Sponsors',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
            AppText(
              text: 'Selected: ${selectedSponsors.length}',
              fontSize: 14,
              color: AppColors.primaryColor,
            ),
          ],
        ),
        SizedBox(height: 8),
        _buildSponsorsContent(),
      ],
    );
  }

  Widget _buildSponsorsContent() {
    return Obx(() {
      if (_sponsorsViewModel.isLoading.value) {
        return _buildSectionLoadingIndicator('Loading sponsors...');
      }

      if (_sponsorsViewModel.sponsorsList.isEmpty) {
        return _buildEmptyState('No sponsors available');
      }

      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _buildSponsorsDropdownButton(),
          ),
          SizedBox(height: 12),
          _buildSelectedSponsorsList(),
        ],
      );
    });
  }

  Widget _buildSponsorsDropdownButton() {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<OrganizerShowListSponsorsModel>(
        isExpanded: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: 'Select sponsors',
          hintStyle: TextStyle(
            fontSize: 16,
            color: AppColors.lightGrey,
          ),
        ),
        items: _sponsorsViewModel.sponsorsList.map((sponsor) {
          return DropdownMenuItem<OrganizerShowListSponsorsModel>(
            value: sponsor,
            child: Container(
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.1),
                    ),
                    child: sponsor.picUrl != null && sponsor.picUrl!.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        sponsor.picUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.business,
                            color: AppColors.primaryColor,
                            size: 16,
                          );
                        },
                      ),
                    )
                        : Icon(
                      Icons.business,
                      color: AppColors.primaryColor,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sponsor.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkgrey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (OrganizerShowListSponsorsModel? selectedSponsor) {
          if (selectedSponsor != null && !selectedSponsors.contains(selectedSponsor.id)) {
            setState(() {
              selectedSponsors.add(selectedSponsor.id);
            });
          }
        },
      ),
    );
  }

  Widget _buildSelectedSponsorsList() {
    if (selectedSponsors.isEmpty) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Selected Sponsors:',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkgrey,
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedSponsors.map((sponsorId) {
            final sponsor = _sponsorsViewModel.sponsorsList.firstWhere(
                  (s) => s.id == sponsorId,
              orElse: () => OrganizerShowListSponsorsModel(
                id: 0,
                name: 'Unknown',
                email: '',

              ),
            );

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.2),
                    ),
                    child: sponsor.picUrl != null && sponsor.picUrl!.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        sponsor.picUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.business,
                            color: AppColors.primaryColor,
                            size: 12,
                          );
                        },
                      ),
                    )
                        : Icon(
                      Icons.business,
                      color: AppColors.primaryColor,
                      size: 12,
                    ),
                  ),
                  SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sponsor.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (sponsor.email.isNotEmpty)
                        Text(
                          sponsor.email,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryColor.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSponsors.remove(sponsorId);
                      });
                    },
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExhibitorsDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: 'Select Exhibitors',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgrey,
            ),
            AppText(
              text: 'Selected: ${selectedExhibitors.length}',
              fontSize: 14,
              color: AppColors.primaryColor,
            ),
          ],
        ),
        SizedBox(height: 8),
        _buildExhibitorsContent(),
      ],
    );
  }

  Widget _buildExhibitorsContent() {
    return Obx(() {
      if (_exhibitorsViewModel.isLoading.value) {
        return _buildSectionLoadingIndicator('Loading exhibitors...');
      }

      if (_exhibitorsViewModel.exhibitorsList.isEmpty) {
        return _buildEmptyState('No exhibitors available');
      }

      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _buildExhibitorsDropdownButton(),
          ),
          SizedBox(height: 12),
          _buildSelectedExhibitorsList(),
        ],
      );
    });
  }

  Widget _buildExhibitorsDropdownButton() {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<OrganizerShowListExhibitorsModel>(
        isExpanded: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: 'Select exhibitors',
          hintStyle: TextStyle(
            fontSize: 16,
            color: AppColors.lightGrey,
          ),
        ),
        items: _exhibitorsViewModel.exhibitorsList.map((exhibitor) {
          return DropdownMenuItem<OrganizerShowListExhibitorsModel>(
            value: exhibitor,
            child: Container(
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.1),
                    ),
                    child: exhibitor.picUrl != null && exhibitor.picUrl!.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        exhibitor.picUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.explore,
                            color: AppColors.primaryColor,
                            size: 16,
                          );
                        },
                      ),
                    )
                        : Icon(
                      Icons.explore,
                      color: AppColors.primaryColor,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      exhibitor.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkgrey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (OrganizerShowListExhibitorsModel? selectedExhibitor) {
          if (selectedExhibitor != null && !selectedExhibitors.contains(selectedExhibitor.id)) {
            setState(() {
              selectedExhibitors.add(selectedExhibitor.id);
            });
          }
        },
      ),
    );
  }

  Widget _buildSelectedExhibitorsList() {
    if (selectedExhibitors.isEmpty) {
      return SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Selected Exhibitors:',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkgrey,
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedExhibitors.map((exhibitorId) {
            final exhibitor = _exhibitorsViewModel.exhibitorsList.firstWhere(
                  (e) => e.id == exhibitorId,
              orElse: () => OrganizerShowListExhibitorsModel(
                id: 0,
                name: 'Unknown',
                email: '',

              ),
            );

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(0.2),
                    ),
                    child: exhibitor.picUrl != null && exhibitor.picUrl!.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        exhibitor.picUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.explore,
                            color: AppColors.primaryColor,
                            size: 12,
                          );
                        },
                      ),
                    )
                        : Icon(
                      Icons.explore,
                      color: AppColors.primaryColor,
                      size: 12,
                    ),
                  ),
                  SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        exhibitor.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (exhibitor.email.isNotEmpty)
                        Text(
                          exhibitor.email,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryColor.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedExhibitors.remove(exhibitorId);
                      });
                    },
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVisibilityToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Visibility*',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.darkgrey,
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: 'Map Visible to Participants',
              fontSize: 14,
              color: AppColors.darkgrey,
            ),
            Switch(
              value: isVisibleToParticipants,
              onChanged: (value) {
                setState(() {
                  isVisibleToParticipants = value;
                });
              },
              activeColor: AppColors.primaryColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return Obx(() {
      final isLoading = _createViewModel.isLoading.value;

      return Column(
        children: [
          if (isLoading)
            Column(
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
                SizedBox(height: 16),
                AppText(
                  text: widget.eventId != null ? 'Updating venue...' : 'Creating venue...',
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
                SizedBox(height: 16),
              ],
            ),
          CustomButton(
            text: widget.eventId != null ? 'Update' : 'Add',
            onPressed: isLoading ? null : _saveVenue,
            backgroundColor: AppColors.primaryColor,
            isLoading: isLoading,
          ),
        ],
      );
    });
  }

  Widget _buildSectionLoadingIndicator(String text) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              strokeWidth: 2,
            ),
            SizedBox(height: 8),
            AppText(
              text: text,
              fontSize: 12,
              color: AppColors.darkgrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: AppText(
          text: message,
          fontSize: 14,
          color: AppColors.lightGrey,
        ),
      ),
    );
  }

  void _saveVenue() {
    if (titleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a title',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
      return;
    }

    if (locationController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a location',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
      return;
    }

    if (googleMapLinkController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a Google Maps link',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
      return;
    }

    final eventData = {
      "title": titleController.text,
      "description": descriptionController.text,
      "location": locationController.text,
      "googleMapLink": googleMapLinkController.text,
      "mapstatus": isVisibleToParticipants,
      "sponsors": selectedSponsors.map((id) => {"id": id}).toList(),
      "exhibitors": selectedExhibitors.map((id) => {"id": id}).toList(),
    };

    // Add optional fields if they are not empty
    if (startTimeController.text.isNotEmpty) {
      eventData["startTime"] = startTimeController.text;
    }
    if (endTimeController.text.isNotEmpty) {
      eventData["endTime"] = endTimeController.text;
    }

    if (widget.eventId != null) {
      _createViewModel.updateEvent(widget.eventId!, eventData);
    } else {
      _createViewModel.createEvent(eventData);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    googleMapLinkController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }
}