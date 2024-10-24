import 'package:ayahhebat/src/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/comment_api.dart';
import '../models/comment_model.dart';
import '../models/reply_model.dart';

enum CommentState { initial, loading, loaded, error }

enum EditCommentState { initial, loading, loaded, error }

enum ReplyState { initial, loading, loaded, error }

enum EditReplyState { initial, loading, loaded, error }

enum IconState { initial, loading, loaded }

class CommentProvider extends ChangeNotifier {
  List<Comment> _comments = [];
  CommentState _commentState = CommentState.initial;
  EditCommentState _editCommentState = EditCommentState.initial;
  ReplyState _replyState = ReplyState.initial;
  EditReplyState _editReplyState = EditReplyState.initial;
  IconState _iconState = IconState.initial;
  String? _errorCommentMessage;
  String? _errorEditCommentMessage;
  String? _errorReplyMessage;
  String? _errorEditReplyMessage;

  bool _hasMoreData = true;

  List<Comment> get comments => _comments;
  CommentState get commentState => _commentState;
  EditCommentState get editCommentState => _editCommentState;
  ReplyState get replyState => _replyState;
  EditReplyState get editReplyState => _editReplyState;
  IconState get iconState => _iconState;
  String? get errorCommentMessage => _errorCommentMessage;
  String? get errorEditCommentMessage => _errorEditCommentMessage;
  String? get errorReplyMessage => _errorReplyMessage;
  String? get errorEditReplyMessage => _errorEditReplyMessage;
  bool get hasMoreData => _hasMoreData;

  final CommentApi _commentApi = CommentApi();

