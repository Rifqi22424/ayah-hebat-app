import 'package:flutter/material.dart';
import '../api/post_api.dart';
import '../models/post_model.dart';

enum PostState { inital, loading, error, loaded }

enum EditPostState { inital, loading, error, loaded }

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  PostState _postState = PostState.inital;
  EditPostState _editPostState = EditPostState.inital;
  String? _errorMessage;
  String? _editErrorMessage;

  List<Post> get posts => _posts;
  PostState get postState => _postState;
  EditPostState get editPostState => _editPostState;
  String? get errorMessage => _errorMessage;
  String? get editErrorMessage => _editErrorMessage;

  final PostApi _postApi = PostApi();

  Future<void> fetchPosts({int limit = 5, int offset = 0}) async {
    _postState = PostState.loading;
    notifyListeners();
    print("loading fetching posts");

    try {
      if (offset == 0) {
        _posts = await _postApi.getPosts(limit: limit, offset: offset);
      } else {
        final _newPosts = await _postApi.getPosts(limit: limit, offset: offset);
        _posts.addAll(_newPosts);
      }
      _postState = PostState.loaded;
      print("fetching data posts");
    } catch (e) {
      _errorMessage = e.toString();
      _postState = PostState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> searchPosts(
      {int limit = 5, int offset = 0, required String query}) async {
    _postState = PostState.loading;
    notifyListeners();

    try {
      _posts = await _postApi.searchPosts(
          limit: limit, offset: offset, query: query);
      _postState = PostState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _postState = PostState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> createPost(String body) async {
    _editPostState = EditPostState.loading;
    notifyListeners();

    try {
      final newPost = await _postApi.createPost(body);
      _posts.insert(0, newPost);
      _editPostState = EditPostState.loaded;
    } catch (e) {
      _editErrorMessage = e.toString();
      _editPostState = EditPostState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> editPost(String body, int postId) async {
    _editPostState = EditPostState.loading;
    notifyListeners();

    try {
      final editedPost = await _postApi.editPost(body, postId);
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = editedPost;
        _editPostState = EditPostState.loaded;
      }
    } catch (e) {
      _editErrorMessage = e.toString();
      _editPostState = EditPostState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> deletePost(int postId) async {
    _editPostState = EditPostState.loading;
    notifyListeners();

    try {
      await _postApi.deletePost(postId);
      _posts.removeWhere((post) => post.id == postId);
      _editPostState = EditPostState.loaded;
    } catch (e) {
      _editErrorMessage = e.toString();
      _editPostState = EditPostState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> addCommentsCount(int postId) async {
    if (_editPostState == EditPostState.loading) return;

    _editPostState = EditPostState.loading;
    notifyListeners();

    final index = _posts.indexWhere((post) => post.id == postId);

    _posts[index] = _posts[index].copyWith(
      isLikedByMe: true,
      count: _posts[index]
          .count
          .copyWith(postLikes: _posts[index].count.postLikes + 1),
    );

    _editPostState = EditPostState.loaded;
    notifyListeners();
  }

  Future<void> likePost(int postId) async {
    if (_editPostState == EditPostState.loading) {
      return;
    }

    _editPostState = EditPostState.loading;
    notifyListeners();

    try {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        bool isCurrentlyLiked = _posts[index].isLikedByMe;

        if (!isCurrentlyLiked) {
          await _postApi.likePost(postId);
          _posts[index] = _posts[index].copyWith(
            isLikedByMe: true,
            count: _posts[index]
                .count
                .copyWith(postLikes: _posts[index].count.postLikes + 1),
          );
        } else {
          await _postApi.likePost(postId);
          _posts[index] = _posts[index].copyWith(
            isLikedByMe: false,
            count: _posts[index]
                .count
                .copyWith(postLikes: _posts[index].count.postLikes - 1),
          );
        }
        _editPostState = EditPostState.loaded;
      }
    } catch (e) {
      _editErrorMessage = e.toString();
      _editPostState = EditPostState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> dislikePost(int postId) async {
    if (_editPostState == EditPostState.loading) {
      return;
    }

    _editPostState = EditPostState.loading;
    notifyListeners();

    try {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        bool isCurrentlyDisliked = _posts[index].isDislikedByMe;

        if (!isCurrentlyDisliked) {
          await _postApi.dislikePost(postId);
          _posts[index] = _posts[index].copyWith(
            isDislikedByMe: true,
            count: _posts[index]
                .count
                .copyWith(postDislikes: _posts[index].count.postDislikes + 1),
          );
        } else {
          await _postApi.dislikePost(postId);
          _posts[index] = _posts[index].copyWith(
            isDislikedByMe: false,
            count: _posts[index]
                .count
                .copyWith(postDislikes: _posts[index].count.postDislikes - 1),
          );
        }
        _editPostState = EditPostState.loaded;
      }
    } catch (e) {
      _editErrorMessage = e.toString();
      _editPostState = EditPostState.error;
    } finally {
      notifyListeners();
    }
  }
}
