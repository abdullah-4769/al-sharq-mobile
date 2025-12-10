// Create a new file: lib/participants_view/all_opted_users_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app_colors/app_colors.dart';
import '../custom_widgets/app_text.dart';
import '../custom_widgets/custom_text_field.dart';
import '../data/response_models/seeing_opted_user_model.dart';
import '../utils/shared_preference.dart';
import '../view_model/connection_request_send_viewmodel.dart';

class AllOptedUsersScreen extends StatefulWidget {
  final List<SeeingOptedUser> users;

  const AllOptedUsersScreen({required this.users});

  @override
  State<AllOptedUsersScreen> createState() => _AllOptedUsersScreenState();
}

class _AllOptedUsersScreenState extends State<AllOptedUsersScreen> {
  final ConnectionRequestSendViewModel _connectionViewModel = Get.put(ConnectionRequestSendViewModel());
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SeeingOptedUser> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return widget.users;
    }
    return widget.users.where((user) =>
    user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        user.role.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Directory'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            CustomTextField(
              hintText: "Search by name or role...",
              controller: _searchController,
              suffixIcon: Icons.search,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Results Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: "${_filteredUsers.length} participant${_filteredUsers.length == 1 ? '' : 's'}",
                  fontSize: 14,
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
                          text: "Clear search",
                          fontSize: 13,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.clear, size: 16, color: AppColors.primaryColor),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Users List
            Expanded(
              child: _filteredUsers.isEmpty
                  ? _buildNoResults()
                  : ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return _buildUserItem(user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.darkgrey),
          const SizedBox(height: 16),
          AppText(
            text: 'No participants found',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
          const SizedBox(height: 8),
          AppText(
            text: 'Try adjusting your search terms',
            fontSize: 14,
            color: AppColors.darkgrey,
            textAlign: TextAlign.center,
          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: isSending
                  ? const SizedBox(
                width: 12,
                height: 12,
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