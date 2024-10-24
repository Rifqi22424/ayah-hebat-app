import 'post_model.dart';
import 'reply_model.dart';

class Comment {
  final int id;
  final int userId;
  final String body;
  final int postId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserData user;
  final CommentCount count;
  final List<Reply> replies;
  final bool isLikedByMe;
  final bool isMine;

  Comment({
    required this.id,
    required this.userId,
    required this.body,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.count,
    required this.replies,
    required this.isLikedByMe,
    required this.isMine,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      body: json['body'] ?? '',
      postId: json['postId'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      user: UserData.fromJson(json['user'] ?? {}),
      count: CommentCount.fromJson(json['_count'] ?? {}),
      isLikedByMe: json['isLikedByMe'] ?? false,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((replyJson) => Reply.fromJson(replyJson))
              .toList() ??
          [],
      isMine: json['isMine'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'body': body,
      'postId': postId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
      '_count': count.toJson(),
      'isLikedByMe': isLikedByMe,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'isMine': isMine,
    };
  }

  Comment copyWith({
    int? id,
    int? userId,
    String? body,
    int? postId,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserData? user,
    CommentCount? count,
    List<Reply>? replies,
    bool? isLikedByMe,
    bool? isMine,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      body: body ?? this.body,
      postId: postId ?? this.postId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      count: count ?? this.count,
      replies: replies ?? this.replies,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isMine: isMine ?? this.isMine,
    );
  }
}

class CommentCount {
  final int commentLikes;
  final int replies;

  CommentCount({
    required this.commentLikes,
    required this.replies,
  });

  factory CommentCount.fromJson(Map<String, dynamic> json) {
    return CommentCount(
      commentLikes: json['commentLikes'] ?? 0,
      replies: json['replies'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentLikes': commentLikes,
      'replies': replies,
    };
  }

  CommentCount copyWith({
    int? commentLikes,
    int? replies,
  }) {
    return CommentCount(
      commentLikes: commentLikes ?? this.commentLikes,
      replies: replies ?? this.replies,
    );
  }
}
