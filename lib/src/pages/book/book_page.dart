import 'package:ayahhebat/src/consts/app_colors.dart';
import 'package:ayahhebat/src/consts/app_styles.dart';
import 'package:ayahhebat/src/consts/padding_sizes.dart';
import 'package:ayahhebat/src/utils/get_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../providers/book_category_provider.dart';
import '../../providers/book_provider.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  String selectedCategory = "semua";
  String searchBooksText = "";
  String? selectedFilterCategory;
  String? selectedBookAge;
  final ScrollController _scrollController = ScrollController();
  int offset = 0;

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      offset += 10;
      Provider.of<BookProvider>(context, listen: false).fetchBooks(
          category: selectedCategory, offset: offset, refresh: false);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookCategoryProvider>(context, listen: false)
          .fetchCategories();
      Provider.of<BookProvider>(context, listen: false)
          .fetchBooks(category: "semua");
      _scrollController.addListener(_scrollListener);
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // showFilterDialog() {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return Consumer<BookCategoryProvider>(
  //           builder: (context, bookCategoryProvider, child) {
  //         return Dialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(16),
  //             ),
  //             child: Container(
  //               padding: EdgeInsets.all(16),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         'Pinjam Buku',
  //                         style: AppStyles.heading2TextStyle,
  //                       ),
  //                       IconButton(
  //                         onPressed: () => Navigator.pop(context),
  //                         icon: Icon(Icons.close),
  //                         padding: EdgeInsets.zero,
  //                         constraints: BoxConstraints(),
  //                       )
  //                     ],
  //                   ),
  //                   SizedBox(height: 16),
  //                   _buildDropdown(
  //                       'Pilih Category',
  //                       selectedFilterCategory,
  //                       bookCategoryProvider.bookCategories
  //                           .map((category) => category.name)
  //                           .toList(), (String? newValue) {
  //                     setState(() {
  //                       selectedFilterCategory = newValue!;
  //                     });
  //                   }),
  //                   SizedBox(height: 32),
  //                   ButtonBuilder(
  //                     onPressed: () async {
  //                       Navigator.pop(context);
  //                     },
  //                     child: Text('Filter'),
  //                   ),
  //                 ],
  //               ),
  //             ));
  //       });
  //     },
  //   );
  // }

  Widget _buildDropdown(String hint, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(32),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          borderRadius: BorderRadius.circular(32),
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          padding: EdgeInsets.only(left: 16),
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(hint, style: AppStyles.hintTextStyle),
          ),
          icon: Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.keyboard_arrow_down),
          ),
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  void fetchBooksByCategoryAndSearch(
      {required String category, String? search, bool isSearch = false}) {
    print("fetchBooksByCategoryAndSearch");
    offset = 0;
    Provider.of<BookProvider>(context, listen: false).clearBooks();
    if (isSearch) {
      Provider.of<BookProvider>(context, listen: false)
          .searchBooks(category: category, search: search);
    } else {
      Provider.of<BookProvider>(context, listen: false)
          .fetchBooks(category: category, search: search);
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<BookCategoryProvider>(context, listen: false).fetchCategories();
    print(Provider.of<BookCategoryProvider>(context, listen: false)
        .bookCategories);

    return Consumer<BookCategoryProvider>(
        builder: (context, BookCategoryProvider bookCategoryProvider, child) {
      return Scaffold(
        appBar: appBarBook(),
        body: Column(
          children: [
            SizedBox(height: PaddingSizes.small),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: PaddingSizes.medium),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: AppStyles.labelTextStyle,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(color: AppColors.accentColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(color: AppColors.accentColor),
                        ),
                        suffixIconColor: AppColors.accentColor,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(color: AppColors.redColor),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor, width: 2),
                        ),
                        hintText: "Cari Buku",
                        hintStyle: AppStyles.hintTextStyle,
                        suffixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        searchBooksText = value;
                        fetchBooksByCategoryAndSearch(
                            category: selectedCategory,
                            search: searchBooksText,
                            isSearch: true);
                      },
                    ),
                  ),
                  // SizedBox(width: 12),
                  // InkWell(
                  //   borderRadius: BorderRadius.circular(12),
                  //   onTap: () {
                  //     showFilterDialog();
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.all(12),
                  //     decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(16),
                  //         border: Border.all(
                  //           color: AppColors.accentColor,
                  //         )),
                  //     child: Image.asset(
                  //       'images/filter.png',
                  //       width: 24,
                  //       height: 24,
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
            SizedBox(height: PaddingSizes.small),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16),
              child: Row(
                children: bookCategoryProvider.bookCategories.map((category) {
                  bool isSelected = selectedCategory.toLowerCase() ==
                      category.name.toLowerCase();
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category.name,
                        style: isSelected
                            ? AppStyles.labelWhiteTextStyle
                            : AppStyles.labelTextStyle,
                      ),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selectedCategory == category.name.toLowerCase()) {
                            return;
                          }
                          selectedCategory = category.name.toLowerCase();
                          fetchBooksByCategoryAndSearch(
                              category: selectedCategory,
                              search: searchBooksText);
                        });
                      },
                      backgroundColor: AppColors.grey,
                      selectedColor: AppColors.primaryColor,
                      shape: StadiumBorder(),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(child:
                Consumer<BookProvider>(builder: (context, bookProvider, child) {
              if (bookProvider.bookState == BookState.initial ||
                  bookProvider.bookState == BookState.loading) {
                return _buildGridShimmerEffect();
              }

              if (bookProvider.bookState == BookState.error) {
                return Center(
                  child: TextButton(
                      onPressed: () => fetchBooksByCategoryAndSearch(
                          category: selectedCategory, search: searchBooksText),
                      child: Text("Refresh")),
                );
              }

              if (bookProvider.books.isEmpty) {
                // return Center(
                //   child: Text("Buku Kosong"),
                // );
                return RefreshIndicator(
                  color: AppColors.primaryColor,
                    child: ListView(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context).size.height / 4),
                            Text("Buku belum tersedia",
                                style: AppStyles.labelTextStyle)
                          ],
                        )
                      ],
                    ),
                    onRefresh: () async => fetchBooksByCategoryAndSearch(
                        category: selectedCategory, search: searchBooksText));
              }
              return RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: () async {
                  fetchBooksByCategoryAndSearch(
                      category: selectedCategory, search: searchBooksText);
                },
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 300,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6),
                  itemCount: bookProvider.bookState == BookState.loading
                      ? bookProvider.books.length + 1
                      : bookProvider.books.length,
                  itemBuilder: (context, index) {
                    if (index == bookProvider.books.length) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final book = bookProvider.books[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/bookDetail', arguments: {
                          'bookId': book.id,
                        });
                      },
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.grey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                    // GetNetworkImage.getBooks(book.imageurl),
                                    GetNetworkImage.getBooks(book.imageurl),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    // color: AppColors.grey,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Image not found",
                                      style: AppStyles.labelTextStyle,
                                    ),
                                  );
                                }, loadingBuilder:
                                        (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Container(
                                      width: double.infinity,
                                      // color: AppColors.grey,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryColor,
                                      ));
                                }),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.categories.join(", "),
                                    style: AppStyles.hintTextStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    book.name,
                                    style: AppStyles.heading2TextStyle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "Stok: ${book.stock}",
                                    style: AppStyles.hintTextStyle,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            })),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              // OfficeAddress officeAddress =
              //     officeAddressProvider.getOfficeAddressByName("ayahhebat") ??
              //         OfficeAddress(
              //             id: 0,
              //             name: "ayahhebat",
              //             address: "JL Griya Karang Asri");
              // showAddBookDialog(context, officeAddress.address);
              Navigator.pushNamed(context, '/addBook');
            },
            child: Icon(Icons.add),
            backgroundColor: AppColors.primaryColor),
      );
    });
  }

  Widget _buildGridShimmerEffect() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 300,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: 6, // Jumlah shimmer item yang ingin ditampilkan
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      color: Colors.white,
                      width: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      SizedBox(height: 6),
                      Container(
                        height: 12,
                        width: 150,
                        color: Colors.white,
                      ),
                      SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 80,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // showAddBookDialog(BuildContext context, String address) async {
  //   print("address $address");
  //   final result = await showDialog(
  //       context: context,
  //       builder: (context) => AddBookDialog(
  //             address: address,
  //           ));
  //   if (result != null) {
  //     print("result: $result");
  //   }
  // }

  AppBar appBarBook() {
    return AppBar(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pilih Buku Bacaan",
            style: AppStyles.heading2TextStyle,
          ),
          SizedBox(height: 4),
          Text(
            "Pilih buku yang ingin di pinjam",
            style: AppStyles.hintTextStyle,
          )
        ],
      ),
      actions: [
        Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentColor,
                )),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/manageBooks');
              },
              icon: Image.asset(
                'images/basket.png',
                width: 24,
                height: 24,
              ),
            ))
      ],
    );
  }
}
