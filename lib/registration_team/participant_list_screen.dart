import 'dart:async';

import 'package:al_sharq_conference/registration_team/participant_detail_by_id_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';

import '../data/response_models/registration_team_model/participant_response_model.dart';
import '../organizer_view/organizer_dashboard/participant_detail_screen.dart';
import '../qr_code/gallery_qr_scanner_service.dart';
import '../qr_code/participant_qr_dialog.dart';
import '../qr_code/registration_team_scanner_screen.dart';
import '../view_model/registration_team_viewmodels/participant_list_viewmodel.dart';

class ParticipantListScreen extends StatefulWidget {
  const ParticipantListScreen({super.key});

  @override
  State<ParticipantListScreen> createState() => _ParticipantListScreenState();
}

class _ParticipantListScreenState extends State<ParticipantListScreen> {
  final ParticipantListViewModel _viewModel = ParticipantListViewModel();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel.fetchParticipants();

    // Setup scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!_viewModel.isLoading.value && _viewModel.hasMore.value) {
          _viewModel.loadMoreParticipants();
        }
      }
    });

    // Setup search listener
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        _viewModel.searchQuery.value = '';
        _viewModel.fetchParticipants();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: const AppText(
          text: 'Participants List',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        // Add scan button in app bar as well
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
            onPressed: () {
              _showScanOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(),

          // Stats Cards
          _buildStatsSection(),

          // Filter Chips
          _buildFilterChips(),

          // Participants List
          Expanded(
            child: _buildParticipantsList(),
          ),
        ],
      ),
      // Add floating action button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showScanOptions();
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const AppText(
          text: 'Scan QR',
          fontSize: 14,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildSearchFilterSection() {
    Timer? _debounce;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by name, email, or organization...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      // Cancel previous timer
                      if (_debounce?.isActive ?? false) _debounce?.cancel();

                      // Set new timer
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        if (value.isNotEmpty) {
                          _viewModel.searchQuery.value = value;
                          _viewModel.searchParticipants();
                        } else {
                          _viewModel.searchQuery.value = '';
                          _viewModel.fetchParticipants();
                        }
                      });
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _viewModel.searchQuery.value = '';
                      _viewModel.fetchParticipants();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Participants',
                _viewModel.totalParticipants.value.toString(),
                Icons.people,
                AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Sessions Bookmark',
                _viewModel.totalBookmarks.value.toString(),
                Icons.bookmark,
                Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Sessions Registration',
                _viewModel.totalSessionRegistrations.value.toString(),
                Icons.event_note,
                Colors.green,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText(
            text: value,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          const SizedBox(height: 4),
          AppText(
            text: title,
            fontSize: 11,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() {
          return Row(
            children: [
              _buildFilterChip('Daily', 0, _viewModel.selectedFilter.value == 0),
              const SizedBox(width: 8),
              _buildFilterChip('Weekly', 1, _viewModel.selectedFilter.value == 1),
              const SizedBox(width: 8),
              _buildFilterChip('10 Days', 2, _viewModel.selectedFilter.value == 2),
              const SizedBox(width: 8),
              _buildFilterChip('90 Days', 3, _viewModel.selectedFilter.value == 3),
              const SizedBox(width: 8),
              _buildFilterChip('All Time', 4, _viewModel.selectedFilter.value == 4),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        _viewModel.selectedFilter.value = index;
        _viewModel.applyFilter();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: AppText(
          text: label,
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
  Widget _buildParticipantsList() {
    return Obx(() {
      if (_viewModel.isLoading.value && _viewModel.filteredParticipants.isEmpty) { // Change this
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }

      if (_viewModel.filteredParticipants.isEmpty) { // Change this
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const AppText(
                text: 'No participants found',
                fontSize: 16,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              if (_searchController.text.isNotEmpty || _viewModel.selectedFilter.value != 4)
                ElevatedButton(
                  onPressed: () {
                    _searchController.clear();
                    _viewModel.selectedFilter.value = 4; // Reset to All Time
                    _viewModel.fetchParticipants();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const AppText(
                    text: 'Clear Filters',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async {
          _viewModel.fetchParticipants();
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _viewModel.filteredParticipants.length + (_viewModel.hasMore.value ? 1 : 0), // Change this
          itemBuilder: (context, index) {
            if (index == _viewModel.filteredParticipants.length) { // Change this
              return _viewModel.isLoading.value
                  ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                ),
              )
                  : const SizedBox.shrink();
            }

            final participant = _viewModel.filteredParticipants[index]; // Change this
            return _buildParticipantCard(participant);
          },
        ),
      );
    });
  }

  Widget _buildParticipantCard(Participant participant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildProfileAvatar(participant),
        title: AppText(
          text: participant.name,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            AppText(
              text: participant.email,
              fontSize: 12,
              color: Colors.grey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (participant.organization != null && participant.organization!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AppText(
                  text: participant.organization!,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          child: Row(
            children: [
              _buildActionButton(
                Icons.qr_code,
                AppColors.primaryColor,
                    () {
                  _showQRCode(participant);
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                Icons.visibility,
                Colors.blue,
                    () {
                      Get.to(() => ParticipantDetailByIdScreen(userId: participant.id));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(Participant participant) {
    if (participant.file != null && participant.file!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(participant.file!),
        backgroundColor: Colors.grey[200],
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.brown,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Scan QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose how you want to scan the QR code',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildScanOption(
                      icon: Icons.camera_alt,
                      title: 'Camera Scan',
                      subtitle: 'Scan using camera',
                      color: AppColors.primaryColor,
                      onTap: () {
                        Get.back();
                        Get.to(() => const RegistrationTeamScannerScreen());
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildScanOption(
                      icon: Icons.photo_library,
                      title: 'Gallery',
                      subtitle: 'Scan from gallery',
                      color: Colors.green,
                      onTap: () async {
                        Get.back();
                        final data = await GalleryQRScannerService.scanQRFromGallery(context);
                        if (data != null) {
                          GalleryQRScannerService.showParticipantDetails(data);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
  void _showQRCode(Participant participant) {
    Get.dialog(
      ParticipantQRDialog(participant: participant),
    );
  }
}