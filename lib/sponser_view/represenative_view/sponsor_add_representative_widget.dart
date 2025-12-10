import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';
import '../../custom_widgets/custom_button.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../../data/request_models/sponsor/sponsor_representative_model.dart';
import '../../data/response_models/organizer_response_models/organize_see_participants_short_info_model.dart';
import '../../view_model/organizer_viewmodels/organize_see_participants_short_info_viewmodel.dart';
import '../../view_model/sponsor_viewmodel/sponsor_representative_viewmodel.dart';

class SponsorAddRepresentativeWidget extends StatefulWidget {
  final int sponsorId;
  final VoidCallback onRepresentativeAdded;

  const SponsorAddRepresentativeWidget({
    super.key,
    required this.sponsorId,
    required this.onRepresentativeAdded,
  });

  @override
  State<SponsorAddRepresentativeWidget> createState() => _SponsorAddRepresentativeWidgetState();
}

class _SponsorAddRepresentativeWidgetState extends State<SponsorAddRepresentativeWidget> {
  final _titleController = TextEditingController();
  final _searchController = TextEditingController();
  final _participantsViewModel = Get.find<OrganizeSeeParticipantsShortInfoViewModel>();
  final _representativeViewModel = Get.find<SponsorRepresentativeViewModel>();

  OrganizeSeeParticipantsShortInfoUser? _selectedParticipant;
  List<OrganizeSeeParticipantsShortInfoUser> _filteredParticipants = [];

  @override
  void initState() {
    super.initState();
    _filteredParticipants = _participantsViewModel.users;
    _searchController.addListener(_filterParticipants);

    ever(_participantsViewModel.participantsData, (data) {
      setState(() {
        _filteredParticipants = _participantsViewModel.users;
      });
    });
  }

  void _filterParticipants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredParticipants = _participantsViewModel.users.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.organization?.toLowerCase().contains(query) == true ||
            user.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _selectParticipant(OrganizeSeeParticipantsShortInfoUser participant) {
    setState(() {
      _selectedParticipant = participant;
    });
  }

  void _unselectParticipant() {
    setState(() {
      _selectedParticipant = null;
    });
  }

