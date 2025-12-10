import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../all_opted_users_screen.dart';
import '../app_colors/app_colors.dart';
import '../custom_widgets/app_text.dart';
import '../custom_widgets/custom_text_field.dart';
import '../data/response_models/seeing_opted_user_model.dart';
import '../utils/shared_preference.dart';
import '../view_model/connection_request_send_viewmodel.dart';
import '../view_model/seeing_opted_user_viewmodel.dart';

class OptedInUsersList extends StatefulWidget {
  const OptedInUsersList({super.key});

  @override
  State<OptedInUsersList> createState() => _OptedInUsersListState();
}

class _OptedInUsersListState extends State<OptedInUsersList> {
  final SeeingOptedUserViewModel _usersViewModel = Get.put(SeeingOptedUserViewModel());
  final ConnectionRequestSendViewModel _connectionViewModel = Get.put(ConnectionRequestSendViewModel());

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showSearch = false;

  int? _eventId;
  bool _loadingEventId = true;

  @override
  void initState() {
    super.initState();
    _loadEventIdAndUsers();
  }

  Future<void> _loadEventIdAndUsers() async {
    try {
      _eventId = await SharedPrefsHelper.getLatestEventId();
      if (_eventId != null) {
        await _usersViewModel.loadOptedInUsers(_eventId!);
      }
    } finally {
      setState(() {
        _loadingEventId = false;
      });
    }
  }

  Future<void> _sendConnectionRequest(int receiverId, String userName) async {
    final result = await _connectionViewModel.sendConnectionRequest(receiverId);

    Color backgroundColor;
    switch (result['type']) {
      case 'success':
        backgroundColor = AppColors.successColor;
        break;
      case 'warning':
        backgroundColor = Colors.orange;
        break;
      case 'info':
        backgroundColor = Colors.blue;
        break;
      default:
        backgroundColor = AppColors.errorColor;
    }

    Get.snackbar(
      result['success'] ? 'Success' : 'Notice',
      result['message'],
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  List<SeeingOptedUser> get _displayedUsers {
    if (_searchQuery.isNotEmpty) {
      // Show all users matching search
      return _usersViewModel.users.where((user) =>
      user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.role.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    } else {
      // Show only first 3 users by default
      return _usersViewModel.users.take(3).toList();
    }
  }

  bool get _hasMoreUsers => _usersViewModel.users.length > 3 && _searchQuery.isEmpty;
  bool get _showViewAllButton => _hasMoreUsers && !_showSearch;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.mediumGreyColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Header with Search Toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.mediumGreyColor.withOpacity(0.3),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: 'Directory',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _showSearch ? Icons.close : Icons.search,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _showSearch = !_showSearch;
                              if (!_showSearch) {
                                _searchController.clear();
                                _searchQuery = '';
                              }
                            });
                          },
                          tooltip: _showSearch ? 'Close search' : 'Search',
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh, color: AppColors.primaryColor),
                          onPressed: _loadEventIdAndUsers,
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                  ],
                ),

                // Search Bar (conditionally shown)
                if (_showSearch)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CustomTextField(
                      hintText: "Search by name or role...",
                      controller: _searchController,
                      suffixIcon: Icons.search,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Dynamic Content Area
          Obx(() {
            if (_loadingEventId) {
              return _buildLoadingEventId();
            }

            if (_eventId == null) {
              return _buildNoEventError();
            }

            if (_usersViewModel.isLoading.value) {
              return _buildLoadingUsers();
            }

            if (_usersViewModel.errorMessage.isNotEmpty) {
              return _buildErrorState();
            }

            if (_usersViewModel.users.isEmpty) {
              return _buildEmptyState();
            }

            return _buildUsersList();
          }),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    final displayedUsers = _displayedUsers;
    final totalUsers = _usersViewModel.users.length;
    final showingAll = _searchQuery.isNotEmpty || _showSearch;

    return Column(
      children: [
        // Results Info
        if (showingAll || _showSearch)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.mediumGreyColor.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: showingAll
                      ? "${displayedUsers.length} of $totalUsers participant${totalUsers == 1 ? '' : 's'}"
                      : "Showing ${displayedUsers.length} of $totalUsers",
                  fontSize: 12,
                  color: AppColors.darkgrey,
                  fontWeight: FontWeight.w500,
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    child: Row(
                      children: [
                        AppText(
                          text: "Clear",
                          fontSize: 12,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.clear, size: 14, color: AppColors.primaryColor),
                      ],
                    ),
                  ),
              ],
            ),
          ),

        // User List
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              if (displayedUsers.isEmpty && _searchQuery.isNotEmpty)
                _buildNoSearchResults()
              else
                ...displayedUsers.map((user) => _buildUserItem(user)).toList(),

              // View All Button (when not searching and more than 3 users)
              if (_showViewAllButton)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => AllOptedUsersScreen(users: _usersViewModel.users));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryColor,
                        side: BorderSide(color: AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('View All Participants'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoSearchResults() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: AppColors.darkgrey),
          const SizedBox(height: 12),
          AppText(
            text: 'No participants found',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 4),
          AppText(
            text: 'Try different search terms',
            fontSize: 12,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingEventId() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('Loading event...'),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNoEventError() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(Icons.event_busy, color: AppColors.errorColor, size: 36),
          const SizedBox(height: 12),
          AppText(
            text: 'No Event Found',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.errorColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Join an event to see participants',
            fontSize: 12,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingUsers() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('Loading participants...'),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.errorColor, size: 36),
          const SizedBox(height: 12),
          AppText(
            text: 'Failed to load',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.errorColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Try refreshing',
            fontSize: 12,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          Icon(Icons.people_outline, size: 36, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No participants found',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserItem(SeeingOptedUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.mediumGreyColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: ClipOval(
              child: user.file != null
                  ? Image.network(
                user.file!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              )
                  : _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(width: 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: user.name,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: AppText(
                    text: user.role,
                    fontSize: 12,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Connect Text Button
          Obx(() {
            final isSending = _connectionViewModel.isSendingRequest(user.id);
            return TextButton(
              onPressed: isSending ? null : () => _sendConnectionRequest(user.id, user.name),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: isSending
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'Connect',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.mediumGreyColor,
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}