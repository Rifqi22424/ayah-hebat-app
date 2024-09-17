import 'package:flutter/material.dart';

import '../api/comment_api.dart';
import '../models/comment_model.dart';
import '../models/reply_model.dart';

enum CommentState { initial, loading, loaded, error }

enum EditCommentState { initial, loading, loaded, error }

enum ReplyState { initial, loading, loaded, error }

enum EditReplyState { initial, loading, loaded, error }

class CommentProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  CommentState _commentState = CommentState.initial;
  EditCommentState _editCommentState = EditCommentState.initial;
  ReplyState _replyState = ReplyState.initial;
  EditReplyState _editReplyState = EditReplyState.initial;
  String? _errorMessage;

  List<Comment> get comment => _comments;
  CommentState get commentState => _commentState;
  EditCommentState get editCommentState => _editCommentState;
  ReplyState get replyState => _replyState;
  EditReplyState get editReplyState => _editReplyState;
  String? get errorMessage => _errorMessage;

  final CommentApi _commentApi = CommentApi();

  Future<void> fetchComments({int limit = 5, int offset = 0}) async {
    _commentState = CommentState.loading;
    notifyListeners();

    try {
      _comments = await _commentApi.getComments(limit: limit, offset: offset);
      _commentState = CommentState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _commentState = CommentState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> createComment(String body, int commentId) async {
    _editCommentState = EditCommentState.loading;
    notifyListeners();

    try {
      final newComment = await _commentApi.createComment(body, commentId);
      _comments.insert(0, newComment);
      _editCommentState = EditCommentState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _editCommentState = EditCommentState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> editComment(String body, int commentId) async {
    _editCommentState = EditCommentState.loading;
    notifyListeners();

    try {
      await _commentApi.editComment(body, commentId);
      final index = _comments.indexWhere((comment) => comment.id == commentId);
      if (index != -1) {
        _comments[index] = _comments[index].copyWith(
          body: body,
          updatedAt: DateTime.now(),
        );
        _editCommentState = EditCommentState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _editCommentState = EditCommentState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteComment(int commentId) async {
    _editCommentState = EditCommentState.loading;
    notifyListeners();

    try {
      await _commentApi.deleteComment(commentId);
      _comments.removeWhere((comment) => comment.id == commentId);
      _editCommentState = EditCommentState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _editCommentState = EditCommentState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> likeComment(int commentId) async {
    _editCommentState = EditCommentState.loading;
    notifyListeners();

    try {
      final index = _comments.indexWhere((comment) => comment.id == commentId);
      if (index != -1) {
        bool isCurrentlyLiked = _comments[index].isLikedByMe;

        if (!isCurrentlyLiked) {
          await _commentApi.likeComment(commentId);
          _comments[index].copyWith(
              isLikedByMe: true,
              count: _comments[index].count.copyWith(
                  commentLikes: _comments[index].count.commentLikes + 1));
        } else {
          await _commentApi.likeComment(commentId);
          _comments[index].copyWith(
              isLikedByMe: false,
              count: _comments[index].count.copyWith(
                  commentLikes: _comments[index].count.commentLikes - 1));
        }
        _editCommentState = EditCommentState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _editCommentState = EditCommentState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchReplies(
      {int limit = 5, int offset = 1, required int commentId}) async {
    _replyState = ReplyState.loading;
    notifyListeners();

    try {
      List<Reply> replies =
          await _commentApi.getReplies(limit: limit, offset: offset);

      final index = _comments.indexWhere((comment) => comment.id == commentId);
      if (index != -1) {
        _comments[index].copyWith(
          replies: replies,
        );
      }
      _replyState = ReplyState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _replyState = ReplyState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> likeReply(int commentId, int replyId) async {
    _editReplyState = EditReplyState.loading;
    notifyListeners();

    try {
      final commentIndex =
          _comments.indexWhere((comment) => comment.id == commentId);
      if (commentIndex != -1) {
        final replyIndex = _comments[commentIndex]
            .replies
            .indexWhere((reply) => reply.id == replyId);
        if (replyIndex != -1) {
          bool isCurrentlyLiked =
              _comments[commentIndex].replies[replyIndex].isLikedByMe;      
          if (!isCurrentlyLiked) {
            _commentApi.likeReply(replyId);
            _comments[commentIndex].replies[replyIndex] =
                _comments[commentIndex].replies[replyIndex].copyWith(
                      isLikedByMe: true,
                      replyLikesCount: _comments[commentIndex]
                              .replies[replyIndex]
                              .replyLikesCount +
                          1,
                    );
          }
        } else {
          _commentApi.likeReply(replyId);
          _comments[commentIndex].replies[replyIndex] =
              _comments[commentIndex].replies[replyIndex].copyWith(
                    isLikedByMe: false,
                    replyLikesCount: _comments[commentIndex]
                            .replies[replyIndex]
                            .replyLikesCount -
                        1,
                  );
        }
      }
      _editReplyState = EditReplyState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _editReplyState = EditReplyState.error;
    } finally {
      notifyListeners();
    }
  }

  // new feature

  //   Future<void> createReply(String body, int commentId) async {
  //   _editReplyState = EditReplyState.loading;
  //   notifyListeners();

  //   try {
  //     final newReply = await _commentApi.createReply(body, commentId);
  //     final

  //     _comments.insert(0, newComment);
  //     _editReplyState = EditReplyState.loaded;
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     _editReplyState = EditReplyState.error;
  //   } finally {
  //     notifyListeners();
  //   }
  // }

  // Future<void> editComment(String body, int commentId) async {
  //   _editCommentState = EditCommentState.loading;
  //   notifyListeners();

  //   try {
  //     await _commentApi.editComment(body, commentId);
  //     final index = _comments.indexWhere((comment) => comment.id == commentId);
  //     if (index != -1) {
  //       _comments[index] = _comments[index].copyWith(
  //         body: body,
  //         updatedAt: DateTime.now(),
  //       );
  //       _editCommentState = EditCommentState.loaded;
  //     }
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     _editCommentState = EditCommentState.error;
  //   } finally {
  //     notifyListeners();
  //   }
  // }

  // Future<void> deleteComment(int commentId) async {
  //   _editCommentState = EditCommentState.loading;
  //   notifyListeners();

  //   try {
  //     await _commentApi.deleteComment(commentId);
  //     _comments.removeWhere((comment) => comment.id == commentId);
  //     _editCommentState = EditCommentState.loaded;
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     _editCommentState = EditCommentState.error;
  //   } finally {
  //     notifyListeners();
  //   }
  // }
}