  Future<void> _addRepresentative() async {
    if (_selectedParticipant == null) {
      Get.snackbar('Error', 'Please select a participant', backgroundColor: AppColors.errorColor);
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a display title', backgroundColor: AppColors.errorColor);
      return;
    }

    final representative = SponsorRepresentativeCreate(
      sponsorId: widget.sponsorId,
      userId: _selectedParticipant!.id,
      displayTitle: _titleController.text.trim(),
    );

    final success = await _representativeViewModel.addSponsorRepresentative(representative);

    if (success) {
      _titleController.clear();
      _searchController.clear();
      setState(() {
        _selectedParticipant = null;
      });
      widget.onRepresentativeAdded();
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.person_add, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  text: 'Add Representative',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppText(
            text: 'Select a participant and assign them a role in your organization',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 20),

          // Search Bar
          CustomTextField(
            controller: _searchController,
            hintText: 'Search by name, organization or email...',
            prefixIcon: Icons.search,
          ),
          const SizedBox(height: 20),

          // Dynamic Content Area
          _buildDynamicContent(),

          const SizedBox(height: 20),

          // Add Button
          Obx(() {
            return CustomButton(
              text: _representativeViewModel.addingRepresentative.value ? 'Adding Representative...' : 'Add Representative',
              onPressed: _representativeViewModel.addingRepresentative.value ? null : _addRepresentative,
              backgroundColor: AppColors.primaryColor,
              isLoading: _representativeViewModel.addingRepresentative.value,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDynamicContent() {
    return Obx(() {
      if (_participantsViewModel.isLoading.value) {
        return _buildLoadingState();
      }

      if (_participantsViewModel.error.value.isNotEmpty) {
        return _buildErrorState();
      }

      if (_selectedParticipant != null) {
        return _buildSelectedState();
      }

      return _buildParticipantsList();
    });
  }

  Widget _buildLoadingState() {
    return Container(
      height: 120,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          const SizedBox(height: 16),
          AppText(
            text: 'Loading participants...',
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.errorColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(
                  text: 'Failed to load participants',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText(
            text: _participantsViewModel.error.value,
            fontSize: 12,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Try Again',
            onPressed: () => _participantsViewModel.fetchParticipantsData(),
            backgroundColor: AppColors.errorColor,
            height: 36,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Participant Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor, width: 2),
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.mediumGreyColor,
                  backgroundImage: _selectedParticipant!.file != null
                      ? NetworkImage(_selectedParticipant!.file!)
                      : const AssetImage('assets/images/dr.jonthan.png') as ImageProvider,
                ),
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: _selectedParticipant!.name,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                    if (_selectedParticipant!.organization != null) ...[
                      const SizedBox(height: 4),
                      AppText(
                        text: _selectedParticipant!.organization!,
                        fontSize: 14,
                        color: AppColors.darkgrey,
                      ),
                    ],
                    const SizedBox(height: 2),
                    AppText(
                      text: _selectedParticipant!.email,
                      fontSize: 12,
                      color: AppColors.mediumGreyColor,
                    ),
                  ],
                ),
              ),

              // Change Button
              TextButton(
                onPressed: _unselectParticipant,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Change'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Title Input
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'Representative Title',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _titleController,
              hintText: 'e.g., Head of Marketing, Sales Manager, Technical Lead...',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a display title';
                }
                return null;
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantsList() {
    if (_filteredParticipants.isEmpty) {
      return _buildEmptyState();
    }

    // Calculate dynamic height based on item count
    final itemCount = _filteredParticipants.length;
    final maxHeight = 300.0;
    final itemHeight = 80.0;
    final calculatedHeight = itemCount > 3 ? maxHeight : itemCount * itemHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Select Participant (${_filteredParticipants.length} available)',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
        ),
        const SizedBox(height: 12),
        Container(
          height: calculatedHeight,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.mediumGreyColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _filteredParticipants.length == 1
              ? _buildSingleParticipant(_filteredParticipants.first)
              : ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _filteredParticipants.length,
            itemBuilder: (context, index) {
              final participant = _filteredParticipants[index];
              return _buildParticipantItem(participant);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSingleParticipant(OrganizeSeeParticipantsShortInfoUser participant) {
    return _buildParticipantItem(participant);
  }

  Widget _buildParticipantItem(OrganizeSeeParticipantsShortInfoUser participant) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectParticipant(participant),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.mediumGreyColor.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.mediumGreyColor.withOpacity(0.3)),
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.mediumGreyColor,
                  backgroundImage: participant.file != null
                      ? NetworkImage(participant.file!)
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: participant.name,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                    if (participant.organization != null) ...[
                      const SizedBox(height: 2),
                      AppText(
                        text: participant.organization!,
                        fontSize: 12,
                        color: AppColors.darkgrey,
                      ),
                    ],
                    const SizedBox(height: 2),
                    AppText(
                      text: participant.email,
                      fontSize: 11,
                      color: AppColors.mediumGreyColor,
                    ),
                  ],
                ),
              ),

              // Select Indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor),
                ),
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mediumGreyColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isEmpty ? Icons.people_outline : Icons.search_off,
            size: 48,
            color: AppColors.mediumGreyColor,
          ),
          const SizedBox(height: 16),
          AppText(
            text: _searchController.text.isEmpty
                ? 'No Participants Available'
                : 'No Matching Participants',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 8),
          AppText(
            text: _searchController.text.isEmpty
                ? 'There are no participants in the system yet'
                : 'Try adjusting your search criteria',
            fontSize: 14,
            color: AppColors.mediumGreyColor,
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 16),
            CustomButton(
              text: 'Refresh List',
              onPressed: () => _participantsViewModel.fetchParticipantsData(),
              backgroundColor: AppColors.primaryColor,
              height: 40,
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}