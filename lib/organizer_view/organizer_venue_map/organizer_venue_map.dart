import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/organizer_view/add_new_venue/add_new_venue_view.dart';

import '../../data/response_models/organizer_response_models/organizer_venue_show_model.dart';
import '../../view_model/organizer_viewmodels/organizer_event_delete_viewmodel.dart';
import '../../view_model/organizer_viewmodels/organizer_venue_show_viewmodel.dart';
import 'package:al_sharq_conference/organizer_view/venue_details/organizer_venue_details.dart';
import 'interactive_venue_map.dart';

class OrganizerVenueMapsScreen extends StatefulWidget {
  const OrganizerVenueMapsScreen({super.key});

  @override
  State<OrganizerVenueMapsScreen> createState() => _OrganizerVenueMapsScreenState();
}

class _OrganizerVenueMapsScreenState extends State<OrganizerVenueMapsScreen> {
  final TextEditingController searchController = TextEditingController();
  final OrganizerVenueShowViewModel _venueViewModel = Get.put(OrganizerVenueShowViewModel());
  final OrganizerEventDeleteViewModel _deleteViewModel = Get.put(OrganizerEventDeleteViewModel());

  @override
  void initState() {
    super.initState();
    _loadVenueData();
  }

  void _loadVenueData() {
    _venueViewModel.getVenueSummary();
  }

  void _showDeleteDialog(OrganizerVenueShowEvent event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const AppText(
            text: 'Delete Event',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          content: AppText(
            text: 'Are you sure you want to delete "${event.name}"? This action cannot be undone.',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const AppText(
                text: 'Cancel',
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // FIXED: Call deleteEvent with all required named parameters
                final success = await _deleteViewModel.deleteEvent(
                  eventId: event.id,
                  eventName: event.name,
                  affectedUserIds: [], // For now, empty array. You'll need to get actual affected users
                  reason: 'Deleted by organizer',
                );
                if (success) {
                  _loadVenueData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const AppText(
                text: 'Delete',
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomAppDrawer(),
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const AppText(
          text: 'Venue Maps',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Obx(() {
        if (_venueViewModel.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        if (_venueViewModel.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: 'Error: ${_venueViewModel.error.value}',
                  fontSize: 16,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Retry',
                  onPressed: _loadVenueData,
                ),
              ],
            ),
          );
        }

        final venueData = _venueViewModel.venueData.value;
        final events = venueData.events;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Search Bar
              Container(
                color: AppColors.whiteColor,
                padding: const EdgeInsets.all(16),
                child: CustomTextField(
                  hintText: 'Search venues...',
                  controller: searchController,
                  suffixIcon: Icons.search,
                  suffixIconColor: AppColors.primaryColor,
                ),
              ),

              // Stats Cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Sessions',
                        venueData.totalSessions.toString(),
                        Icons.event,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Live Now',
                        venueData.liveSessions.toString(),
                        Icons.play_circle_filled,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Scheduled',
                        venueData.scheduledSessions.toString(),
                        Icons.schedule,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              // Interactive Map
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: VenueMapComponent(
                  events: events,
                  onMarkerTap: (event) {
                    Get.to(() => EventDetailsScreen( event:  event));
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Add New Venue Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomButton(
                  text: "Add New Venue",
                  onPressed: () => Get.to(() => AddNewVenueScreen()),
                ),
              ),

              const SizedBox(height: 16),

              // Venue Cards List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildLocationCard(event, index);
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          AppText(
            text: value,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          const SizedBox(height: 4),
          AppText(
            text: title,
            fontSize: 11,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(OrganizerVenueShowEvent event, int index) {
    final color = _getCardColor(index);
    final hasLocation = event.getLatLngFromUrl() != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      hasLocation ? Icons.location_on : Icons.location_off,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: event.name,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        text: event.location ?? 'Check map',
                        fontSize: 13,
                        color: AppColors.darkgrey,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(() => EventDetailsScreen(event: event));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const AppText(
                          text: 'Details',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        Get.to(() => AddNewVenueScreen(eventId: event.id));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const AppText(
                          text: 'Edit',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _showDeleteDialog(event),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const AppText(
                          text: 'Delete',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: event.description,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      '${event.totalSessions} Total',
                      Icons.event,
                      Colors.blue,
                    ),
                    if (event.liveSessions > 0)
                      _buildInfoChip(
                        '${event.liveSessions} Live',
                        Icons.play_circle_filled,
                        Colors.red,
                      ),
                    if (event.scheduledSessions > 0)
                      _buildInfoChip(
                        '${event.scheduledSessions} Scheduled',
                        Icons.schedule,
                        Colors.orange,
                      ),
                    if (event.mapstatus == true)
                      _buildInfoChip(
                        'Map Visible',
                        Icons.map,
                        Colors.green,
                      ),
                    if (!hasLocation)
                      _buildInfoChip(
                        'No Location',
                        Icons.location_off,
                        Colors.grey,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          AppText(
            text: label,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ],
      ),
    );
  }

  Color _getCardColor(int index) {
    switch (index % 3) {
      case 0: return AppColors.primaryColor;
      case 1: return Colors.green;
      case 2: return Colors.blue;
      default: return AppColors.primaryColor;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}