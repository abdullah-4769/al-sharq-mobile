import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/custom_widgets/custom_text_field.dart';
import 'package:al_sharq_conference/utils/shared_preference.dart';

import '../../data/request_models/participant_Request_models/forms/participant_forum_chat_model.dart';
import '../../view_model/participant_viewmodel/forms/participant_forum_chat_viewmodel.dart';

class ForumChatScreen extends StatefulWidget {
  final int forumId;
  final String forumTitle;
  final String forumTag;

  const ForumChatScreen({
    super.key,
    required this.forumId,
    required this.forumTitle,
    required this.forumTag,
  });

  @override
  State<ForumChatScreen> createState() => _ForumChatScreenState();
}

class _ForumChatScreenState extends State<ForumChatScreen> {
  final ParticipantForumChatViewModel viewModel = Get.put(ParticipantForumChatViewModel());
  final TextEditingController commentController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  int? _currentUserId;
  int? _replyingToCommentId;
  String _replyingToUserName = '';

  @override
  void initState() {
    super.initState();
    print('=== ForumChatScreen initialized for forum: ${widget.forumId} ===');
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      _currentUserId = await SharedPrefsHelper.getUserId();
      print('=== Current user ID: $_currentUserId ===');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.fetchForumDetails(widget.forumId);
      });
    } catch (e) {
      print('=== Error getting user data: $e ===');
    }
  }

  void _addComment() async {
    if (commentController.text.trim().isEmpty) return;

    if (_currentUserId == null) {
      _showQuickMessage('Please login to comment');
      return;
    }

    final content = commentController.text.trim();
    final parentCommentId = _replyingToCommentId;

    print('=== Adding comment: "$content", parentCommentId: $parentCommentId ===');

    commentController.clear();
    _cancelReply();

    // Optimistic UI update
    final tempComment = Comment(
      id: -1, // Temporary ID
      forumId: widget.forumId,
      userId: _currentUserId!,
      content: content,
      parentCommentId: parentCommentId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      user: User(
        id: _currentUserId!,
        name: 'You', // Temporary name
        role: 'participant',
        file: '',
      ),
      replies: [],
    );

    // Add to UI immediately
    _addCommentToUI(tempComment);

    final success = await viewModel.addComment(
      forumId: widget.forumId,
      userId: _currentUserId!,
      content: content,
      parentCommentId: parentCommentId,
    );

    if (!success) {
      // Remove optimistic update if failed
      _removeCommentFromUI(-1);
      _showQuickMessage('Failed to add comment');
    } else {
      print('=== Comment added successfully, refreshing data ===');
      // Refresh to get the real comment with proper ID and user data
      viewModel.fetchForumDetails(widget.forumId);
    }
  }
  void _addCommentToUI(Comment comment) {
    final forum = viewModel.forumDetail.value;

    if (comment.parentCommentId != null) {
      // Find parent comment and add reply
      final newComments = List<Comment>.from(forum.comments);
      bool replyAdded = false;

      for (int i = 0; i < newComments.length; i++) {
        if (newComments[i].id == comment.parentCommentId) {
          final newReplies = List<Comment>.from(newComments[i].replies);
          newReplies.add(comment);
          newComments[i] = newComments[i].copyWith(replies: newReplies);
          replyAdded = true;
          break;
        }

        // Also check replies of this comment for nested replies
        for (int j = 0; j < newComments[i].replies.length; j++) {
          if (newComments[i].replies[j].id == comment.parentCommentId) {
            final newReplies = List<Comment>.from(newComments[i].replies[j].replies);
            newReplies.add(comment);
            final updatedReply = newComments[i].replies[j].copyWith(replies: newReplies);
            final parentReplies = List<Comment>.from(newComments[i].replies);
            parentReplies[j] = updatedReply;
            newComments[i] = newComments[i].copyWith(replies: parentReplies);
            replyAdded = true;
            break;
          }
        }
        if (replyAdded) break;
      }

      if (replyAdded) {
        viewModel.forumDetail.value = forum.copyWith(comments: newComments);
      } else {
        // If parent not found, add as top-level comment
        final newComments = List<Comment>.from(forum.comments);
        newComments.insert(0, comment);
        viewModel.forumDetail.value = forum.copyWith(comments: newComments);
      }
    } else {
      // Add as top-level comment
      final newComments = List<Comment>.from(forum.comments);
      newComments.insert(0, comment);
      viewModel.forumDetail.value = forum.copyWith(comments: newComments);
    }
  }

  void _removeCommentFromUI(int commentId) {
    final forum = viewModel.forumDetail.value;
    final newComments = _removeCommentFromList(forum.comments, commentId);
    viewModel.forumDetail.value = forum.copyWith(comments: newComments);
  }

  List<Comment> _removeCommentFromList(List<Comment> comments, int commentId) {
    return comments.where((comment) {
      if (comment.id == commentId) {
        return false; // Remove this comment
      }

      // Check and update replies
      if (comment.replies.isNotEmpty) {
        final newReplies = _removeCommentFromList(comment.replies, commentId);
        if (newReplies.length != comment.replies.length) {
          // A reply was removed, update the comment
          comment = comment.copyWith(replies: newReplies);
        }
      }

      return true;
    }).toList();
  }

  void _deleteComment(int commentId) async {
    // Store comment for rollback
    final commentToDelete = _findCommentById(commentId);
    if (commentToDelete == null) return;

    // Remove from UI immediately
    _removeCommentFromUI(commentId);

    final success = await viewModel.deleteComment(commentId, widget.forumId);

    if (!success) {
      // Add back if failed
      _addCommentToUI(commentToDelete);
      _showQuickMessage('Failed to delete comment');
    }
  }

  Comment? _findCommentById(int commentId) {
    return _findCommentInList(viewModel.forumDetail.value.comments, commentId);
  }

  Comment? _findCommentInList(List<Comment> comments, int commentId) {
    for (final comment in comments) {
      if (comment.id == commentId) return comment;

      if (comment.replies.isNotEmpty) {
        final foundInReplies = _findCommentInList(comment.replies, commentId);
        if (foundInReplies != null) return foundInReplies;
      }
    }
    return null;
  }

  void _setReplyTo(Comment comment) {
    print('=== Setting reply to comment: ${comment.id}, user: ${comment.user.name} ===');

    setState(() {
      _replyingToCommentId = comment.id;
      _replyingToUserName = comment.user.name;
    });

    commentController.text = '@${comment.user.name} ';
    commentController.selection = TextSelection.collapsed(offset: commentController.text.length);

    // Auto focus and scroll to comment box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUserName = '';
    });
  }

  void _showQuickMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildUserAvatar(String imageUrl, {double radius = 16}) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // Handle image loading errors
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Add your Al Sharq logo here if needed
            // Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 8),
            AppText(
              text: 'Forum Discussion',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryColor),
            onPressed: () {
              viewModel.refreshForum(widget.forumId);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Forum Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Discussion Title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(
                    text: 'Form Discussion',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Discussion Title
                AppText(
                  text: widget.forumTitle,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                const SizedBox(height: 8),

                // Topic Tag
                AppText(
                  text: widget.forumTag,
                  fontSize: 14,
                  color: AppColors.darkgrey,
                ),
                const SizedBox(height: 16),

                // Stats and Creator Row
                Row(
                  children: [
                    // Stats
                    Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.people_outline,
                          value: '${viewModel.forumDetail.value.totalUsers}',
                          label: 'Users',
                        ),
                        const SizedBox(width: 16),
                        _buildStatItem(
                          icon: Icons.chat_bubble_outline,
                          value: '${viewModel.forumDetail.value.totalComments}',
                          label: 'Comments',
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Creator
                    Row(
                      children: [
                        _buildUserAvatar(viewModel.forumDetail.value.user.file, radius: 14),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: 'Created by ${viewModel.forumDetail.value.user.name}',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            AppText(
                              text: viewModel.forumDetail.value.user.role,
                              fontSize: 10,
                              color: AppColors.darkgrey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (viewModel.isLoading.value && viewModel.forumDetail.value.id == 0) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading discussion...', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              }

              if (viewModel.errorMessage.value.isNotEmpty && viewModel.forumDetail.value.id == 0) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: AppText(
                          text: viewModel.errorMessage.value,
                          color: Colors.red,
                          fontSize: 16,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Retry',
                        onPressed: () => viewModel.fetchForumDetails(widget.forumId),
                        backgroundColor: AppColors.primaryColor,
                        width: 120,
                      ),
                    ],
                  ),
                );
              }

              final forum = viewModel.forumDetail.value;

              return Column(
                children: [
                  // Comments Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                    ),
                    child: Row(
                      children: [
                        AppText(
                          text: 'Comments',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: AppText(
                            text: '${forum.comments.length}',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Comments List
                  Expanded(
                    child: forum.comments.isEmpty
                        ? _buildEmptyComments()
                        : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: forum.comments.length,
                      itemBuilder: (context, index) {
                        return _buildComment(forum.comments[index], 0);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),

          // Reply Indicator
          if (_replyingToCommentId != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.reply, size: 16, color: AppColors.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      text: 'Replying to $_replyingToUserName',
                      fontSize: 12,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Icon(Icons.close, size: 16, color: AppColors.primaryColor),
                  ),
                ],
              ),
            ),

          // Add Comment Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 40,
                      maxHeight: 80,
                    ),
                    child: TextField(
                      controller: commentController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() {
                  return viewModel.isAddingComment.value
                      ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                      : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _addComment,
                        child: const Center(
                          child: Icon(
                            Icons.send,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String value, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.darkgrey),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: value,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            AppText(
              text: label,
              fontSize: 10,
              color: AppColors.darkgrey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyComments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No comments yet',
            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to start the discussion!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(Comment comment, int level) {
    final isCurrentUserComment = comment.user.id == _currentUserId;
    final hasReplies = comment.replies.isNotEmpty;
    final isReply = level > 0;
    final isReplyingToThis = _replyingToCommentId == comment.id;

    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 16.0 : 0,
        top: 8,
        right: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isReplyingToThis
                  ? AppColors.primaryColor.withOpacity(0.05)
                  : (isReply ? Colors.grey[50] : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: isReplyingToThis
                  ? Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 2)
                  : (isReply ? null : Border.all(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info and Time
                Row(
                  children: [
                    _buildUserAvatar(comment.user.file, radius: 12),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              AppText(
                                text: comment.user.name,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              if (isCurrentUserComment) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: AppText(
                                    text: 'You',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          AppText(
                            text: comment.user.role,
                            fontSize: 10,
                            color: AppColors.darkgrey,
                          ),
                        ],
                      ),
                    ),
                    AppText(
                      text: _formatTimeAgo(comment.createdAt),
                      fontSize: 10,
                      color: AppColors.darkgrey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Comment Content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: AppText(
                    text: comment.content,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),

                // Actions
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _setReplyTo(comment),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.reply,
                              size: 12,
                              color: isReplyingToThis ? AppColors.primaryColor : AppColors.darkgrey,
                            ),
                            const SizedBox(width: 4),
                            AppText(
                              text: 'Reply',
                              fontSize: 11,
                              color: isReplyingToThis ? AppColors.primaryColor : AppColors.darkgrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isCurrentUserComment) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _deleteComment(comment.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 12, color: Colors.red),
                              const SizedBox(width: 4),
                              AppText(
                                text: 'Delete',
                                fontSize: 11,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Replies
          if (hasReplies) ...[
            const SizedBox(height: 4),
            ...comment.replies.map((reply) => _buildComment(reply, level + 1)),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}

// Add these extension methods to your Comment class
extension CommentCopyWith on Comment {
  Comment copyWith({
    int? id,
    int? forumId,
    int? userId,
    String? content,
    int? parentCommentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      forumId: forumId ?? this.forumId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      replies: replies ?? this.replies,
    );
  }
}

extension ForumDetailCopyWith on ForumDetail {
  ForumDetail copyWith({
    int? id,
    int? sessionId,
    User? user,
    String? title,
    String? content,
    String? tag,
    int? totalUsers,
    int? totalComments,
    List<Comment>? comments,
  }) {
    return ForumDetail(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      user: user ?? this.user,
      title: title ?? this.title,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      totalUsers: totalUsers ?? this.totalUsers,
      totalComments: totalComments ?? this.totalComments,
      comments: comments ?? this.comments,
    );
  }
}