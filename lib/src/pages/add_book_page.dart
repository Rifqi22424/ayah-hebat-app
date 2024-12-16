import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../api/book_api.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final officeAddressProvider =
          Provider.of<OfficeAddressProvider>(context, listen: false);
      officeAddressProvider.fetchOfficeAddresses();
      _addressController.text =
          officeAddressProvider.officeAddresses[0].address;
    });
    super.initState();
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
  }) async {
    if (_fromKey.currentState!.validate()) {
      bool success = await _bookApi.createBookDonation(
          name,
          description,
          stock.toString(),
          planSentAt.toIso8601String(),
          categoryIds.join(","),
          photo);
      if (success) {
        _titleController.clear();
        _stockController.clear();
        selectedIds.clear();
        _descriptionController.clear();
        _selectedDate = null;
        _imageFile = null;

        setState(() {});

        showCostumSnackBar(
            context: context,
            message: "Buku berhasil diajukan",
            backgroundColor: AppColors.greenColor!);
      } else {
        showCostumSnackBar(
            context: context,
            message: "Buku gagal diajukan",
            backgroundColor: AppColors.redColor!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BookCategoryProvider, OfficeAddressProvider>(
        builder: (context, bookCategoryProvider, officeAddressProvider, child) {
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
                        TextButton(
                            style: TextButton.styleFrom().copyWith(
                              overlayColor:
                                  WidgetStateProperty.all(AppColors.grey),
                            ),
                            onPressed: _pickImage,
                            child: Text(
                              "Tambah Gambar*",
                              style: AppStyles.labelTextStyle,
                            ))
                      ],
                    ),
                  ),
                  _buildTextFormField(
                      title: "Judul Buku*",
                      hint: "Nama Buku",
                      controller: _titleController),
                  _buildTextFormField(
                      title: "Jumlah Buku*",
                      hint: "10",
                      controller: _stockController,
                      isNumber: true),
                  _buildCategoriesChips(bookCategoryProvider.bookCategories),
                  _buildTextFormField(
                      title: "Deskripsi Buku*",
                      hint: "Deskripsi Buku",
                      controller: _descriptionController),
                  _buildTextFormField(
                      title: "Alamat Pemberian Buku",
                      hint: "Alamat buku dikirimkan",
                      controller: _addressController,
                      readOnly: true,
                      maxLines: 2),
                  DatePickerRow(
                    title: 'Tanggal pemberian*',
                    date: _selectedDate,
                    onDatePicked: (DateTime pickedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    },
                  ),
                  ButtonBuilder(
                      onPressed: () async {
                        if (_imageFile == null) {
                          final snackBar = SnackBar(
                              backgroundColor: AppColors.redColor,
                              content:
                                  Text("Mohon pilih gambar terlebih dahulu"));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          return;
                        }

                        if (_selectedDate == null) {
                          showCostumSnackBar(
                              context: context,
                              message: "Mohon pilih tanggal terlebih dahulu",
                              backgroundColor: AppColors.redColor!);
                          return;
                        }

                        if (selectedIds.isEmpty) {
                          showCostumSnackBar(
                              context: context,
                              message: "Mohon pilih kategori terlebih dahulu",
                              backgroundColor: AppColors.redColor!);
                          return;
                        }

                        await _submitForm(
                            name: _titleController.text,
                            description: _descriptionController.text,
                            stock: int.parse(_stockController.text),
                            planSentAt: _selectedDate ?? DateTime.now(),
                            categoryIds: selectedIds.toList(),
                            photo: _imageFile!,
                            context: context);
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

  _buildCategoriesChips(List<BookCategory> bookCategories) {
    final List<Map<String, dynamic>> options = bookCategories
        .where((e) => e.id != 0)
        .map((e) => {'name': e.name, 'id': e.id})
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Kategori Buku*", style: AppStyles.heading2TextStyle),
        Wrap(
          spacing: 2,
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
        Text(title, style: AppStyles.heading2TextStyle),
        TextFormField(
          readOnly: readOnly,
          style: AppStyles.labelTextStyle,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppStyles.hintTextStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.accentColor),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Mohon isi terlebih dahulu';
            }
            return null;
          },
          controller: controller,
        )
      ],
    );
  }
}
