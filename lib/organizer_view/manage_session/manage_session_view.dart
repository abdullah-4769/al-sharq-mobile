import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';

import '../../data/response_models/organizer_response_models/organizer_all_session_details_show_model.dart';
import '../add_new_session/add_new_session.dart';
import '../../view_model/organizer_viewmodels/organizer_all_session_details_show_viewmodel.dart';
import '../../view_model/organizer_viewmodels/organizer_delete_session_viewmodel.dart';

class OrganizerManageSessionsScreen extends StatefulWidget {
  const OrganizerManageSessionsScreen({super.key});

  @override
  State<OrganizerManageSessionsScreen> createState() => _OrganizerManageSessionsScreenState();
}

class _OrganizerManageSessionsScreenState extends State<OrganizerManageSessionsScreen> {
  final TextEditingController searchController = TextEditingController();
  final OrganizerAllSessionDetailsShowViewModel _sessionsViewModel = Get.put(OrganizerAllSessionDetailsShowViewModel());
  final OrganizerDeleteSessionViewModel _deleteViewModel = Get.put(OrganizerDeleteSessionViewModel());

  String selectedFilter = 'All';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    _sessionsViewModel.getAllSessions();
  }

  List<OrganizerAllSessionDetailsShowModel> get filteredSessions {
    var sessions = _sessionsViewModel.sessionsList;

    // Apply status filter
    if (selectedFilter != 'All') {
      sessions = sessions.where((session) => session.status == selectedFilter).toList().obs;
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      sessions = sessions.where((session) =>
      session.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          session.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          session.primarySpeaker.toLowerCase().contains(searchQuery.toLowerCase()) ||
          session.location.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList().obs;
    }

    return sessions;
  }

  String get currentDate {
    final sessions = filteredSessions;
    if (sessions.isNotEmpty) {
      return sessions.first.formattedDate;
    }
    return 'No sessions available';
  }

  void _deleteSession(int sessionId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(
          text: 'Delete Session',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        content: AppText(
          text: 'Are you sure you want to delete this session? This action cannot be undone.',
          fontSize: 14,
          color: AppColors.darkgrey,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: AppText(
              text: 'Cancel',
              fontSize: 14,
              color: AppColors.darkgrey,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: AppText(
              text: 'Delete',
              fontSize: 14,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _deleteViewModel.deleteSession(sessionId);
      if (success) {
        _loadSessions(); // Refresh the list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppText(
          text: 'Manage Sessions',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: 'Search sessions...',
                    controller: searchController,
                    suffixIcon: Icons.search,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.tune, color: AppColors.primaryColor),
              ],
            ),
          ),

          // Stats Bar
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(() {
              return Row(
                children: [
                  _buildStatChip('All', _sessionsViewModel.getTotalSessions().toString(), Colors.blue, selectedFilter == 'All'),
                  const SizedBox(width: 12),
                  _buildStatChip('Upcoming', _sessionsViewModel.getUpcomingSessions().toString(), Colors.green, selectedFilter == 'Upcoming'),
                  const SizedBox(width: 12),
                  _buildStatChip('Completed', _sessionsViewModel.getCompletedSessions().toString(), Colors.orange, selectedFilter == 'Completed'),
                ],
              );
            }),
          ),

          // Add New Session Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Create New Session',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddNewSessionScreen()),
                );
              },
              backgroundColor: AppColors.primaryColor,
              height: 48,
            ),
          ),

          // Date Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AppText(
              text: currentDate,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkgrey,
            ),
          ),

          // View All Link
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedFilter = 'All';
                      searchQuery = '';
                      searchController.clear();
                    });
                  },
                  child: const AppText(
                    text: 'View All',
                    fontSize: 14,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Sessions List
          Expanded(
            child: Obx(() {
              if (_sessionsViewModel.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                );
              }

              if (_sessionsViewModel.error.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      AppText(
                        text: 'Failed to load sessions',
                        fontSize: 16,
                        color: AppColors.darkgrey,
                      ),
                      const SizedBox(height: 8),
                      CustomButton(
                        text: 'Retry',
                        onPressed: _loadSessions,
                        backgroundColor: AppColors.primaryColor,
                        height: 40,
                      ),
                    ],
                  ),
                );
              }

              final sessions = filteredSessions;

              if (sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 48, color: AppColors.mediumGreyColor),
                      const SizedBox(height: 16),
                      AppText(
                        text: searchQuery.isNotEmpty ? 'No sessions found' : 'No sessions available',
                        fontSize: 16,
                        color: AppColors.darkgrey,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return _buildSessionCard(session);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String count, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.mediumGreyColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              text: label,
              fontSize: 12, // ✅ Valid font size
              fontWeight: FontWeight.w500,
              color: isSelected ? color : AppColors.darkgrey,
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text( // ✅ Using regular Text widget for very small count
                count,
                style: TextStyle(
                  fontSize: 8, // Very small font size for count
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSessionCard(OrganizerAllSessionDetailsShowModel session) {
    final hasSpeakerImage = session.speakers.isNotEmpty &&
        session.speakers.first.file != null &&
        session.speakers.first.file!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  text: session.title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.bookmark_border, color: AppColors.primaryColor, size: 20),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              // Speaker Avatar with Image
              if (hasSpeakerImage)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryColor, width: 1),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      session.speakers.first.file!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 12,
                            color: AppColors.primaryColor,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 12,
                            color: AppColors.primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: 12,
                    color: AppColors.primaryColor,
                  ),
                ),

              const SizedBox(width: 8),
              Expanded(
                child: AppText(
                  text: session.primarySpeaker,
                  fontSize: 12,
                  color: AppColors.darkgrey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: session.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  text: session.status,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: session.statusColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          AppText(
            text: session.description.isNotEmpty ? session.description : 'No description available',
            fontSize: 12,
            color: AppColors.darkgrey,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildSessionInfo(Icons.access_time, session.formattedTime),
              _buildSessionInfo(Icons.timer, session.duration),
              _buildSessionInfo(Icons.location_on, session.location),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // In the _buildSessionCard method, update the edit button:
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddNewSessionScreen(
                          sessionId: session.id,
                          isEditMode: true,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const AppText(
                    text: 'Edit',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _deleteViewModel.isLoading.value ? null : () => _deleteSession(session.id),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.darkgrey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _deleteViewModel.isLoading.value
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const AppText(
                    text: 'Delete',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkgrey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.darkgrey),
        const SizedBox(width: 4),
        AppText(
          text: text,
          fontSize: 10, // ✅ Valid font size (minimum allowed)
          color: AppColors.darkgrey,
        ),
      ],
    );
  }
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}