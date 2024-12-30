import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../api/book_api.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../consts/padding_sizes.dart';
import '../consts/rounded_sizes.dart';
import '../models/book_category_model.dart';
import '../providers/book_category_provider.dart';
import '../providers/office_address_provider.dart';
import '../widgets/app_bar_builder.dart';
import '../widgets/button_builder.dart';
import '../widgets/date_picker_row.dart';
import '../widgets/snack_bar_builder.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _fromKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _selectedDate;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final BookApi _bookApi = BookApi();
  final Set<int> selectedIds = {};
  bool _loadingAddBook = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfficeAddressProvider>().fetchOfficeAddresses();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    context.read<OfficeAddressProvider>().clearOfficeAddresses();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1000,
          maxHeight: 1000,
          imageQuality: 85);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  _submitForm({
    required String name,
    required String description,
    required int stock,
    required DateTime planSentAt,
    required List<int> categoryIds,
    required File photo,
    required BuildContext context,
    required String address,
  }) async {
    print("In submitting...");

    try {
      bool success = await _bookApi.createBookDonation(
        name,
        description,
        stock.toString(),
        planSentAt.toIso8601String(),
        categoryIds.join(","),
        photo,
      );

      if (success) {
        // Clear all the fields on successful submission
        _titleController.clear();
        _stockController.clear();
        selectedIds.clear();
        _descriptionController.clear();
        _selectedDate = null;
        _imageFile = null;

        setState(() {});

        setState(() {
          _loadingAddBook = false; // Reset loading state
        });

        _showSucessDonateBook(address);
      } else {
        setState(() {
          _loadingAddBook = false; // Reset loading state
        });

        throw Exception("Failed to donate the book.");
      }
    } catch (error) {
      print("Error: $error");

      setState(() {
        _loadingAddBook = false; // Reset loading state
      });

      // Display the error message in a custom SnackBar
      showCostumSnackBar(
        context: context,
        message: error.toString(), // Show the error message
        backgroundColor: AppColors.redColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookCategoryProvider, OfficeAddressProvider>(
        builder: (context, bookCategoryProvider, officeAddressProvider, child) {
      if (officeAddressProvider.officeAddresses.isNotEmpty) {
        _addressController.text =
            officeAddressProvider.officeAddresses[0].address;
      }
      return Scaffold(
        appBar: AppBarBuilder(
          title: "Tambah Buku",
          showBackButton: true,
          onBackButtonPressed: () {
            Navigator.pop(context);
          },
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _fromKey,
              child: Column(
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text("Tambah Buku", style: AppStyles.labelTextStyle),
                  //     IconButton(
                  //         onPressed: () {
                  //           Navigator.pop(context);
                  //         },
                  //         icon: Icon(Icons.close))
                  //   ],
                  // ),
                  Center(
                    child: Column(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(32),
                          onTap: _pickImage,
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: AppColors.grey),
                            child: _imageFile != null
                                ? ClipOval(
                                    child: Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(Icons.photo_library,
                                    size: 40, color: AppColors.accentColor),
                          ),
                        ),
                        SizedBox(height: PaddingSizes.medium),
                        TextButton(
                            style: TextButton.styleFrom().copyWith(
                                overlayColor:
                                    WidgetStateProperty.all(AppColors.grey),
                                side: WidgetStatePropertyAll(BorderSide(
                                    width: 1, color: AppColors.accentColor)),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(32)))),
                            onPressed: _pickImage,
                            // onPressed: () => _showSucessDonateBook(
                            //     "0my Android StudioI have created a project. The app builds and runs perfectly, but when I try to create a separate .kt file and run it, it shows the error"),
                            child: Text(
                              "Tambah Gambar",
                              style: AppStyles.labelTextStyle,
                            ))
                      ],
                    ),
                  ),
                  _buildTextFormField(
                      title: "Judul Buku",
                      hint: "Nama Buku",
                      controller: _titleController),
                  _buildTextFormField(
                      title: "Jumlah Buku",
                      hint: "10",
                      controller: _stockController,
                      isNumber: true),
                  _buildCategoriesChips(bookCategoryProvider.bookCategories),
                  _buildTextFormField(
                      title: "Deskripsi Buku",
                      hint: "Deskripsi Buku",
                      controller: _descriptionController),
                  _buildTextFormField(
                      title: "Alamat Pemberian Buku",
                      hint: "Loading...",
                      controller: _addressController,
                      readOnly: true,
                      maxLines: 2),
                  DatePickerRow(
                    title: Padding(
                      padding: const EdgeInsets.only(left: PaddingSizes.small),
                      child: Text("Tanggal Pemberian",
                          style: AppStyles.labelBoldTextStyle),
                    ),
                    date: _selectedDate,
                    onDatePicked: (DateTime pickedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    },
                  ),
                  SizedBox(height: PaddingSizes.medium),
                  ButtonBuilder(
                      onPressed: () async {
                        if (_loadingAddBook) return;

                        setState(() {
                          _loadingAddBook = true; // Set loading state to true
                        });

                        String address = "Kutab Al Fatih";

                        if (_imageFile == null) {
                          final snackBar = SnackBar(
                              backgroundColor: AppColors.redColor,
                              content:
                                  Text("Mohon pilih gambar terlebih dahulu"));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          setState(() {
                            _loadingAddBook = false; // Reset loading state
                          });
                          return;
                        }

                        if (_selectedDate == null) {
                          showCostumSnackBar(
                              context: context,
                              message: "Mohon pilih tanggal terlebih dahulu",
                              backgroundColor: AppColors.redColor);
                          setState(() {
                            _loadingAddBook = false; // Reset loading state
                          });
                          return;
                        }

                        if (selectedIds.isEmpty) {
                          showCostumSnackBar(
                              context: context,
                              message: "Mohon pilih kategori terlebih dahulu",
                              backgroundColor: AppColors.redColor);
                          setState(() {
                            _loadingAddBook = false; // Reset loading state
                          });
                          return;
                        }

                        if (!_isValidStock(_stockController.text)) {
                          showCostumSnackBar(
                              context: context,
                              message:
                                  "Jumlah buku harus berupa bilangan bulat positif dan tidak boleh mengandung koma",
                              backgroundColor: AppColors.redColor);
                          setState(() {
                            _loadingAddBook = false; // Reset loading state
                          });
                          return;
                        }

                        if (officeAddressProvider.officeAddresses.isNotEmpty) {
                          address =
                              officeAddressProvider.officeAddresses[0].address;
                        }

                        if (!_fromKey.currentState!.validate()) {
                          setState(() {
                            _loadingAddBook = false; // Reset loading state
                          });
                          return;
                        }

                        await _submitForm(
                            name: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            stock: int.parse(_stockController.text.trim()),
                            planSentAt: _selectedDate!,
                            categoryIds: selectedIds.toList(),
                            photo: _imageFile!,
                            context: context,
                            address: address);

                        setState(() {
                          _loadingAddBook = false; // Reset loading state
                        });
                      },
                      child: Text("Ajukan Buku",
                          style: AppStyles.labelWhiteTextStyle))
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  bool _isValidStock(String value) {
    final number = int.tryParse(value);
    return number != null &&
        number > 0 &&
        !value.contains('.') &&
        !value.contains(',');
  }

  _buildCategoriesChips(List<BookCategory> bookCategories) {
    final List<Map<String, dynamic>> options = bookCategories
        .where((e) => e.id != 0)
        .map((e) => {'name': e.name, 'id': e.id})
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Kategori Buku", style: AppStyles.labelBoldTextStyle),
        Wrap(
          // spacing: 2,
          runSpacing: -12,
          children: options.map((option) {
            String name = option['name'];
            int id = option['id'];
            bool isSelected = selectedIds.contains(id);

            return FilterChip(
              showCheckmark: false,
              label: Text(
                name,
                style: isSelected
                    ? AppStyles.labelWhiteTextStyle
                    : AppStyles.labelTextStyle,
              ),
              selected: selectedIds.contains(id),
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    selectedIds.add(id);
                  } else {
                    selectedIds.remove(id);
                  }
                });
              },
              backgroundColor: AppColors.grey,
              selectedColor: AppColors.primaryColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  _showSucessDonateBook(String address) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RoundedSizes.extraLarge)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close))),
              Center(
                  child: Image.asset('images/approved.png',
                      width: 126, height: 126)),
              SizedBox(height: PaddingSizes.medium),
              Center(
                child: Text("Donasi Buku Berhasil Diajukan",
                    style: AppStyles.heading2TextStyle),
              ),
              SizedBox(height: PaddingSizes.large),
              Text("Silahkan untuk memberikan buku ke:",
                  style: AppStyles.labelTextStyle, textAlign: TextAlign.center),
              SizedBox(height: PaddingSizes.small),
              Text(address,
                  style: AppStyles.hintTextStyle, textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  _buildTextFormField(
      {required String title,
      required String hint,
      required TextEditingController controller,
      bool readOnly = false,
      int maxLines = 1,
      bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: PaddingSizes.small),
          child: Text(title, style: AppStyles.labelBoldTextStyle),
        ),
        SizedBox(height: PaddingSizes.small),
        TextFormField(
          readOnly: readOnly,
          style: AppStyles.labelTextStyle,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppStyles.hintTextStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(RoundedSizes.extraLarge),
              borderSide: BorderSide(color: AppColors.accentColor),
            ),
            isDense: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Mohon isi terlebih dahulu';
            }
            return null;
          },
          controller: controller,
        ),
        SizedBox(height: PaddingSizes.small),
      ],
    );
  }
}
