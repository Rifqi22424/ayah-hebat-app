import 'package:ayahhebat/src/consts/app_colors.dart';
import 'package:ayahhebat/src/consts/app_styles.dart';
import 'package:ayahhebat/src/utils/get_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/book_category_provider.dart';
import '../../providers/book_provider.dart';
import '../../widgets/button_builder.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  String selectedCategory = "semua";
  String? selectedFilterCategory;
  String? selectedBookAge;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookCategoryProvider>(context, listen: false)
          .fetchCategories();
      Provider.of<BookProvider>(context, listen: false).fetchBooks();
    });
    super.initState();
  }

  showFilterDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return Consumer<BookCategoryProvider>(
            builder: (context, bookCategoryProvider, child) {
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pinjam Buku',
                          style: AppStyles.heading2TextStyle,
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildDropdown(
                        'Pilih Category',
                        selectedFilterCategory,
                        bookCategoryProvider.bookCategories
                            .map((category) => category.name)
                            .toList(), (String? newValue) {
                      setState(() {
                        selectedFilterCategory = newValue!;
                      });
                    }),
                    SizedBox(height: 32),
                    ButtonBuilder(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      child: Text('Filter'),
                    ),
                  ],
                ),
              ));
        });
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    Provider.of<BookCategoryProvider>(context, listen: false).fetchCategories();
    print(Provider.of<BookCategoryProvider>(context, listen: false)
        .bookCategories);

    return Consumer2<BookProvider, BookCategoryProvider>(builder: (context,
        BookProvider bookProvider,
        BookCategoryProvider bookCategoryProvider,
        child) {
      return Scaffold(
        appBar: appBarBook(),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide:
                                  BorderSide(color: AppColors.accentColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide:
                                  BorderSide(color: AppColors.accentColor),
                            ),
                            suffixIconColor: AppColors.accentColor,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: BorderSide(
                                  color: AppColors.primaryColor, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide:
                                  BorderSide(color: AppColors.redColor!),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: BorderSide(
                                  color: AppColors.primaryColor, width: 2),
                            ),
                            hintText: "Cari Buku",
                            hintStyle: AppStyles.hintTextStyle,
                            suffixIcon: Icon(Icons.search)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      showFilterDialog();
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.accentColor,
                          )),
                      child: Image.asset(
                        'images/filter.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  )
                ],
              ),
            ),
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
                          selectedCategory = category.name.toLowerCase();
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
            Expanded(
                child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6),
              itemCount: bookProvider.books.length,
              itemBuilder: (context, index) {
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
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              GetNetworkImage.getBooks(book.imageurl),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
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
            )),
          ],
        ),
      );
    });
  }

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
                  color: AppColors.textColor,
                )),
            child: IconButton(
              onPressed: () {},
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
