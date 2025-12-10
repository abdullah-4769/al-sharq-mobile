import 'package:get/get.dart';
import '../../../data/request_models/participant_Request_models/forms/participant_forum_chat_model.dart';
import '../../../repository/participants_repository/form/participant_forum_chat_repo.dart';


class ParticipantForumChatViewModel extends GetxController {
  final ParticipantForumChatRepository _repository = ParticipantForumChatRepository();

  final RxBool isLoading = false.obs;
  final RxBool isAddingComment = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ForumDetail> forumDetail = ForumDetail(
    id: 0,
    sessionId: 0,
    user: User(id: 0, name: '', role: '', file: ''),
    title: '',
    content: '',
    tag: '',
    totalUsers: 0,
    totalComments: 0,
    comments: [],
  ).obs;

  Future<void> fetchForumDetails(int forumId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('=== Fetching forum details for ID: $forumId ===');

      final details = await _repository.getForumDetails(forumId);
      forumDetail.value = details;

      print('=== Successfully loaded forum with ${details.comments.length} comments ===');

    } catch (e) {
      errorMessage.value = 'Failed to load forum: $e';
      print('=== Error loading forum: $e ===');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addComment({
    required int forumId,
    required int userId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      isAddingComment.value = true;
      errorMessage.value = '';

      final comment = AddCommentRequest(
        forumId: forumId,
        userId: userId,
        content: content,
        parentCommentId: parentCommentId,
      );

      await _repository.addComment(comment);

      // Refresh forum details to get the new comment
      await fetchForumDetails(forumId);
      return true;

    } catch (e) {
      errorMessage.value = 'Failed to add comment: $e';
      return false;
    } finally {
      isAddingComment.value = false;
    }
  }

  Future<bool> deleteComment(int commentId, int forumId) async {
    try {
      await _repository.deleteComment(commentId);

      // Refresh forum details to reflect the deletion
      await fetchForumDetails(forumId);
      return true;

    } catch (e) {
      errorMessage.value = 'Failed to delete comment: $e';
      return false;
    }
  }

  void refreshForum(int forumId) {
    fetchForumDetails(forumId);
  }
}