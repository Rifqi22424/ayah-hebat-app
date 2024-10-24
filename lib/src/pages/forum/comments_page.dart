import 'package:ayahhebat/main.dart';
import 'package:ayahhebat/src/widgets/app_bar_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import '../../models/reply_model.dart';
import '../../providers/comment_provider.dart';
import '../../providers/post_provider.dart';
import '../../utils/shared_preferences.dart';
import '../../widgets/expandable_text.dart';

class CommentsPage extends StatefulWidget {
  final Post post;
  final int indexPostProv;

  const CommentsPage(
      {super.key, required this.post, required this.indexPostProv});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  CommentProvider? _commentProvider;
  TextEditingController commentController = TextEditingController();
  Map<int, String> monthNames = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'Mei',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sept',
    10: 'Okt',
    11: 'Nov',
    12: 'Des',
  };

  final FocusNode _focusNode = FocusNode();

  bool isExpanded = false;
  bool loadingSendComment = false;

  bool isReply = false;
  bool isReplyComment = false;

  int replyToCommentId = 0;
  String replyToCommentName = "";

  int replyToReplyId = 0;
  String replyToReplyName = "";

  String filter = "Terbaru";
  String sort = "likes";
  final ScrollController _scrollController = ScrollController();

  int offset = 0;

  String timeAgo(DateTime inputDate) {
    final now = DateTime.now();
    final diff = now.difference(inputDate);
    if (diff.inDays >= 1) {
      return '${diff.inDays} hari yang lalu';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} menit yang lalu';
    } else {
      return 'baru saja';
    }
  }

  Future<void> onRefresh() async {
    String? token = await SharedPreferencesHelper.getToken();
    print(token);
    Provider.of<CommentProvider>(context, listen: false)
        .fetchComments(postId: widget.post.id, sort: sort);
    offset = 0;
  }

  void _sendComment(
      {required BuildContext context,
      required String body,
      required int? postId,
      required bool isComment,
      required int? commentId,
      required bool isReply,
      required int? replyId}) async {
    CommentProvider commentProvider =
        Provider.of<CommentProvider>(context, listen: false);

    if (isComment) {
      await commentProvider.createComment(body, postId!, context);
    } else if (isComment == false && isReply == false) {
      await commentProvider.createReply(body, commentId!, context);
    } else {
      await commentProvider.createReplyToReply(
          body, commentId!, replyId!, context);
    }

    bool isCommentLoaded = isComment &&
        commentProvider.editCommentState == EditCommentState.loaded;
    bool isReplyLoaded =
        !isComment && commentProvider.editReplyState == EditReplyState.loaded;

    if (isCommentLoaded || isReplyLoaded) {
      commentController.text = "";
      replyToCommentId = 0;
      replyToCommentName = "";
      this.isReply = false;
      FocusScope.of(context).unfocus();
    }

    setState(() {});
  }

  Widget replyToWidget() {
    String name = "";

    if (isReplyComment) {
      name = replyToCommentName;
    } else {
      name = replyToReplyName;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text("Replying to " + name),
          InkWell(
              onTap: () {
                replyToCommentId = 0;
                replyToCommentName = "";
                replyToReplyId = 0;
                replyToReplyName = "";
                isReply = false;
                commentController.text = "";

                setState(() {});
              },
              child: Icon(
                Icons.close,
                size: 18,
              ))
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _commentProvider = Provider.of<CommentProvider>(context, listen: false);
    _commentProvider?.fetchComments(postId: widget.post.id);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      offset += 5;
      Provider.of<CommentProvider>(context, listen: false).fetchMoreComments(
          postId: widget.post.id, offset: offset, sort: sort);
    }
  }

  @override
  void dispose() {
    _commentProvider?.clearComments();
    _focusNode.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("isReply " + isReply.toString());
    int index = widget.indexPostProv;
    Post post = widget.post;
    final String linkImage = "$serverPath/uploads/${post.user.profile.photo}";

    return PopScope(
      child: Scaffold(
        appBar: AppBarBuilder(
          title: "Forums",
          onBackButtonPressed: () async {
            Navigator.of(context).pop();
            // String? token = await SharedPreferencesHelper.getToken();
            // print(token);
          },
          showBackButton: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: onRefresh,
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.grey,
                                    radius: 24,
                                    foregroundImage: NetworkImage(
                                      linkImage,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    post.user.profile.nama,
                                    style: AppStyles.heading2TextStyle,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "${monthNames[post.createdAt.month]} ${post.createdAt.day}, ${post.createdAt.year}",
                                    style: AppStyles.hintTextStyle,
                                  )
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                post.body,
                                style: AppStyles.medium2TextStyle,
                              ),
                              SizedBox(height: 12),
                              Consumer<PostProvider>(
                                builder: (context, postProvider, child) {
                                  print(post.id);
                                  print(postProvider.posts.length);
                                  var postData = postProvider.posts[index];
                                  return Row(
                                    children: [
                                      SizedBox(
                                        child: Row(
                                          children: [
                                            Text(postData.count.comments
                                                .toString()),
                                            SizedBox(width: 2),
                                            IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(),
                                                onPressed: () async {
                                                  FocusScope.of(context)
                                                      .requestFocus(_focusNode);
                                                },
                                                icon: Image.asset(
                                                  "images/comment-icon.png",
                                                  height: 24,
                                                  width: 24,
                                                ))
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      SizedBox(
                                        child: Row(
                                          children: [
                                            Text(postData.count.postDislikes
                                                .toString()),
                                            SizedBox(width: 2),
                                            IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(),
                                                onPressed: () {
                                                  Provider.of<PostProvider>(
                                                          context,
                                                          listen: false)
                                                      .dislikePost(post.id);
                                                },
                                                icon: Image.asset(
                                                  postData.isDislikedByMe
                                                      ? "images/is-dislike-icon.png"
                                                      : "images/dislike-icon.png",
                                                  height: 24,
                                                  width: 24,
                                                ))
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      SizedBox(
                                        child: Row(
                                          children: [
                                            Text(postData.count.postLikes
                                                .toString()),
                                            SizedBox(width: 2),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                              onPressed: () {
                                                Provider.of<PostProvider>(
                                                        context,
                                                        listen: false)
                                                    .likePost(post.id);
                                              },
                                              icon: Image.asset(
                                                postData.isLikedByMe
                                                    ? "images/is-like-icon.png"
                                                    : "images/like-icon.png",
                                                height: 24,
                                                width: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: AppColors.grey,
                          thickness: 2,
                          height: 6,
                        ),
                        SizedBox(
                          height: 40,
                          child: DropdownButton(
                            padding: const EdgeInsets.only(left: 16),
                            value: filter,
                            underline: const SizedBox(),
                            style: AppStyles.labelTextStyle,
                            items: <String>['Terbaru', 'Terpopuler']
                                .map((String value) {
                              return DropdownMenuItem(
                                  value: value, child: Text(value));
                            }).toList(),
                            onChanged: (value) {
                              if (value == "Terbaru") {
                                sort = "recent";
                              } else {
                                sort = "likes";
                              }
                              setState(() {
                                filter = value!;
                              });

                              Provider.of<CommentProvider>(context,
                                      listen: false)
                                  .fetchComments(postId: post.id, sort: sort);
                              offset = 0;
                            },
                          ),
                        ),
                        Consumer<CommentProvider>(
                          builder: (context, commentProv, child) {
                            print("offset: " + offset.toString());
                            if (commentProv.commentState ==
                                    CommentState.loading &&
                                (commentProv.comments.isEmpty || offset < 5)) {
                              return const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryColor),
                                  ),
                                ),
                              );
                            } else if (commentProv.commentState ==
                                CommentState.error) {
                              return Center(
                                child: Text(
                                    'Error: ${commentProv.errorCommentMessage ?? 'An error occurred'}'),
                              );
                            } else {
                              // print("panjang comment + ${commentProv.comments.length}");
                              return ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: commentProv.comments.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == commentProv.comments.length) {
                                    return commentProv.commentState ==
                                            CommentState.loading
                                        ? const SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: Center(
                                              child: SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          AppColors
                                                              .primaryColor),
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink();
                                  }
                                  Comment comment = commentProv.comments[index];
                                  // print("comment replies " +
                                  //     comment.count.replies.toString() +
                                  //     " with " +
                                  //     comment.id.toString());
                                  return Column(
                                    children: [
                                      InkWell(
                                        onDoubleTap: () {
                                          Provider.of<CommentProvider>(context,
                                                  listen: false)
                                              .likeComment(comment.id);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                          child: IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4.0),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        AppColors.grey,
                                                    radius: 24,
                                                    foregroundImage: NetworkImage(
                                                        '$serverPath/uploads/${comment.user.profile.photo}'),
                                                  ),
                                                ),
                                                SizedBox(width: 6),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            comment.user.profile
                                                                .nama,
                                                            style: AppStyles
                                                                .heading2TextStyle,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 4.0,
                                                                    left: 4.0),
                                                            child: Text(
                                                              timeAgo(comment
                                                                  .createdAt),
                                                              style: AppStyles
                                                                  .miniHintTextStyle,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      ExpandableText(
                                                          body: comment.body),
                                                      const SizedBox(height: 2),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  comment.count
                                                                      .commentLikes
                                                                      .toString(),
                                                                  style: AppStyles
                                                                      .miniHintTextStyle),
                                                              const SizedBox(
                                                                  width: 2),
                                                              Text('likes',
                                                                  style: AppStyles
                                                                      .miniHintTextStyle)
                                                            ],
                                                          ),
                                                          InkWell(
                                                              onTap: () {
                                                                replyToCommentId =
                                                                    comment.id;
                                                                replyToCommentName =
                                                                    comment
                                                                        .user
                                                                        .profile
                                                                        .nama;
                                                                isReply = true;
                                                                isReplyComment =
                                                                    true;
                                                                FocusScope.of(
                                                                        context)
                                                                    .requestFocus(
                                                                        _focusNode);
                                                                setState(() {});
                                                              },
                                                              child: Text(
                                                                  'Reply',
                                                                  style: AppStyles
                                                                      .miniHintTextStyle)),
                                                          SizedBox(),
                                                          SizedBox()
                                                        ],
                                                      ),
                                                      const SizedBox(height: 2),
                                                      if (comment
                                                              .count.replies >
                                                          0)
                                                        InkWell(
                                                          onTap: () {
                                                            Provider.of<CommentProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .fetchReplies(
                                                                    commentId:
                                                                        comment
                                                                            .id,
                                                                    offset: comment
                                                                        .replies
                                                                        .length);
                                                            print(
                                                                "comment id = ${comment.id}");
                                                            print("post id: " +
                                                                post.id
                                                                    .toString());
                                                          },
                                                          child: Text(
                                                              "View ${comment.count.replies} more replies",
                                                              style: AppStyles
                                                                  .miniHintTextStyle),
                                                        ),
                                                      const SizedBox(height: 4),
                                                    ],
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: IconButton(
                                                      onPressed: () {
                                                        print("status like: " +
                                                            comment.isLikedByMe
                                                                .toString());
                                                        EditReplyState
                                                            editReplyState =
                                                            Provider.of<CommentProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .editReplyState;
                                                        if (editReplyState ==
                                                            EditReplyState
                                                                .loading) {
                                                          print("cek");
                                                        } else {
                                                          Provider.of<CommentProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .likeComment(
                                                                  comment.id);
                                                        }
                                                      },
                                                      icon: Image.asset(
                                                        comment.isLikedByMe
                                                            ? 'images/orange-heart.png'
                                                            : 'images/heart.png',
                                                        width: 16,
                                                        height: 16,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      ListView.builder(
                                        itemCount: comment.replies.length,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          // print("index reply " + index.toString());
                                          if (index == comment.replies.length) {
                                            return commentProv.replyState ==
                                                    ReplyState.loading
                                                ? const Center(
                                                    child: SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                AppColors
                                                                    .primaryColor),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink();
                                          }
                                          Reply reply = comment.replies[index];
                                          return InkWell(
                                            onDoubleTap: () {
                                              Provider.of<CommentProvider>(
                                                      context,
                                                      listen: false)
                                                  .likeReply(
                                                      comment.id, reply.id);
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  left: 50, right: 12),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4.0),
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            AppColors.grey,
                                                        radius: 24,
                                                        foregroundImage:
                                                            NetworkImage(
                                                                '$serverPath/uploads/${reply.user.profile.photo}'),
                                                      ),
                                                    ),
                                                    SizedBox(width: 6),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                reply
                                                                    .user
                                                                    .profile
                                                                    .nama,
                                                                style: AppStyles
                                                                    .heading2TextStyle,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            4.0,
                                                                        left:
                                                                            4.0),
                                                                child: Text(
                                                                  timeAgo(reply
                                                                      .createdAt),
                                                                  style: AppStyles
                                                                      .miniHintTextStyle,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          ExpandableText(
                                                              body: reply.body),
                                                          const SizedBox(
                                                              height: 2),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      reply
                                                                          .replyLikesCount
                                                                          .toString(),
                                                                      style: AppStyles
                                                                          .miniHintTextStyle),
                                                                  const SizedBox(
                                                                      width: 2),
                                                                  Text('likes',
                                                                      style: AppStyles
                                                                          .miniHintTextStyle)
                                                                ],
                                                              ),
                                                              InkWell(
                                                                  onTap: () {
                                                                    replyToCommentId =
                                                                        reply
                                                                            .commentId;
                                                                    replyToReplyId =
                                                                        index;
                                                                    replyToReplyName = reply
                                                                        .user
                                                                        .profile
                                                                        .nama;
                                                                    isReply =
                                                                        true;
                                                                    isReplyComment =
                                                                        false;
                                                                    FocusScope.of(
                                                                            context)
                                                                        .requestFocus(
                                                                            _focusNode);
                                                                    commentController
                                                                            .text =
                                                                        "@$replyToReplyName ";
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  child: Text(
                                                                      'Reply',
                                                                      style: AppStyles
                                                                          .miniHintTextStyle)),
                                                              SizedBox(),
                                                              SizedBox()
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                        ],
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: IconButton(
                                                          onPressed: () {
                                                            Provider.of<CommentProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .likeReply(
                                                                    comment.id,
                                                                    reply.id);
                                                          },
                                                          icon: Image.asset(
                                                            reply.isLikedByMe
                                                                ? 'images/orange-heart.png'
                                                                : 'images/heart.png',
                                                            width: 16,
                                                            height: 16,
                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: (isReply) ? 90 : 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (isReply) ? replyToWidget() : Container(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          controller: commentController,
                          decoration: InputDecoration(
                              hintText: "Ketik Pesan...",
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 6),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32),
                                  borderSide: BorderSide(
                                      color: AppColors.primaryColor)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32),
                                  borderSide: BorderSide(
                                    color: AppColors.grey,
                                  ))),
                        ),
                      ),
                      SizedBox(width: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(32),
                        onTap: () {
                          if (commentController.text.trim() != "" &&
                              replyToCommentName == "" &&
                              replyToCommentId == 0) {
                            _sendComment(
                                context: context,
                                body: commentController.text,
                                postId: post.id,
                                isComment: true,
                                commentId: null,
                                isReply: false,
                                replyId: null);
                          } else if (commentController.text.trim() != "" &&
                              isReply &&
                              isReplyComment) {
                            _sendComment(
                                context: context,
                                body: commentController.text,
                                postId: post.id,
                                isComment: false,
                                commentId: replyToCommentId,
                                isReply: false,
                                replyId: null);
                            // _sendComment(context, commentController.text, null,
                            //     false, replyToCommentId);
                          } else if (commentController.text.trim() != "" &&
                              isReply &&
                              !isReplyComment) {
                            _sendComment(
                                context: context,
                                body: commentController.text,
                                postId: post.id,
                                isComment: false,
                                commentId: replyToCommentId,
                                isReply: true,
                                replyId: replyToReplyId);
                            // _sendComment(context, commentController.text, null,
                            //     false, replyToCommentId);
                          }
                        },
                        child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColors.darkGrey,
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: Offset(0, 3))
                                ],
                                shape: BoxShape.circle,
                                color: AppColors.primaryColor),
                            child: Consumer<CommentProvider>(
                              builder: (context, commentProv, child) {
                                return commentProv.iconState ==
                                        IconState.loading
                                    ? const Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.whiteColor),
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send,
                                        color: AppColors.whiteColor,
                                      );
                              },
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