  Future<void> fetchComments(
      {int limit = 10,
      int offset = 0,
      sort = "likes",
      required int postId}) async {
    _commentState = CommentState.loading;
    notifyListeners();

    try {
      _hasMoreData = true;
      _comments = await _commentApi.getComments(
          postId: postId, limit: limit, sort: sort, offset: offset);

      _commentState = CommentState.loaded;
    } catch (e) {
      _errorCommentMessage = e.toString();
      _commentState = CommentState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMoreComments(
      {int limit = 5,
      int offset = 0,
      sort = "likes",
      required int postId}) async {
    if (!_hasMoreData) return;

    _commentState = CommentState.loading;
    notifyListeners();

    try {
      if (offset == 0) {
        _comments = await _commentApi.getComments(
            postId: postId, limit: limit, sort: sort, offset: offset);
      } else {
        List<Comment> newComments = [];

        newComments = await _commentApi.getComments(
            postId: postId, limit: limit, sort: sort, offset: offset);
        _comments.addAll(newComments);

        if (newComments.length < limit) {
          _hasMoreData = false;
        }
      }

      _commentState = CommentState.loaded;
    } catch (e) {
      _errorCommentMessage = e.toString();
      _commentState = CommentState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> clearComments() async {
    print("clear");
    _commentState = CommentState.loading;
    notifyListeners();

    try {
      _comments.clear();
      _hasMoreData = true;
      _commentState = CommentState.initial;
    } catch (e) {
      _errorCommentMessage = e.toString();
      _commentState = CommentState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> createComment(
      String body, int postId, BuildContext context) async {
    _editCommentState = EditCommentState.loading;
    _iconState = IconState.loading;
    notifyListeners();

    try {
      final newComment = await _commentApi.createComment(body, postId);
      _comments.insert(0, newComment);
      Provider.of<PostProvider>(context).addCommentsCount(postId);
      _editCommentState = EditCommentState.loaded;
    } catch (e) {
      _errorEditCommentMessage = e.toString();
      _editCommentState = EditCommentState.error;
    } finally {
      _iconState = IconState.loaded;
      notifyListeners();
    }
  }

  Future<void> editComment(String body, int commentId) async {
    _editCommentState = EditCommentState.loading;
    _iconState = IconState.loading;
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
      _errorEditCommentMessage = e.toString();
      _editCommentState = EditCommentState.error;
    } finally {
      _iconState = IconState.loaded;
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
      _errorEditCommentMessage = e.toString();
      _editCommentState = EditCommentState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> likeComment(int commentId) async {
    if (_editCommentState == EditCommentState.loading) return;

    _editCommentState = EditCommentState.loading;
    notifyListeners();

    try {
      final index = _comments.indexWhere((comment) => comment.id == commentId);
      if (index != -1) {
        bool isCurrentlyLiked = _comments[index].isLikedByMe;

        if (isCurrentlyLiked) {
          bool unlike = await _commentApi.likeComment(commentId);
          if (unlike) {
            _comments[index] = _comments[index].copyWith(
                isLikedByMe: false,
                count: _comments[index].count.copyWith(
                    commentLikes: _comments[index].count.commentLikes - 1));
          }
        } else {
          bool like = await _commentApi.likeComment(commentId);
          if (like) {
            _comments[index] = _comments[index].copyWith(
                isLikedByMe: true,
                count: _comments[index].count.copyWith(
                    commentLikes: _comments[index].count.commentLikes + 1));
          }
        }
        _editCommentState = EditCommentState.loaded;
      }
    } catch (e) {
      _errorEditCommentMessage = e.toString();
      _editCommentState = EditCommentState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchReplies(
      {int limit = 5, int offset = 1, required int commentId}) async {
    if (_replyState == ReplyState.loading) return;

    _replyState = ReplyState.loading;
    notifyListeners();
    print("reply state" + _replyState.toString());

    try {
      List<Reply> newReplies = await _commentApi.getReplies(
          limit: limit, offset: offset, commentId: commentId);

      final index = _comments.indexWhere((comment) => comment.id == commentId);
      if (index != -1) {
        List<Reply> existingReplies = _comments[index].replies;

        List<Reply> combinedReplies = [...existingReplies, ...newReplies];

        int countReplies = _comments[index].count.replies - newReplies.length;

        print(countReplies);

        _comments[index] = _comments[index].copyWith(
            replies: combinedReplies,
            count: _comments[index].count.copyWith(replies: countReplies));
      }
      _replyState = ReplyState.loaded;
      // print(_replyState);
      // print(_comments[index]);
    } catch (e) {
      _errorReplyMessage = e.toString();
      _replyState = ReplyState.error;
    } finally {
      print("reply state end " + _replyState.toString());
      // print("reply state end " + _errorReplyMessage.toString());
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
      }
      _editReplyState = EditReplyState.loaded;
    } catch (e) {
      _errorEditReplyMessage = e.toString();
      _editReplyState = EditReplyState.error;
    } finally {
      notifyListeners();
    }
  }

  // new feature

  Future<void> createReply(
      String body, int commentId, BuildContext context) async {
    if (_editReplyState == EditReplyState.loading) return;

    _editReplyState = EditReplyState.loading;
    _iconState = IconState.loading;
    notifyListeners();

    try {
      final newReply = await _commentApi.createReply(body, commentId);

      final index = _comments.indexWhere((comment) => comment.id == commentId);

      final newList = _comments[index].replies;
      newList.insert(0, newReply);

      _comments[index] = _comments[index].copyWith(
        replies: newList,
      );

      final postId = _comments[index].postId;
      // count: _comments[index]
      //     .count
      //     .copyWith(replies: _comments[index].count.replies + 1)

      Provider.of<PostProvider>(context).addCommentsCount(postId);
      _editReplyState = EditReplyState.loaded;
    } catch (e) {
      _errorEditReplyMessage = e.toString();
      _editReplyState = EditReplyState.error;
    } finally {
      _iconState = IconState.loaded;
      notifyListeners();
    }
  }

  Future<void> createReplyToReply(
      String body, int commentId, int replyId, BuildContext context) async {
    _editReplyState = EditReplyState.loading;
    _iconState = IconState.loading;
    print("masuk");
    print("body " + body);
    print("commentId " + commentId.toString());
    print("replyId " + replyId.toString());
    notifyListeners();

    try {
      final newReply = await _commentApi.createReply(body, commentId);

      final index = _comments.indexWhere((comment) => comment.id == commentId);

      final newList = _comments[index].replies;
      newList.insert(replyId + 1, newReply);

      _comments[index] = _comments[index].copyWith(
        replies: newList,
      );

      final postId = _comments[index].postId;

      Provider.of<PostProvider>(context, listen: false)
          .addCommentsCount(postId);

      _editReplyState = EditReplyState.loaded;
    } catch (e) {
      _errorEditReplyMessage = e.toString();
      _editReplyState = EditReplyState.error;
    } finally {
      _iconState = IconState.loaded;
      notifyListeners();
    }
  }

  Future<void> editReply(String body, int replyId, int commentId) async {
    _editReplyState = EditReplyState.loading;
    _iconState = IconState.loading;
    notifyListeners();

    try {
      await _commentApi.editReply(body, replyId);
      final commentIndex =
          _comments.indexWhere((comment) => comment.id == commentId);
      // cari dulu commentnya setelah itu baru cari reply di comment tersebut

      if (commentIndex != -1) {
        final replyIndex = _comments[commentIndex]
            .replies
            .indexWhere((reply) => reply.id == replyId);

        if (replyIndex != -1) {
          _comments[commentIndex].replies[replyIndex] =
              _comments[commentIndex].replies[replyIndex].copyWith(body: body);
        }
        _editReplyState = EditReplyState.loaded;
      }
    } catch (e) {
      _errorEditReplyMessage = e.toString();
      _editReplyState = EditReplyState.error;
    } finally {
      _iconState = IconState.loaded;
      notifyListeners();
    }
  }

  Future<void> deleteReply(int replyId, int commentId) async {
    _editReplyState = EditReplyState.loading;
    notifyListeners();

    try {
      await _commentApi.deleteReply(replyId);
      final commentIndex =
          _comments.indexWhere((comment) => comment.id == commentId);

      if (commentIndex != -1) {
        final replyIndex = _comments[commentIndex]
            .replies
            .indexWhere((reply) => reply.id == replyId);

        if (replyIndex != -1) {
          _comments[commentIndex].replies.removeAt(replyIndex);
        }
      }

      _editReplyState = EditReplyState.loaded;
    } catch (e) {
      _errorEditReplyMessage = e.toString();
      _editReplyState = EditReplyState.error;
    } finally {
      notifyListeners();
    }
  }

  // pr tolong untuk setiap error yang jenisnya beda atau dari state yang berbeda maka buatkan message errornya masing masing (done)
}
