import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_text_field.dart';


// AppText Widget

// Custom TextField


// Venue Location Model
class VenueLocation {
  final String name;
  final String description;
  final String details;
  final String type;
  final String sessionCount;
  final Color color;
  final LatLng position;
  final bool isMapView;

  VenueLocation({
    required this.name,
    required this.description,
    required this.details,
    required this.type,
    required this.sessionCount,
    required this.color,
    required this.position,
    this.isMapView = false,
  });
}

class VenueMapsScreen extends StatefulWidget {
  const VenueMapsScreen({super.key});

  @override
  State<VenueMapsScreen> createState() => _VenueMapsScreenState();
}

class _VenueMapsScreenState extends State<VenueMapsScreen> {
  final TextEditingController searchController = TextEditingController();
  GoogleMapController? _mapController;
  Position? _userPosition;
  Set<Marker> _markers = {};

  // Default location (New York area as shown in your screenshot)
  static const LatLng _defaultLocation = LatLng(40.7128, -74.0060);

  final List<VenueLocation> locations = [
    VenueLocation(
      name: 'Main Hall Map',
      description: 'www.techcorp.com',
      details: 'contact@techcorp.com\n\nDr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      type: 'Keynote Speaker',
      sessionCount: '3 Sessions',
      color: AppColors.primaryColor,
      position: LatLng(40.7589, -73.9851), // A12 Hall 1 position
      isMapView: true,
    ),
    VenueLocation(
      name: 'Main Hall Map',
      description: 'www.techcorp.com',
      details: 'contact@techcorp.com\n\nDr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      type: 'Keynote Speaker',
      sessionCount: '3 Sessions',
      color: Colors.green,
      position: LatLng(40.6892, -74.0445), // Venue 01 position
      isMapView: true,
    ),
    VenueLocation(
      name: 'Main Hall Map',
      description: 'www.techcorp.com',
      details: 'contact@techcorp.com\n\nDr. Johnathan is a professor of Political Science at Cairo University with expertise in international relations and Middle Eastern diplomacy. She has published extensively on regional cooperation and has advised multiple governments and organizations on policy development.',
      type: 'Keynote Speaker',
      sessionCount: '3 Sessions',
      color: Colors.blue,
      position: LatLng(40.7282, -73.7949),
      isMapView: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _createMarkers();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _userPosition = position;
      });
      _updateUserMarker();
    } catch (e) {
      // Handle location error
    }
  }

  void _createMarkers() {
    _markers.clear();

    // Add venue markers
    for (int i = 0; i < locations.length; i++) {
      final location = locations[i];
      String markerId = 'venue_$i';
      String markerLabel = i == 0 ? 'A12 Hall 1' : i == 1 ? 'Venue 01' : 'Venue 02';

      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: location.position,
          infoWindow: InfoWindow(
            title: markerLabel,
            snippet: location.type,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            location.color == AppColors.primaryColor ? BitmapDescriptor.hueRed :
            location.color == Colors.green ? BitmapDescriptor.hueGreen :
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    _updateUserMarker();
  }

  void _updateUserMarker() {
    if (_userPosition != null) {
      _markers.removeWhere((marker) => marker.markerId.value == 'user_location');
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          infoWindow: const InfoWindow(
            title: 'You',
            snippet: 'Your current location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
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
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: AppColors.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              hintText: 'Search...',
              controller: searchController,
              suffixIcon: Icons.tune,
              suffixIconColor: AppColors.primaryColor,
            ),
          ),

          // Google Map
          Container(
            height: 250,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _userPosition != null
                      ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
                      : _defaultLocation,
                  zoom: 11.0,
                ),
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                zoomControlsEnabled: false,
              ),
            ),
          ),

          // Venue Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];
                return _buildLocationCard(location, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(VenueLocation location, int index) {
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
          // Header with colored circle and tags
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Colored circle indicator
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: location.color,
                    shape: BoxShape.circle,
                  ),
                  child:  Center(
                    child: AppText(
                      text: 'Just Launched',
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: location.name,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        text: location.description,
                        fontSize: 13,
                        color: AppColors.darkgrey,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppText(
                        text: location.type,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.lightred2.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppText(
                        text: location.sessionCount,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: AppText(
              text: location.details,
              fontSize: 12,
              color: AppColors.darkgrey,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}