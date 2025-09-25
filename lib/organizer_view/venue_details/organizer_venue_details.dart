import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../images/images.dart';

class OrganizerVenueDetails extends StatefulWidget {
  @override
  _OrganizerVenueDetailsState createState() => _OrganizerVenueDetailsState();
}

class _OrganizerVenueDetailsState extends State<OrganizerVenueDetails> {
  String selectedHall = 'Hall A';
  GoogleMapController? _mapController;
  Set<Marker> _mapMarkers = {};

  // Default location (e.g., New York area)
  static const LatLng _defaultLocation = LatLng(40.7128, -74.0060);

  @override
  void initState() {
    super.initState();
    _createMapMarkers();
  }

  void _createMapMarkers() {
    _mapMarkers.clear();
    // Marker for "A12 Hall 1"
    _mapMarkers.add(
      Marker(
        markerId: const MarkerId('a12_hall_1'),
        position: LatLng(40.7589, -73.9851), // Example position (adjust as needed)
        infoWindow: const InfoWindow(title: 'A12 Hall 1', snippet: 'Main Venue'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    // Marker for "You" (simulate user location)
    _mapMarkers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(40.7128, -74.0060), // Default user position (adjust with Geolocator if needed)
        infoWindow: const InfoWindow(title: 'You', snippet: 'Your current location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomAppDrawer(),
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.whiteColor,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const AppText(
                  text: 'Exhibitors Details',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800'),
                        fit: BoxFit.cover,
                      ),
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
                  Positioned(
                    bottom: 20,
                    left: MediaQuery.of(context).size.width / 2 - 30,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.lightred2,
                      child: AppText(
                        text: 'CloudTech',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.whiteColor,
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
                // Company Description
                _buildCompanySection(),

                // Hall Selection Buttons
                _buildHallSelection(),
                _buildTable(),

                // Venue Layout
                // _buildVenueLayout(),

                // Locations Section
                _buildLocationsSection(),

                // Facilities Section
                _buildFacilitiesSection(),

                // Map Section
                _buildMapSection(),

                // Social Media Section
                _buildSocialMediaSection(),

                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanySection() {
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
            text:
            'CloudTech Solutions',

              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,

          ),
          SizedBox(height: 12),
          AppText(
            text:
            'CloudTech Solutions is a leading provider of enterprise software solutions and digital transformation services, helping Fortune 500 companies worldwide streamline operations, enhance productivity, and embrace innovation. With decades of experience across multiple industries, TechWorld specializes in creating customized technology solutions that drive growth, improve customer experiences, and enable organizations to stay competitive in an ever-evolving digital landscape. Committed to excellence, TechWorld combines cutting-edge tools, expert consulting, and best-in-class support to deliver measurable business outcomes and empower companies to achieve their strategic goals.',

              fontSize: 14,
              color: AppColors.darkgrey,


          ),
          SizedBox(height: 20),
          AppText(
            text:
            'Contact Information',

              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,

          ),
          SizedBox(height: 16),
          _buildContactItem(
            Icons.language,
            'Website',
            'www.techcorp.com',
            Colors.blue,
                () => _launchURL('https://www.techcorp.com'),
          ),
          _buildContactItem(
            Icons.email,
            'Email',
            'contact@techcorp.com',
            Colors.green,
                () => _launchURL('mailto:contact@techcorp.com'),
          ),
          _buildContactItem(
            Icons.phone,
            'Phone',
            '+1 (555) 123-4567',
            Colors.purple,
                () => _launchURL('tel:+15551234567'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                    text:
                    label,

                      fontSize: 12,
                      color: AppColors.darkgrey,

                  ),
                  AppText(
                    text:
                    value,

                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,

                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHallSelection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildHallButton('Hall A', selectedHall == 'Hall A'),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildHallButton('Hall B', selectedHall == 'Hall B'),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildHallButton('Coffee Lounge', selectedHall == 'Coffee Lounge'),
          ),
        ],
      ),
    );
  }

  Widget _buildHallButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedHall = text),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red[700] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.red[700]! : Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: AppText(
            text:
            text,

              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 12,

          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: AssetImage(Images.stages,),fit: BoxFit.cover)
      ),
    );
  }

  Widget _buildLocationsSection() {
    final locations = [
      {'icon': Icons.mic, 'name': 'Hall A', 'subtitle': 'Main Auditorium', 'color': Colors.red},
      {'icon': Icons.groups, 'name': 'Hall B', 'subtitle': 'Conference Room', 'color': Colors.blue},
      {'icon': Icons.store, 'name': 'Exhibitions', 'subtitle': 'Sponsor Booth', 'color': Colors.green},
      {'icon': Icons.coffee, 'name': 'Networking', 'subtitle': 'Coffee Lounge', 'color': Colors.orange},
    ];

    return _buildSectionCard(
      'Locations',
      Column(
        children: locations.map((location) => _buildLocationItem(
          location['icon'] as IconData,
          location['name'] as String,
          location['subtitle'] as String,
          location['color'] as Color,
        )).toList(),
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    final facilities = [
      {'icon': Icons.wc, 'name': 'Restrooms', 'color': Colors.blue},
      {'icon': Icons.wifi, 'name': 'WiFi Zone', 'color': Colors.cyan},
      {'icon': Icons.restaurant, 'name': 'Food Court', 'color': Colors.amber},
      {'icon': Icons.local_parking, 'name': 'Parking', 'color': Colors.purple},
      {'icon': Icons.elevator, 'name': 'Elevators', 'color': Colors.green},
      {'icon': Icons.info, 'name': 'Info Desk', 'color': Colors.indigo},
    ];

    return _buildSectionCard(
      'Facilities',
      Column(
        children: facilities.map((facility) => _buildFacilityItem(
          facility['icon'] as IconData,
          facility['name'] as String,
          facility['color'] as Color,
        )).toList(),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
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
            text:
            title,

              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,

          ),
          SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildLocationItem(IconData icon, String name, String subtitle, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text:
                  name,

                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,

                ),
                AppText(
                  text:
                  subtitle,

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

  Widget _buildFacilityItem(IconData icon, String name, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          AppText(
            text:
            name,

              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,

          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
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
            target: _defaultLocation,
            zoom: 11.0,
          ),
          markers: _mapMarkers,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          mapType: MapType.normal,
          zoomControlsEnabled: true,
          myLocationEnabled: true, // Requires location permissions
          myLocationButtonEnabled: true,
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
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
            text:
            'Follow Us',

              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,

          ),
          SizedBox(height: 16),
          _buildSocialButton('LinkedIn', Colors.blue[700]!, Image.asset(Images.linkedin2, height: 20, width: 20)),
          SizedBox(height: 8),
          _buildSocialButton('Twitter', Colors.blue[400]!, Image.asset(Images.twitterIcon, height: 20, width: 20)),
          SizedBox(height: 8),
          _buildSocialButton('YouTube', Colors.red[600]!, Image.asset(Images.youtube, height: 20, width: 20)),

        ],
      ),
    );
  }

  Widget _buildSocialButton(String platform, Color color, Image image) {
    return InkWell(
      onTap: () => _showSocialMediaDialog(platform),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image, // 👈 directly use
            SizedBox(width: 8),
            AppText(
              text:
              platform,

                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,

            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar(
          'Error',
          'Could not open $url',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Info',
        'Opening $url...',
        backgroundColor: Colors.blue[100],
        colorText: Colors.blue[800],
      );
    }
  }

  void _showSocialMediaDialog(String platform) {
    Get.dialog(
      AlertDialog(
        title: Text('Follow on $platform'),
        content: Text('Opening $platform profile...'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}