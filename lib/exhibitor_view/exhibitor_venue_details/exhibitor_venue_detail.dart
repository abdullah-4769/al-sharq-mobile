import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../images/images.dart';

class ExhibitorVenueDetails extends StatefulWidget {
  @override
  _ExhibitorVenueDetailsState createState() => _ExhibitorVenueDetailsState();
}

class _ExhibitorVenueDetailsState extends State<ExhibitorVenueDetails> {
  String selectedHall = 'Hall A';

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
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const AppText(
                  text: 'Exhibitor Details',
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
                        text: 'EXH Tech',
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
                SizedBox(height: 16),
                _buildTable(),

                // Locations Section
                _buildLocationsSection(),

                // Facilities Section
                _buildFacilitiesSection(),

                // Map Placeholder Section
                _buildMapPlaceholderSection(),

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
            text: 'Exhibitor Company Name',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          SizedBox(height: 12),
          AppText(
            text:
            'Our exhibiting company is a leading provider of innovative products and solutions, dedicated to delivering exceptional value to businesses worldwide. With a commitment to quality, innovation, and customer satisfaction, we showcase cutting-edge products and services designed to meet the evolving needs of modern enterprises. Our team of experts is here to demonstrate how our solutions can drive growth, enhance efficiency, and create competitive advantages in your industry.',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 20),
          AppText(
            text: 'Contact Information',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          SizedBox(height: 16),
          _buildContactItem(
            Icons.language,
            'Website',
            'www.exhibitor.com',
            Colors.blue,
                () => _launchURL('https://www.exhibitor.com'),
          ),
          _buildContactItem(
            Icons.email,
            'Email',
            'contact@exhibitor.com',
            Colors.green,
                () => _launchURL('mailto:contact@exhibitor.com'),
          ),
          _buildContactItem(
            Icons.phone,
            'Phone',
            '+1 (555) 987-6543',
            Colors.purple,
                () => _launchURL('tel:+15559876543'),
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
            child: _buildHallButton('Exhibition Area', selectedHall == 'Exhibition Area'),
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
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
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
            text: text,
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
      margin: EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
              image: AssetImage(Images.stages),
              fit: BoxFit.cover
          )
      ),
    );
  }

  Widget _buildLocationsSection() {
    final locations = [
      {'icon': Icons.store, 'name': 'Booth A', 'subtitle': 'Exhibition Booth', 'color': Colors.red},
      {'icon': Icons.location_on, 'name': 'Hall A', 'subtitle': 'Main Exhibition', 'color': Colors.blue},
      {'icon': Icons.store_mall_directory, 'name': 'Retail Zone', 'subtitle': 'Vendor Area', 'color': Colors.green},
      {'icon': Icons.meeting_room, 'name': 'Demo Room', 'subtitle': 'Product Demo', 'color': Colors.orange},
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
            text: title,
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
                  text: name,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                AppText(
                  text: subtitle,
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
            text: name,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholderSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: 'Venue Location',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  text: 'Map View',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Map Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Stack(
              children: [
                // Background Pattern
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[100]!,
                        Colors.grey[200]!,
                      ],
                    ),
                  ),
                ),

                // Roads
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 20,
                    color: Colors.grey[400]!.withOpacity(0.3),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 10,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    color: Colors.grey[400]!.withOpacity(0.3),
                  ),
                ),

                // Location Markers
                Positioned(
                  top: 60,
                  left: MediaQuery.of(context).size.width / 2 - 60,
                  child: _buildMapMarker('A12 Hall 1', Colors.red, Icons.location_on),
                ),
                Positioned(
                  bottom: 60,
                  right: MediaQuery.of(context).size.width / 2 - 60,
                  child: _buildMapMarker('You', Colors.blue, Icons.person_pin_circle),
                ),

                // Center Info
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 40,
                        color: Colors.grey[500],
                      ),
                      SizedBox(height: 8),
                      AppText(
                        text: 'Conference Venue',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,

                      ),
                      SizedBox(height: 4),
                      AppText(
                        text: 'Enable Google Maps API for live view',
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Location Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLocationDetail('Distance', '250m', Icons.directions_walk),
              _buildLocationDetail('Time', '3 min', Icons.access_time),
              _buildLocationDetail('Floor', 'Ground', Icons.layers),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker(String title, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AppText(
            text: title,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryColor),
        SizedBox(height: 4),
        AppText(
          text: value,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        AppText(
          text: label,
          fontSize: 10,
          color: AppColors.darkgrey,
        ),
      ],
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
            text: 'Follow Us',
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
            image,
            SizedBox(width: 8),
            AppText(
              text: platform,
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
}