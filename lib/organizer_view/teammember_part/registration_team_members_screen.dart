// lib/organizer_view/registration_team/registration_team_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/images/images.dart';
import '../../data/response_models/organizer_response_models/registration_team_response_model.dart';
import '../../qr_code/gallery_qr_scanner_service.dart';
import '../../qr_code/registration_team_scanner_screen.dart';
import '../../registration_team/participant_detail_by_id_screen.dart';
import '../../view_model/organizer_viewmodels/registration_team_viewmodel.dart';
import 'add_registration_team_member_screen.dart';

class RegistrationTeamScreen extends StatefulWidget {
  const RegistrationTeamScreen({super.key});

  @override
  State<RegistrationTeamScreen> createState() => _RegistrationTeamScreenState();
}

class _RegistrationTeamScreenState extends State<RegistrationTeamScreen> {
  final RegistrationTeamViewModel _viewModel = Get.put(RegistrationTeamViewModel());
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _viewModel.loadMoreTeamMembers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          Images.alsharqLogo,
          height: 35,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        // Add scan button in app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.black87),
            onPressed: _showScanOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Registration Team',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(() => Text(
                              '${_viewModel.filteredTeamMembers.length} ${_viewModel.filteredTeamMembers.length == 1 ? 'member' : 'members'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            )),
                          ],
                        ),
                      ),
                      // Add Member Button
                      Material(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 2,
                        child: InkWell(
                          onTap: () async {
                            final result = await Get.to(() => AddRegistrationTeamMemberScreen());
                            if (result == true) {
                              _viewModel.refreshData();
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.person_add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add Member',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search and Filter Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by name, email or organization...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                              suffixIcon: Obx(() => _viewModel.searchQuery.value.isNotEmpty
                                  ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey[400]),
                                onPressed: () {
                                  _searchController.clear();
                                  _viewModel.searchQuery.value = '';
                                  _viewModel.searchTeamMembers();
                                },
                              )
                                  : const SizedBox()),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onChanged: (value) {
                              _viewModel.searchQuery.value = value;
                              _viewModel.searchTeamMembers();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filter Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.filter_list, color: AppColors.primaryColor),
                          onPressed: () => _showFilterBottomSheet(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Time Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Obx(() => Row(
                    children: [
                      _buildFilterChip('Daily', 0),
                      const SizedBox(width: 8),
                      _buildFilterChip('Weekly', 1),
                      const SizedBox(width: 8),
                      _buildFilterChip('10 Days', 2),
                      const SizedBox(width: 8),
                      _buildFilterChip('90 Days', 3),
                      const SizedBox(width: 8),
                      _buildFilterChip('All Time', 4),
                    ],
                  )),
                ),
              ],
            ),
          ),

          // Team Members List
          Expanded(
            child: Obx(() {
              if (_viewModel.isLoading.value && _viewModel.filteredTeamMembers.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryColor),
                      SizedBox(height: 16),
                      Text(
                        'Loading team members...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              if (_viewModel.filteredTeamMembers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        'No team members found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _viewModel.searchQuery.value.isNotEmpty
                            ? 'Try adjusting your search'
                            : 'Add your first team member',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Get.to(() => AddRegistrationTeamMemberScreen());
                          if (result == true) {
                            _viewModel.refreshData();
                          }
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Team Member'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _viewModel.refreshData,
                color: AppColors.primaryColor,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _viewModel.filteredTeamMembers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _viewModel.filteredTeamMembers.length) {
                      return _viewModel.hasMore.value
                          ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                          : const SizedBox(height: 16);
                    }

                    final member = _viewModel.filteredTeamMembers[index];
                    return _buildTeamMemberCard(member, index);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _viewModel.selectedFilter.value == index;

    return InkWell(
      onTap: () {
        _viewModel.selectedFilter.value = index;
        _viewModel.applyFilter();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
          )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }



  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'organizer':
        return AppColors.primaryColor;
      case 'volunteer':
        return Colors.green;
      case 'staff':
        return Colors.orange;
      default:
        return AppColors.primaryColor; // Default color for registrationteam
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showMemberDetails(RegistrationTeamMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MemberDetailBottomSheet(
        member: member,
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(member);
        },
        onViewDetails: () {
          Navigator.pop(context);
          _viewMemberDetails(member);
        },
      ),
    );
  }

  // New method to navigate to detailed view screen
  void _viewMemberDetails(RegistrationTeamMember member) {
    Get.to(() => ParticipantDetailByIdScreen(
      userId: member.id,
    ));
  }

  void _confirmDelete(RegistrationTeamMember member) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Team Member'),
        content: Text('Are you sure you want to remove ${member.name} from the registration team?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _viewModel.removeTeamMember(member.id);
              Get.snackbar(
                'Success',
                '${member.name} has been removed',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Time Period',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => Column(
              children: [
                _buildFilterOption('Daily', 0),
                _buildFilterOption('Weekly', 1),
                _buildFilterOption('10 Days', 2),
                _buildFilterOption('90 Days', 3),
                _buildFilterOption('All Time', 4),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, int index) {
    final isSelected = _viewModel.selectedFilter.value == index;

    return ListTile(
      onTap: () {
        _viewModel.selectedFilter.value = index;
        _viewModel.applyFilter();
        Navigator.pop(context);
      },
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.primaryColor : Colors.grey,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primaryColor : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard(RegistrationTeamMember member, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showMemberDetails(member),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar with actual image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _buildMemberAvatar(member),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Member Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      member.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                ],
                              ),
                              const SizedBox(height: 8),

                              // Email with icon
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Icon(Icons.email, size: 14, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      member.email,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              // Organization if available
                              if (member.organization != null && member.organization!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Icon(Icons.business, size: 14, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        member.organization!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 8),

                              // Date
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatDate(member.createdAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Arrow Icon
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// Add this method to show the actual image
  Widget _buildMemberAvatar(RegistrationTeamMember member) {
    // Check if member has a photo or file URL
    String? imageUrl = member.photo ?? member.file;

    if (imageUrl == null || imageUrl.isEmpty) {
      // Show initials with gradient background
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Show network image with proper error handling
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Fallback to initials if image fails to load
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Center(
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
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
                        Navigator.pop(context);
                        _startCameraScan();
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
                        Navigator.pop(context);
                        await _startGalleryScan();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
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

  Future<void> _startCameraScan() async {
    try {
      await Get.to(() => const RegistrationTeamScannerScreen());
    } catch (e) {
      print('Camera scan error: $e');
    }
  }

  Future<void> _startGalleryScan() async {
    try {
      final data = await GalleryQRScannerService.scanQRFromGallery(context);
      if (data != null) {
        GalleryQRScannerService.showParticipantDetails(data);
      }
    } catch (e) {
      print('Gallery scan error: $e');
      Get.snackbar(
        'Error',
        'Failed to scan from gallery',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

// Also update the MemberDetailBottomSheet to show actual image
class MemberDetailBottomSheet extends StatelessWidget {
  final RegistrationTeamMember member;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;

  const MemberDetailBottomSheet({
    super.key,
    required this.member,
    required this.onDelete,
    required this.onViewDetails,
  });

  Widget _buildMemberAvatar() {
    // Check if member has a photo or file URL
    String? imageUrl = member.photo ?? member.file;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            member.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  member.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildMemberAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registration Team Member',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getRoleColor(member.role),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildDetailRow(Icons.email, 'Email', member.email),
          if (member.organization != null && member.organization!.isNotEmpty)
            _buildDetailRow(Icons.business, 'Organization', member.organization!),
          _buildDetailRow(Icons.calendar_today, 'Joined', _formatFullDate(member.createdAt)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.remove_red_eye),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: const BorderSide(color: AppColors.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getRoleColor(String role) {
    return AppColors.primaryColor; // Fixed color for registration team
  }


}