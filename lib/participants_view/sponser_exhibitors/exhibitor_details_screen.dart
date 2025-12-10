import 'package:al_sharq_conference/custom_widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/response_models/participant_response_model/sponsor_and_exibitors/participant_exibitor_detail_show_model.dart';
import '../../data/response_models/participant_response_model/sponsor_and_exibitors/participant_sponsor_detail_showmodel.dart';
import '../../images/images.dart';
import 'package:get/get.dart';
import '../../view_model/participant_viewmodel/participant_sponsor_exibitor_viewmodel/participant_exibitor_detail_show_viewmodel.dart';
import '../../view_model/participant_viewmodel/participant_sponsor_exibitor_viewmodel/participant_sponsor_detail_show_viewmodel.dart';

class ExhibitorDetailScreen extends StatefulWidget {
  final int id;
  final String type;

  const ExhibitorDetailScreen({
    super.key,
    required this.id,
    required this.type,
  });

  @override
  State<ExhibitorDetailScreen> createState() => _ExhibitorDetailScreenState();
}

class _ExhibitorDetailScreenState extends State<ExhibitorDetailScreen> {
  @override
  void initState() {
    super.initState();
    print('=== ExhibitorDetailScreen loaded with id: ${widget.id}, type: ${widget.type} ===');

    if (widget.type == 'sponsor') {
      final sponsorViewModel = Get.put(
        ParticipantSponsorDetailsShowViewModel(),
        tag: 'sponsor_${widget.id}',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sponsorViewModel.fetchSponsorDetails(widget.id, context);
      });
    } else {
      final exhibitorViewModel = Get.put(
        ParticipantExhibitorDetailsViewModel(),
        tag: 'exhibitor_${widget.id}',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        exhibitorViewModel.fetchExhibitorDetails(widget.id, context);
      });
    }
  }

  @override
  void dispose() {
    if (widget.type == 'sponsor') {
      Get.delete<ParticipantSponsorDetailsShowViewModel>(tag: 'sponsor_${widget.id}');
    } else {
      Get.delete<ParticipantExhibitorDetailsViewModel>(tag: 'exhibitor_${widget.id}');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomAppDrawer(),
      backgroundColor: AppColors.lightGreyColor,
      body: widget.type == 'sponsor'
          ? _buildSponsorDetailScreen(context)
          : _buildExhibitorDetailScreen(context),
    );
  }

  Widget _buildSponsorDetailScreen(BuildContext context) {
    final sponsorViewModel = Get.find<ParticipantSponsorDetailsShowViewModel>(
      tag: 'sponsor_${widget.id}',
    );

    return Obx(() {
      if (sponsorViewModel.isLoading.value && sponsorViewModel.sponsorDetails == null) {
        return const Center(child: CircularProgressIndicator());
      }

      if (sponsorViewModel.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                sponsorViewModel.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        );
      }

      final sponsor = sponsorViewModel.sponsorDetails;
      if (sponsor == null) {
        return const Center(child: Text('No sponsor details found'));
      }

      return CustomScrollView(
        slivers: [
          _buildHeaderSection(
            context: context,
            imageUrl: sponsor.picUrl ?? 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
            logoText: _getInitials(sponsor.name),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.whiteColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: sponsor.name,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 12),
                        AppText(
                          text: sponsor.description,
                          fontSize: 13,
                          color: AppColors.darkgrey,
                        ),
                        const SizedBox(height: 24),

                        if (sponsor.contacts.isNotEmpty) ...[
                          AppText(
                            text: 'Contact Information',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                          const SizedBox(height: 16),
                          ...sponsor.contacts.map((contact) =>
                              _buildContactItem(
                                icon: Icons.email,
                                title: 'Email',
                                subtitle: contact.email,
                                iconColor: AppColors.darkBlue,
                              )
                          ).toList(),
                          const SizedBox(height: 24),
                        ],

                        if (sponsor.representatives.isNotEmpty) ...[
                          AppText(
                            text: 'Team',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                          const SizedBox(height: 16),
                          ...sponsor.representatives.map((rep) =>
                              _buildTeamMember(
                                name: rep.user.name,
                                position: rep.displayTitle,
                                imageUrl: rep.user.file,
                              )
                          ).toList(),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),

                  if (sponsor.products.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      color: AppColors.lightGreyColor,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: 'Products & Services',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                          const SizedBox(height: 16),
                          ...sponsor.products.map((product) =>
                              _buildServiceItem(
                                icon: Icons.business_center,
                                title: product.title,
                                description: product.description,
                                iconColor: AppColors.lightBlue,
                              )
                          ).toList(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],

                  if (sponsor.socialMedia.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      color: AppColors.lightGreyColor,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: 'Follow Us',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                          const SizedBox(height: 16),
                          ...sponsor.socialMedia.map((social) =>
                              _buildSocialMediaButton(social)
                          ).toList(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildExhibitorDetailScreen(BuildContext context) {
    final exhibitorViewModel = Get.find<ParticipantExhibitorDetailsViewModel>(
      tag: 'exhibitor_${widget.id}',
    );

    return Obx(() {
      if (exhibitorViewModel.isLoading.value && exhibitorViewModel.exhibitorDetails == null) {
        return const Center(child: CircularProgressIndicator());
      }

      if (exhibitorViewModel.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                exhibitorViewModel.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        );
      }

      final exhibitor = exhibitorViewModel.exhibitorDetails;
      if (exhibitor == null) {
        return const Center(child: Text('No exhibitor details found'));
      }

      return CustomScrollView(
        slivers: [
          _buildHeaderSection(
            context: context,
            imageUrl: exhibitor.picUrl ?? 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
            logoText: _getInitials(exhibitor.name),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: AppColors.whiteColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: exhibitor.name,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 12),
                        AppText(
                          text: exhibitor.description,
                          fontSize: 13,
                          color: AppColors.darkgrey,
                        ),
                        const SizedBox(height: 24),

                        AppText(
                          text: 'Contact Information',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 16),
                        if (exhibitor.website != null && exhibitor.website!.isNotEmpty)
                          _buildContactItem(
                            icon: Icons.language,
                            title: 'Website',
                            subtitle: exhibitor.website!,
                            iconColor: AppColors.darkBlue,
                          ),
                        if (exhibitor.email != null && exhibitor.email!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildContactItem(
                            icon: Icons.email,
                            title: 'Email',
                            subtitle: exhibitor.email!,
                            iconColor: AppColors.darkBlue,
                          ),
                        ],
                        if (exhibitor.phone != null && exhibitor.phone!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildContactItem(
                            icon: Icons.phone,
                            title: 'Phone',
                            subtitle: exhibitor.phone!,
                            iconColor: AppColors.darkPurpleColor,
                          ),
                        ],
                        const SizedBox(height: 24),

                        AppText(
                          text: 'Location',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(height: 16),
                        _buildContactItem(
                          icon: Icons.location_on,
                          title: 'Location',
                          subtitle: exhibitor.location,
                          iconColor: AppColors.darkPurpleColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    color: AppColors.lightGreyColor,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (exhibitor.products.isNotEmpty) ...[
                          AppText(
                            text: 'Products & Services',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                          const SizedBox(height: 16),
                          ...exhibitor.products.map((product) =>
                              _buildServiceItem(
                                icon: Icons.business_center,
                                title: product.title,
                                description: product.description,
                                iconColor: AppColors.lightBlue,
                              )
                          ).toList(),
                          const SizedBox(height: 24),
                        ],

                        if (exhibitor.booths.isNotEmpty) ...[
                          AppText(
                            text: 'Booth Information',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                          const SizedBox(height: 16),
                          ...exhibitor.booths.map((booth) =>
                              Column(
                                children: [
                                  _buildBoothInfo('Booth Number', booth.boothNumber),
                                  _buildBoothInfo('Hall Location', booth.boothLocation),
                                  if (booth.openTime != null && booth.openTime!.isNotEmpty)
                                    _buildBoothInfo('Opening Time', booth.openTime!),
                                  const SizedBox(height: 16),

                                  Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.containerGreyColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: AppText(
                                        text: 'Booth Layout',
                                        fontSize: 14,
                                        color: AppColors.darkgrey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  if (booth.mapLink != null && booth.mapLink!.isNotEmpty)
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.lightGreyColor),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: _buildMapSection(booth),
                                      ),
                                    ),
                                  const SizedBox(height: 16),

                                  if (booth.mapLink != null && booth.mapLink!.isNotEmpty)
                                    CustomButton(
                                      text: 'Get Directions',
                                      onPressed: () {
                                        _launchMap(booth.mapLink!);
                                      },
                                      backgroundColor: AppColors.primaryColor,
                                      height: 48,
                                    ),
                                  const SizedBox(height: 16),
                                ],
                              )
                          ).toList(),
                          const SizedBox(height: 24),
                        ],

                        if (exhibitor.socialMedia.isNotEmpty) ...[
                          AppText(
                            text: 'Follow Us',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                          const SizedBox(height: 16),
                          ...exhibitor.socialMedia.map((social) =>
                              _buildSocialMediaButton(social)
                          ).toList(),
                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHeaderSection({
    required BuildContext context,
    required String imageUrl,
    required String logoText,
  }) {
    return SliverAppBar(
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
          child: AppText(
            text: widget.type == 'sponsor' ? 'Sponsor Details' : 'Exhibitor Details',
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
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
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
                  text: logoText,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final cleanedName = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    final names = cleanedName.split(' ');

    if (names.length == 1) {
      final singleName = names[0];
      return singleName.length > 2
          ? singleName.substring(0, 2).toUpperCase()
          : singleName.toUpperCase();
    }

    String initials = '';
    for (int i = 0; i < names.length && initials.length < 2; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0];
      }
    }

    return initials.toUpperCase();
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: title,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              AppText(
                text: subtitle,
                fontSize: 12,
                color: AppColors.darkgrey,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String position,
    String? imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGreyColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryColor,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? AppText(
              text: _getInitials(name),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.whiteColor,
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: name,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor,
                ),
                AppText(
                  text: position,
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

  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor,
                ),
                AppText(
                  text: description,
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

  Widget _buildBoothInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: label,
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          AppText(
            text: value,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(Booth booth) {
    final coordinates = _extractCoordinatesFromMapLink(booth.mapLink ?? '');
    final staticMapUrl = _getMapBoxStaticMapUrl(coordinates['lat']!, coordinates['lng']!);

    return GestureDetector(
      onTap: () => _openFullScreenMap(booth.mapLink!, booth.boothLocation),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(staticMapUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, size: 16, color: AppColors.primaryColor),
                  const SizedBox(width: 6),
                  AppText(
                    text: 'Tap to View Map',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          ),
          if (booth.distance != null && booth.distance!.isNotEmpty)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  text: booth.distance!,
                  fontSize: 10,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, double> _extractCoordinatesFromMapLink(String mapLink) {
    try {
      print('=== Extracting coordinates from: $mapLink ===');

      final uri = Uri.parse(mapLink);

      // Try query parameter 'q' (e.g., ?q=lat,lng)
      if (uri.queryParameters.containsKey('q')) {
        final q = uri.queryParameters['q']!;
        final coords = q.split(',');
        if (coords.length >= 2) {
          final lat = double.tryParse(coords[0].trim());
          final lng = double.tryParse(coords[1].trim());
          if (lat != null && lng != null) {
            print('=== Found coordinates from query: $lat, $lng ===');
            return {'lat': lat, 'lng': lng};
          }
        }
      }

      // Try path with @lat,lng format (e.g., /@31.5204,74.3587)
      final atMatch = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)').firstMatch(mapLink);
      if (atMatch != null) {
        final lat = double.tryParse(atMatch.group(1)!);
        final lng = double.tryParse(atMatch.group(2)!);
        if (lat != null && lng != null) {
          print('=== Found coordinates from @ format: $lat, $lng ===');
          return {'lat': lat, 'lng': lng};
        }
      }

      // Try /place/ format
      final placeMatch = RegExp(r'/place/([^/]+)/@(-?\d+\.?\d*),(-?\d+\.?\d*)').firstMatch(mapLink);
      if (placeMatch != null) {
        final lat = double.tryParse(placeMatch.group(2)!);
        final lng = double.tryParse(placeMatch.group(3)!);
        if (lat != null && lng != null) {
          print('=== Found coordinates from place format: $lat, $lng ===');
          return {'lat': lat, 'lng': lng};
        }
      }

      print('=== Could not extract coordinates, using default ===');
    } catch (e) {
      print('=== Error extracting coordinates: $e ===');
    }

    // Default to Lahore, Pakistan
    return {'lat': 31.5204, 'lng': 74.3587};
  }

  String _getMapBoxStaticMapUrl(double lat, double lng) {
    const accessToken = "pk.eyJ1Ijoicml6aWVhZ2xpbmVzIiwiYSI6ImNtaGc3aGt4bjBlb2YycnNjbDBldnh3ejUifQ.sAY7q13HBaq80LoOUAT0oQ";
    const styleId = "streets-v11";
    const width = 600;
    const height = 300;
    const zoom = 15;

    final marker = "pin-s+ff0000($lng,$lat)";

    return "https://api.mapbox.com/styles/v1/mapbox/$styleId/static/$marker/$lng,$lat,$zoom/${width}x$height@2x?access_token=$accessToken&attribution=false&logo=false";
  }

  void _openFullScreenMap(String mapLink, String locationName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.lightGreyColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.map, color: AppColors.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppText(
                          text: 'Open $locationName in Maps',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ],
                  ),
                ),

                _buildMapOption(
                  icon: Icons.map_outlined,
                  title: 'Google Maps',
                  subtitle: 'Open in Google Maps app',
                  onTap: () => _launchInGoogleMaps(mapLink),
                ),

                _buildMapOption(
                  icon: Icons.navigation,
                  title: 'Apple Maps',
                  subtitle: 'Open in Apple Maps',
                  onTap: () => _launchInAppleMaps(mapLink),
                ),

                _buildMapOption(
                  icon: Icons.public,
                  title: 'Web Browser',
                  subtitle: 'Open in web browser',
                  onTap: () => _launchInBrowser(mapLink),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () => Get.back(),
                    backgroundColor: AppColors.lightGreyColor,
                    textColor: AppColors.darkgrey,
                    height: 48,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: AppText(
        text: title,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.blackColor,
      ),
      subtitle: AppText(
        text: subtitle,
        fontSize: 12,
        color: AppColors.darkgrey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  void _launchInGoogleMaps(String mapLink) async {
    try {
      Get.back();

      String googleMapsUrl = mapLink;
      if (!mapLink.contains('maps.google.com') && !mapLink.contains('goo.gl/maps')) {
        googleMapsUrl = 'https://maps.google.com/?q=${Uri.encodeComponent(mapLink)}';
      }

      final Uri url = Uri.parse(googleMapsUrl);

      final googleMapsAppUrl = Uri.parse('comgooglemaps://?q=${Uri.encodeComponent(url.toString())}');
      if (await canLaunchUrl(googleMapsAppUrl)) {
        await launchUrl(googleMapsAppUrl);
        return;
      }

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Google Maps');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open Google Maps: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _launchInAppleMaps(String mapLink) async {
    try {
      Get.back();

      final appleMapsUrl = Uri.parse('https://maps.apple.com/?q=${Uri.encodeComponent(mapLink)}');

      if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Apple Maps');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open Apple Maps: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _launchInBrowser(String mapLink) async {
    try {
      Get.back();

      final Uri url = Uri.parse(mapLink);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch browser');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open in browser: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _launchMap(String mapLink) async {
    try {
      final Uri url = Uri.parse(mapLink);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch map',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open map: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildSocialMediaButton(SocialMedia social) {
    String imagePath = Images.linkedin2;
    Color backgroundColor = AppColors.lightBlue;

    if (social.name.toLowerCase().contains('twitter')) {
      imagePath = Images.twitterIcon;
    } else if (social.name.toLowerCase().contains('youtube')) {
      imagePath = Images.youtube;
      backgroundColor = AppColors.primaryColor;
    } else if (social.name.toLowerCase().contains('facebook')) {
      imagePath = Images.facebookimage;
    }

    return Column(
      children: [
        CustomButton(
          text: social.name,
          onPressed: () {
            _launchWebsite(social.website);
          },
          imagePath: imagePath,
          backgroundColor: backgroundColor,
          height: 44,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _launchWebsite(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch website',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open website: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}