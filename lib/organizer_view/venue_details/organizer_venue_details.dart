// lib/organizer_view/venue_details/organizer_venue_details.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import '../../data/response_models/organizer_response_models/organizer_venue_show_model.dart';
import '../organizer_venue_map/interactive_venue_map.dart';

class EventDetailsScreen extends StatelessWidget {
  final OrganizerVenueShowEvent event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  Future<void> _launchMapsUrl() async {
    if (event.googleMapLink.isNotEmpty) {
      final uri = Uri.parse(event.googleMapLink);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open Google Maps',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = event.getLatLngFromUrl() != null;

    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: AppText(
          text: 'Venue Details',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
        actions: [
          if (hasLocation)
            IconButton(
              icon: const Icon(Icons.map, color: AppColors.primaryColor),
              onPressed: _launchMapsUrl,
              tooltip: 'Open in Google Maps',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Section using Mapbox
            if (hasLocation)
              VenueMapComponent(
                singleEvent: event,
                height: 300,
                showControls: true,
                showAttribution: true,
              )
            else
              Container(
                height: 300,
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Location not available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Name Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: event.name,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 12),
                          AppText(
                            text: event.description,
                            fontSize: 14,
                            color: AppColors.darkgrey,
                            maxLines: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Event Info Section
                  AppText(
                    text: 'Event Information',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 12),

                  // Info Cards
                  if (event.location != null && event.location!.isNotEmpty)
                    _buildInfoCard(
                      icon: Icons.location_on,
                      title: 'Location',
                      value: event.location!,
                    ),

                  _buildInfoCard(
                    icon: Icons.event,
                    title: 'Total Sessions',
                    value: event.totalSessions.toString(),
                  ),

                  if (event.liveSessions > 0)
                    _buildInfoCard(
                      icon: Icons.play_circle_filled,
                      title: 'Live Sessions',
                      value: event.liveSessions.toString(),
                      valueColor: Colors.red,
                    ),

                  if (event.scheduledSessions > 0)
                    _buildInfoCard(
                      icon: Icons.schedule,
                      title: 'Scheduled Sessions',
                      value: event.scheduledSessions.toString(),
                      valueColor: Colors.orange,
                    ),

                  if (event.startTime != null)
                    _buildInfoCard(
                      icon: Icons.calendar_today,
                      title: 'Start Time',
                      value: _formatDateTime(event.startTime),
                    ),

                  if (event.endTime != null)
                    _buildInfoCard(
                      icon: Icons.calendar_today,
                      title: 'End Time',
                      value: _formatDateTime(event.endTime),
                    ),

                  const SizedBox(height: 16),

                  // Map Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: (event.mapstatus ?? false)
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (event.mapstatus ?? false)
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (event.mapstatus ?? false)
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: (event.mapstatus ?? false)
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        AppText(
                          text: (event.mapstatus ?? false)
                              ? 'Map is visible to participants'
                              : 'Map is hidden from participants',
                          fontSize: 14,
                          color: (event.mapstatus ?? false)
                              ? Colors.green
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sponsors Section
                  if (event.sponsors.isNotEmpty) ...[
                    AppText(
                      text: 'Sponsors (${event.sponsors.length})',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 12),
                    ...event.sponsors.map((sponsor) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.business,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          title: AppText(
                            text: sponsor.name,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          subtitle: AppText(
                            text: sponsor.email,
                            fontSize: 12,
                            color: AppColors.darkgrey,
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                  ],

                  // Exhibitors Section
                  if (event.exhibitors.isNotEmpty) ...[
                    AppText(
                      text: 'Exhibitors (${event.exhibitors.length})',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 12),
                    ...event.exhibitors.map((exhibitor) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            child: const Icon(
                              Icons.store,
                              color: Colors.orange,
                            ),
                          ),
                          title: AppText(
                            text: exhibitor.name,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          subtitle: AppText(
                            text: exhibitor.email,
                            fontSize: 12,
                            color: AppColors.darkgrey,
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                  ],

                  // Action Button
                  if (hasLocation)
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Open in Google Maps',
                        onPressed: _launchMapsUrl,
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: title,
                    fontSize: 12,
                    color: AppColors.darkgrey,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: value,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'Not set';

    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}