import 'package:ayahhebat/main.dart';
import 'package:ayahhebat/src/api/profile_api.dart';
import 'package:ayahhebat/src/widgets/app_bar_left_builder.dart';
import 'package:ayahhebat/src/widgets/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/post_api.dart';
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
  final PostApi _postService = PostApi();

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

  void onSendPostTapped(String body) {
    
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

  void onPostTapped(int postId) {
    Navigator.pushNamed(context, '/comments', arguments: {'postId': postId});
  }

  void showAddPost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                            // style: AppStyles.labelBoldTextStyle,
                          )
                        ],
                      );
                    }
                    return Container();
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _postBodyController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(color: AppColors.lightgrey))),
                ),
                SizedBox(height: 25),
                ButtonBuilder(
                    onPressed: () async {
                      onSendPostTapped(_postBodyController.text);
                    },
                    child: Text("Kirim")),
              ],
            ),
          ),
        );
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
                  suffixIcon: IconButton(
                      onPressed: () {
                        searchTrigger();
                      },
                      icon: Icon(Icons.search)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32))),
            ),
            SizedBox(height: 16),
            Expanded(child: Consumer<PostProvider>(
              builder: (context, postProvider, child) {
                print(postProvider.posts);
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
                } else {
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
                                      onPostTapped(post.id);
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
                                                    AppStyles.heading1TextStyle,
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
                                                onPressed: () {},
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
                                                            onPressed: () {},
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
