import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../images/images.dart';
import '../../data/response_models/organizer_response_models/organizer_venue_show_model.dart';

class OrganizerVenueDetails extends StatefulWidget {
  final OrganizerVenueShowEvent event;

  const OrganizerVenueDetails({super.key, required this.event});

  @override
  _OrganizerVenueDetailsState createState() => _OrganizerVenueDetailsState();
}

class _OrganizerVenueDetailsState extends State<OrganizerVenueDetails> {
  String selectedHall = 'Hall A';
  GoogleMapController? _mapController;
  Set<Marker> _mapMarkers = {};

  @override
  void initState() {
    super.initState();
    _createMapMarkers();
  }

  void _createMapMarkers() {
    _mapMarkers.clear();

    final position = widget.event.getLatLngFromUrl();
    if (position != null) {
      _mapMarkers.add(
        Marker(
          markerId: MarkerId('event_location_${widget.event.id}'),
          position: position,
          infoWindow: InfoWindow(
            title: widget.event.name,
            snippet: widget.event.location ?? 'Event Location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomAppDrawer(),
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.whiteColor,
            flexibleSpace: FlexibleSpaceBar(
              title: AppText(
                text: widget.event.name,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              background: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.7),
                    ),
                    child: const Icon(
                      Icons.event,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.blackColor.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Event Description
                _buildEventSection(),

                // Sponsors Section
                if (widget.event.sponsors.isNotEmpty) _buildSponsorsSection(),

                // Exhibitors Section
                if (widget.event.exhibitors.isNotEmpty) _buildExhibitorsSection(),

                // Event Details
                _buildEventDetailsSection(),

                // Map Section
                if (widget.event.getLatLngFromUrl() != null) _buildMapSection(),

                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: widget.event.name,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          SizedBox(height: 12),
          AppText(
            text: widget.event.description,
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 20),
          AppText(
            text: 'Event Information',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          SizedBox(height: 16),
          _buildInfoItem(
            Icons.location_on,
            'Location',
            widget.event.location ?? 'Not specified',
            Colors.blue,
          ),
          _buildInfoItem(
            Icons.calendar_today,
            'Sessions',
            '${widget.event.totalSessions} Sessions',
            Colors.green,
          ),
          if (widget.event.startTime != null)
            _buildInfoItem(
              Icons.access_time,
              'Start Time',
              _formatDateTime(widget.event.startTime!),
              Colors.purple,
            ),
          if (widget.event.endTime != null)
            _buildInfoItem(
              Icons.access_time,
              'End Time',
              _formatDateTime(widget.event.endTime!),
              Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildSponsorsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Sponsors (${widget.event.sponsors.length})',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
            ),
            itemCount: widget.event.sponsors.length,
            itemBuilder: (context, index) {
              final sponsor = widget.event.sponsors[index];
              return _buildSponsorExhibitorItem(
                sponsor.name,
                sponsor.email,
                sponsor.picUrl,
                Colors.blue,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExhibitorsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Exhibitors (${widget.event.exhibitors.length})',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
            ),
            itemCount: widget.event.exhibitors.length,
            itemBuilder: (context, index) {
              final exhibitor = widget.event.exhibitors[index];
              return _buildSponsorExhibitorItem(
                exhibitor.name,
                exhibitor.email,
                exhibitor.picUrl,
                Colors.green,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorExhibitorItem(String name, String email, String? imageUrl, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.business, color: Colors.white, size: 20),
            ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: name,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                AppText(
                  text: email,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetailsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Event Details',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (widget.event.mapstatus == true)
                _buildDetailChip('Map Visible', Colors.green),
              _buildDetailChip('${widget.event.totalSessions} Sessions', Colors.blue),
              _buildDetailChip('${widget.event.sponsors.length} Sponsors', Colors.purple),
              _buildDetailChip('${widget.event.exhibitors.length} Exhibitors', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: AppText(
        text: text,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  Widget _buildMapSection() {
    final position = widget.event.getLatLngFromUrl();
    if (position == null) return SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: position,
            zoom: 15.0,
          ),
          markers: _mapMarkers,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          mapType: MapType.normal,
          zoomControlsEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: label,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                ),
                AppText(
                  text: value,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}