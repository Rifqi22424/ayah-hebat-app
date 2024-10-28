import 'package:ayahhebat/main.dart';
import 'package:ayahhebat/src/api/profile_api.dart';
import 'package:ayahhebat/src/widgets/app_bar_left_builder.dart';
import 'package:ayahhebat/src/widgets/button_builder.dart';
import 'package:ayahhebat/src/widgets/costum_snack_bar.dart';
import 'package:ayahhebat/src/widgets/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../models/post_model.dart';
import '../../providers/post_provider.dart';

class ForumsPage extends StatefulWidget {
  const ForumsPage({super.key});

  @override
  State<ForumsPage> createState() => _ForumsPageState();
}

class _ForumsPageState extends State<ForumsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _postBodyController = TextEditingController();
  int offset = 0;
  final ProfileApi _profileService = ProfileApi();

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

  void searchTrigger() {
    if (_searchController.text != "") {
      final query = _searchController.text;
      Provider.of<PostProvider>(context, listen: false)
          .searchPosts(query: query);
    }
  }

  void autoSearch() {
    Future.delayed(Duration(seconds: 2));
    searchTrigger();
  }

  void onRefreshButton() {
    if (_searchController.text != "") {
      final query = _searchController.text;
      Provider.of<PostProvider>(context, listen: false)
          .searchPosts(query: query);
      offset = 0;
    } else {
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
      offset = 0;
    }
  }

  Future<void> onSendPostTapped(BuildContext context, String body) async {
    String formattedBody = body.replaceAll("\n", " ");
    await Provider.of<PostProvider>(context, listen: false)
        .createPost(formattedBody);

    final postProvider = Provider.of<PostProvider>(context, listen: false);

    print(postProvider.editPostState);

    if (postProvider.editPostState == EditPostState.error) {
      showCustomSnackBar(
          context, "Gagal mengirim postingan", AppColors.redColor!);
    } else if (postProvider.editPostState == EditPostState.loaded) {
      print("done");
      _postBodyController.clear();
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
    });

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      offset += 5;
      Provider.of<PostProvider>(context, listen: false)
          .fetchPosts(offset: offset);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void onPostTapped(int index, Post post, bool autoFocus) {
    Navigator.pushNamed(context, '/comments', arguments: {
      'indexPostProvider': index,
      'post': post,
      'autoFocus': autoFocus
    });
  }

  void showReportDialog(BuildContext context, String type, int postId) {
    showDialog(
        context: context,
        builder: (context) {
          if (type == "report") {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Text("Peringatan", style: AppStyles.mediumTextStyle),
              content: Text("Apakah anda ingin melaporkan postingan tersebut?",
                  style: AppStyles.heading3TextStyle),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.blueColor,
                    disabledForegroundColor: AppColors.halfBlueColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Tidak'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.redColor,
                    disabledForegroundColor: AppColors.halfRedColor,
                  ),
                  onPressed: () {
                    Provider.of<PostProvider>(context, listen: false)
                        .reportPost(postId);
                    print("masuk report tapped");
                    Navigator.pop(context);
                  },
                  child: const Text('Ya'),
                ),
              ],
            );
          } else {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Text("Peringatan", style: AppStyles.mediumTextStyle),
              content: Text("Apakah anda ingin menghapus postingan tersebut?",
                  style: AppStyles.heading3TextStyle),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.blueColor,
                    disabledForegroundColor: AppColors.halfBlueColor,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Tidak'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.redColor,
                    disabledForegroundColor: AppColors.halfRedColor,
                  ),
                  onPressed: () {
                    Provider.of<PostProvider>(context, listen: false)
                        .deletePost(postId);
                    Navigator.pop(context);
                  },
                  child: const Text('Ya'),
                ),
              ],
            );
          }
        });
  }

  void showMoreDialog(BuildContext context, bool isMine, int postId) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text("Laporkan"),
                    onTap: () {
                      Navigator.of(context).pop();
                      showReportDialog(context, "report", postId);
                    },
                  ),
                  isMine
                      ? ListTile(
                          title: Text("Hapus"),
                          onTap: () {
                            Navigator.of(context).pop();
                            showReportDialog(context, "detete", postId);
                          },
                        )
                      : SizedBox(),
                ],
              ),
            ));
  }

  void showAddPost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ScaffoldMessenger(
            child: Builder(
          builder: (context) => Scaffold(
            backgroundColor: Colors.transparent,
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tambahkan Postingan",
                            style: AppStyles.heading2TextStyle,
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close))
                        ],
                      ),
                      FutureBuilder<ProfileData>(
                        future: _profileService.getNameAndPhoto(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryColor),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text("Error has ocurred");
                          } else if (snapshot.hasData) {
                            final data = snapshot.data!;

                            return Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.grey,
                                  radius: 24,
                                  foregroundImage: NetworkImage(
                                      '${serverPath}/uploads/${data.photo}'),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  data.nama,
                                  style: AppStyles.heading2TextStyle,
                                )
                              ],
                            );
                          }
                          return Container();
                        },
                      ),
                      SizedBox(height: 10),
                      TextField(
                        maxLines: 2,
                        controller: _postBodyController,
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: AppColors.primaryColor)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: AppColors.lightgrey))),
                      ),
                      SizedBox(height: 25),
                      ButtonBuilder(
                          onPressed: () async {
                            try {
                              await onSendPostTapped(
                                  context, _postBodyController.text);
                            } catch (e) {
                              showCustomSnackBar(
                                  context, e.toString(), AppColors.redColor!);
                            }
                          },
                          child: Text("Kirim")),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));

        // Dialog(
        //   shape:
        //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        //   child: Container(
        //     padding: EdgeInsets.all(16),
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Text(
        //               "Tambahkan Postingan",
        //               style: AppStyles.heading2TextStyle,
        //             ),
        //             IconButton(
        //                 onPressed: () {
        //                   Navigator.pop(context);
        //                 },
        //                 icon: Icon(Icons.close))
        //           ],
        //         ),
        //         FutureBuilder<ProfileData>(
        //           future: _profileService.getNameAndPhoto(),
        //           builder: (context, snapshot) {
        //             if (snapshot.connectionState == ConnectionState.waiting) {
        //               return SizedBox(
        //                 height: 20,
        //                 width: 20,
        //                 child: CircularProgressIndicator(
        //                   valueColor: AlwaysStoppedAnimation<Color>(
        //                       AppColors.primaryColor),
        //                 ),
        //               );
        //             } else if (snapshot.hasError) {
        //               return Text("Error has ocurred");
        //             } else if (snapshot.hasData) {
        //               final data = snapshot.data!;

        //               return Row(
        //                 children: [
        //                   CircleAvatar(
        //                     backgroundColor: AppColors.grey,
        //                     radius: 24,
        //                     foregroundImage: NetworkImage(
        //                         '${serverPath}/uploads/${data.photo}'),
        //                   ),
        //                   SizedBox(width: 10),
        //                   Text(
        //                     data.nama,
        //                     style: AppStyles.heading2TextStyle,
        //                   )
        //                 ],
        //               );
        //             }
        //             return Container();
        //           },
        //         ),
        //         SizedBox(height: 10),
        //         TextField(
        //           maxLines: 2,
        //           controller: _postBodyController,
        //           decoration: InputDecoration(
        //               focusedBorder: OutlineInputBorder(
        //                   borderRadius: BorderRadius.circular(6),
        //                   borderSide:
        //                       BorderSide(color: AppColors.primaryColor)),
        //               border: OutlineInputBorder(
        //                   borderRadius: BorderRadius.circular(6),
        //                   borderSide: BorderSide(color: AppColors.lightgrey))),
        //         ),
        //         SizedBox(height: 25),
        //         ButtonBuilder(
        //             onPressed: () async {
        //               try {
        //                 onSendPostTapped(_postBodyController.text);
        //               } catch (e) {
        //                 showCustomSnackBar(
        //                     context, e.toString(), AppColors.redColor!);
        //               }
        //             },
        //             child: Text("Kirim")),
        //       ],
        //     ),
        //   ),
        // );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarLeftBuilder(
          title: "Forum diskusi", description: "Diskusi tentang keluarga"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) {
                autoSearch();
              },
              decoration: InputDecoration(
                  hintText: "Cari disini...",
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide(color: AppColors.primaryColor)),
                  suffixIcon: IconButton(
                      onPressed: () {
                        searchTrigger();
                      },
                      icon: Icon(Icons.search, color: AppColors.textColor)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32))),
            ),
            SizedBox(height: 16),
            Expanded(child: Consumer<PostProvider>(
              builder: (context, postProvider, child) {
                if (postProvider.postState == PostState.loading &&
                    postProvider.posts.isEmpty) {
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
                } else if (postProvider.postState == PostState.error) {
                  return Center(
                    child: Text(
                        'Error: ${postProvider.errorMessage ?? "An error occurred"}'),
                  );
                } else if (postProvider.posts.isEmpty) {
                  return const Center(
                    child: Text("Belum ada postingan"),
                  );
                }
                else {
                  return RefreshIndicator(
                    color: AppColors.primaryColor,
                    onRefresh: () async {
                      onRefreshButton();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      itemCount: postProvider.posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == postProvider.posts.length) {
                          return postProvider.postState == PostState.loading
                              ? const Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.primaryColor),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }
                        Post post = postProvider.posts[index];
                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  border:
                                      Border.all(color: AppColors.darkGrey)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      print("index = $index");
                                      print("post id=  ${post.id}");
                                      onPostTapped(index, post, false);
                                    },
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(32),
                                        topRight: Radius.circular(32)),
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: AppColors.grey,
                                                radius: 24,
                                                foregroundImage: NetworkImage(
                                                    '$serverPath/uploads/${post.user.profile.photo}'),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                post.user.profile.nama,
                                                style:
                                                    AppStyles.heading3BoldTextStyle,
                                              ),
                                              SizedBox(width: 5),
                                              Column(
                                                children: [
                                                  Text(
                                                    "${monthNames[post.createdAt.month]} ${post.createdAt.day}, ${post.createdAt.year}",
                                                    style:
                                                        AppStyles.miniHintTextStyle,
                                                  ),
                                                  SizedBox(height: 4),
                                                ],
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                          ExpandableText(body: post.body, isPost: true),
                                          SizedBox(height: 12),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(32),
                                        bottomRight: Radius.circular(32)),
                                    child: Container(
                                      height: 64,
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16.0),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(),
                                                onPressed: () {
                                                  showMoreDialog(context,
                                                      post.isMine, post.id);
                                                },
                                                icon: Image.asset(
                                                  "images/dots-icon.png",
                                                  height: 24,
                                                  width: 24,
                                                ),
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0),
                                            child: SizedBox(
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    child: Row(
                                                      children: [
                                                        Text(post.count.comments
                                                            .toString()),
                                                        SizedBox(width: 2),
                                                        IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                BoxConstraints(),
                                                            onPressed: () {
                                                              onPostTapped(
                                                                  index,
                                                                  post,
                                                                  true);
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
                                                        Text(post
                                                            .count.postDislikes
                                                            .toString()),
                                                        SizedBox(width: 2),
                                                        IconButton(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                BoxConstraints(),
                                                            onPressed: () {
                                                              Provider.of<PostProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .dislikePost(
                                                                      post.id);
                                                            },
                                                            icon: Image.asset(
                                                              post.isDislikedByMe
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
                                                        Text(post
                                                            .count.postLikes
                                                            .toString()),
                                                        SizedBox(width: 2),
                                                        IconButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              BoxConstraints(),
                                                          onPressed: () {
                                                            Provider.of<PostProvider>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .likePost(
                                                                    post.id);
                                                          },
                                                          icon: Image.asset(
                                                            post.isLikedByMe
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
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  );
                }
              },
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddPost(context);
        },
        child: Icon(Icons.add),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }
}
