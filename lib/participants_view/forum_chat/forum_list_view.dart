import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import '../../repository/participants_repository/form/forums_list_repo.dart';
import '../../view_model/participant_viewmodel/forms/forums_list_viewmodel.dart';
import '../forum_chat/forum_chat_screen.dart';

class ForumsListScreen extends StatefulWidget {
  final int sessionId;

  const ForumsListScreen({super.key, required this.sessionId});

  @override
  State<ForumsListScreen> createState() => _ForumsListScreenState();
}

class _ForumsListScreenState extends State<ForumsListScreen> {
  final ForumsListViewModel viewModel = Get.put(ForumsListViewModel());
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('=== ForumsListScreen initialized with sessionId: ${widget.sessionId} ===');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchForums(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const AppText(
          text: 'Session Discussions',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryColor),
            onPressed: () {
              viewModel.refreshForums(widget.sessionId);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (viewModel.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading discussions...', style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        }

        if (viewModel.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                AppText(
                  text: viewModel.errorMessage.value,
                  color: Colors.red,
                  fontSize: 16,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Retry',
                  onPressed: () => viewModel.fetchForums(widget.sessionId),
                  backgroundColor: AppColors.primaryColor,
                //  width: 120,
                ),
              ],
            ),
          );
        }

        final forumsData = viewModel.forumsData.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.darkgrey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search topics...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppColors.darkgrey),
                        ),
                        onChanged: (value) {
                          // Implement search functionality if needed
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Session Title
              AppText(
                text: forumsData.title,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              const SizedBox(height: 16),

              // Trending Topics
              const AppText(
                text: 'Key Topics',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: forumsData.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AppText(
                    text: tag,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),

              const Divider(),
              const SizedBox(height: 16),

              // All Discussions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppText(
                    text: 'All Discussions',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  AppText(
                    text: '${forumsData.forums.length} discussion(s)',
                    fontSize: 14,
                    color: AppColors.darkgrey,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (forumsData.forums.isEmpty)
                _buildEmptyState()
              else
                ...forumsData.forums.map((forum) => _buildForumCard(forum)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.forum_outlined, size: 64, color: AppColors.darkgrey),
          const SizedBox(height: 16),
          const Text(
            'No discussions yet',
            style: TextStyle(fontSize: 16, color: AppColors.darkgrey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to start a discussion!',
            style: TextStyle(fontSize: 14, color: AppColors.darkgrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForumCard(Forum forum) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tag
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lightPurpleColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText(
                    text: forum.tag,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkPurpleColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: forum.status == 'APPROVED'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppText(
                  text: forum.status == 'APPROVED' ? 'Approved' : 'Pending',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: forum.status == 'APPROVED' ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          AppText(
            text: forum.title,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          const SizedBox(height: 8),

          // Content
          AppText(
            text: forum.content,
            fontSize: 14,
            color: AppColors.darkgrey,
          ),
          const SizedBox(height: 12),

          // Stats and Creator - FIXED VERSION
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 16, color: AppColors.darkgrey),
                  const SizedBox(width: 4),
                  AppText(
                    text: '${forum.totalUsers} Members',
                    fontSize: 12,
                    color: AppColors.darkgrey,
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.darkgrey),
                  const SizedBox(width: 4),
                  AppText(
                    text: '${forum.totalComments} Posts',
                    fontSize: 12,
                    color: AppColors.darkgrey,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Creator
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(forum.creator.file),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: AppText(
                      text: 'Created by ${forum.creator.name}',
                      fontSize: 12,
                      color: AppColors.darkgrey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Join Button
          CustomButton(
            text: forum.status == 'APPROVED' ? 'Join Discussion' : 'Pending Approval',
            onPressed: forum.status == 'APPROVED'
                ? () => _joinForum(forum)
                : null,
            backgroundColor: forum.status == 'APPROVED'
                ? AppColors.primaryColor
                : AppColors.darkgrey,
            height: 40,
          ),
        ],
      ),
    );
  }

  void _joinForum(Forum forum) {
    print('=== Joining forum: ${forum.forumId} - ${forum.title} ===');
    Get.to(() => ForumChatScreen(
      forumId: forum.forumId,
      forumTitle: forum.title,
      forumTag: forum.tag,
    ));
  }
}