import 'package:flutter/material.dart';
import 'package:ayahhebat/src/api/news_api.dart';
import 'package:ayahhebat/src/models/news/newest_news_model.dart';
import 'package:ayahhebat/src/models/news/popular_news_model.dart';
import 'package:ayahhebat/src/widgets/app_bar_builder.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../consts/padding_sizes.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<PopularNews>> futurePopularNews;
  List<NewestNews> newestNewsList = [];
  final CarouselController _controller = CarouselController();
  final ScrollController _scrollController = ScrollController();
  int _current = 0;
  bool isLoading = false;
  int limit = 5;
  int offset = 0;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    futurePopularNews = NewsApi().getPopularNews();
    _loadMoreNews();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMoreData &&
          !isLoading) {
        _loadMoreNews();
      }
    });
  }

  Future<void> _loadMoreNews() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<NewestNews> moreNews =
          await NewsApi().getNewestNews(limit: limit, offset: offset);
      setState(() {
        newestNewsList.addAll(moreNews);
        offset += limit;
        if (moreNews.length < limit) {
          hasMoreData = false;
        }
      });
    } catch (e) {
      print('Error loading more news: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder(
        title: "Berita Populer",
        showBackButton: false,
        showCancelButton: false,
      ),
      body: FutureBuilder<List<PopularNews>>(
        future: futurePopularNews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load news'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No news available'));
          } else {
            List<PopularNews> newsList = snapshot.data!;
            return Column(
              children: [
                CarouselSlider(
                  items:
                      newsList.map((news) => buildCarouselItem(news)).toList(),
                  carouselController: _controller,
                  options: CarouselOptions(
                    aspectRatio: 2.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: newsList.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _current == entry.key ? 34.0 : 12.0,
                          height: 12.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4.0),
                          decoration: _current == entry.key
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color:
                                      AppColors.primaryColor.withOpacity(0.9),
                                )
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: AppColors.textColor.withOpacity(0.4),
                                )
                          // BoxDecoration(
                          //   shape: _current == entry.key
                          //       ? BoxShape.rectangle
                          //       : BoxShape.circle,
                          //   borderRadius: _current == entry.key
                          //       ? BorderRadius.circular(8.0)
                          //       : null,
                          //   color: _current == entry.key
                          //       ? AppColors.primaryColor.withOpacity(0.9)
                          //       : AppColors.textColor.withOpacity(0.4),
                          // ),
                          ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24)),
                      color: AppColors.textColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Berita Terbaru",
                            style: AppStyles.heading2PrimaryTextStyle),
                        SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                newestNewsList.length + (hasMoreData ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == newestNewsList.length) {
                                return const Center(
                                    child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryColor),
                                  ),
                                ));
                              }
                              NewestNews news = newestNewsList[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/newsContent',
                                      arguments: {'newsId': news.id});
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.network(
                                            news.imageUrl,
                                            width: 180,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                news.title,
                                                style: AppStyles
                                                    .heading3WhiteTextStyle,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                              SizedBox(
                                                  height: PaddingSizes.small),
                                              Text(
                                                news.subTitle,
                                                style: AppStyles
                                                    .smallHintTextStyle,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              SizedBox(
                                                    height: PaddingSizes.extrasmall),
                                              Text(news.author,
                                                  style: AppStyles
                                                      .labelPrimaryTextStyle)
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildCarouselItem(PopularNews news) {
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/newsContent',
            arguments: {'newsId': news.id});
      },
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          child: Stack(
            children: <Widget>[
              Image.network(news.imageUrl,
                  fit: BoxFit.cover, width: screenWidth * 0.8),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Text(news.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.heading1WhiteTextStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
