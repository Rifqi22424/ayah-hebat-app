class Post {
  final int id;
  final int userId;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserData user;
  final PostCount count;
  final bool isLikedByMe;
  final bool isDislikedByMe;
  final bool isMine;

  Post({
    required this.id,
    required this.userId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.count,
    required this.isLikedByMe,
    required this.isDislikedByMe,
    required this.isMine,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      body: json['body'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      user: UserData.fromJson(json['user'] ?? {}),
      count: PostCount.fromJson(json['_count'] ?? {}),
      isLikedByMe: json['isLikedByMe'] ?? false,
      isDislikedByMe: json['isDislikedByMe'] ?? false,
      isMine: json['isMine'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
      '_count': count.toJson(),
      'isLikedByMe': isLikedByMe,
      'isDislikedByMe': isDislikedByMe,
      'isMine': isMine,
    };
  }

  Post copyWith({
    int? id,
    int? userId,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserData? user,
    PostCount? count,
    bool? isLikedByMe,
    bool? isDislikedByMe,
    bool? isMine,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      count: count ?? this.count,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isDislikedByMe: isDislikedByMe ?? this.isDislikedByMe,
      isMine: isMine ?? this.isMine,
    );
  }
}

class UserData {
  final int id;
  final String email;
  final ProfileData profile;

  UserData({
    required this.id,
    required this.email,
    required this.profile,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      profile: ProfileData.fromJson(json['profile'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'profile': profile.toJson(),
    };
  }
}

class ProfileData {
  final String nama;
  final String photo;

  ProfileData({
    required this.nama,
    required this.photo,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      nama: json['nama'] ?? '',
      photo: json['photo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'photo': photo,
    };
  }
}

class PostCount {
  final int postLikes;
  final int postDislikes;
  final int comments;

  PostCount({
    required this.postLikes,
    required this.postDislikes,
    required this.comments,
  });

  factory PostCount.fromJson(Map<String, dynamic> json) {
    return PostCount(
      postLikes: json['postLikes'] ?? 0,
      postDislikes: json['postDislikes'] ?? 0,
      comments: json['comments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postLikes': postLikes,
      'postDislikes': postDislikes,
      'comments': comments,
    };
  }

  PostCount copyWith({
    int? postLikes,
    int? postDislikes,
    int? comments,
  }) {
    return PostCount(
      postLikes: postLikes ?? this.postLikes,
      postDislikes: postDislikes ?? this.postDislikes,
      comments: comments ?? this.comments,
    );
  }
}
