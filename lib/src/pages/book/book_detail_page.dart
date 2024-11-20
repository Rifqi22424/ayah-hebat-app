import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../consts/app_colors.dart';
import '../../models/book_detail_model.dart';
import '../../providers/book_detail_provider.dart';
import '../../utils/get_network_image.dart';
import '../../widgets/app_bar_builder.dart';
import '../../widgets/button_builder.dart';

class BookDetailPage extends StatefulWidget {
  final int bookId;
  const BookDetailPage({super.key, required this.bookId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BookDetailProvider>(context, listen: false);
      provider.fetchBookDetail(id: widget.bookId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final provider = Provider.of<BookDetailProvider>(context);
    BookDetail _bookDetail = provider.bookDetail!;

    if (provider.bookDetailState == BookDetailState.loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return provider.bookDetail != null
        ? DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBarBuilder(
                title: "Detail Buku",
                showBackButton: true,
                onBackButtonPressed: () => Navigator.pop(context),
              ),
              body: Column(
                children: [
                  Container(
                    height: height * 0.45,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Image.network(
                      GetNetworkImage.getBooks(_bookDetail.imageUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(_bookDetail.categories.join(', ')),
                        Text("Stock: ${_bookDetail.stock.toString()}"),
                      ],
                    ),
                  ),
                  TabBar(
                    tabs: [Tab(text: 'Cerita Singkat'), Tab(text: 'Komentar')],
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: AppColors.accentColor,
                    indicatorColor: AppColors.primaryColor,
                    indicatorSize: TabBarIndicatorSize.label,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_bookDetail.description),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: _bookDetail.reviews.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    onTap: () {},
                                    leading: Image.network(
                                        GetNetworkImage.getUploads(_bookDetail
                                            .reviews[index]
                                            .user
                                            .profile
                                            .photo)),
                                    title: Text(_bookDetail
                                        .reviews[index].user.profile.nama),
                                    subtitle: Text(
                                        _bookDetail.reviews[index].description),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 16.0, left: 16.0, right: 16.0, top: 8.0),
                    child: ButtonBuilder(
                      child: Text("Pinjam Buku"),
                      onPressed: () async {},
                    ),
                  )
                ],
              ),
            ),
          )
        : Scaffold(
            body: Center(
              child: Text("Data tidak ditemukan"),
            ),
          );
  }
}
