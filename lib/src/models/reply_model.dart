import 'post_model.dart';

class Reply {
  final int id;
  final int userId;
  final String body;
  final int commentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserData user;
  final int replyLikesCount;
  final bool isLikedByMe;
  final bool isMine;

  Reply({
    required this.id,
    required this.userId,
    required this.body,
    required this.commentId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.replyLikesCount,
    required this.isLikedByMe,
    required this.isMine,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      body: json['body'] ?? '',
      commentId: json['commentId'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      user: UserData.fromJson(json['user'] ?? {}),
      replyLikesCount:
          json['_count'] != null ? json['_count']['replyLikes'] ?? 0 : 0,
      isLikedByMe: json['isLikedByMe'] ?? false,
      isMine: json['isMine'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'body': body,
      'commentId': commentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
      '_count': {
        'replyLikes': replyLikesCount,
      },
      'isLikedByMe': isLikedByMe,
      'isMine': isMine,
    };
  }

  Reply copyWith({
    int? id,
    int? userId,
    String? body,
    int? commentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserData? user,
    int? replyLikesCount,
    bool? isLikedByMe,
    bool? isMine,
  }) {
    return Reply(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        body: body ?? this.body,
        commentId: commentId ?? this.commentId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        user: user ?? this.user,
        replyLikesCount: replyLikesCount ?? this.replyLikesCount,
        isLikedByMe: isLikedByMe ?? this.isLikedByMe,
        isMine: isMine ?? this.isMine);
  }
}
