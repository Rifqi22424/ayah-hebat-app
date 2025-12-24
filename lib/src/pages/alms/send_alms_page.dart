import 'dart:io';

import 'package:ayahhebat/src/consts/padding_sizes.dart';
import 'package:ayahhebat/src/mixins/validation_mixin.dart';
import 'package:ayahhebat/src/models/response/create_alms_response.dart';
import 'package:ayahhebat/src/providers/allocation_provider.dart';
import 'package:ayahhebat/src/utils/format_number.dart';
import 'package:ayahhebat/src/widgets/button_builder.dart';
import 'package:ayahhebat/src/widgets/snack_bar_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../api/alms_api.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../models/entity/allocation_model.dart';
import '../../widgets/app_bar_builder.dart';

class SendAlmsPage extends StatefulWidget {
  const SendAlmsPage({super.key});

  @override
  State<SendAlmsPage> createState() => _SendAlmsPageState();
}

class _SendAlmsPageState extends State<SendAlmsPage> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String? _selectedAlmsTypeCode;
  File? _transactionProofImage;
  final AlmsApi almsService = AlmsApi();
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<AllocationProvider>().fetchAllocations();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _transactionProofImage = File(image.path);
        });
      }
    } catch (e) {
      showCostumSnackBar(
          context: context, message: "Gagal memilih gambar: ${e.toString()}");
    }
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _transactionProofImage = File(image.path);
        });
      }
    } catch (e) {
      showCostumSnackBar(
          context: context, message: "Gagal mengambil foto: ${e.toString()}");
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pilih Sumber Gambar"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Galeri"),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Kamera"),
              onTap: () {
                Navigator.pop(context);
                _captureImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarBuilder(
        title: "Kirim Iuran",
        showBackButton: true,
        showCancelButton: false,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.asset("images/payment-card.png")),
                  SizedBox(height: PaddingSizes.medium),
                  Text("Nominal Transfer", style: AppStyles.labelBoldTextStyle),
                  SizedBox(height: PaddingSizes.extrasmall),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(PaddingSizes.medium),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(width: PaddingSizes.small),
                            Text("Rp. "),
                            SizedBox(width: PaddingSizes.small),
                            Expanded(
                              child: TextFormField(
                                style: AppStyles.labelTextStyle,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "0",
                                  hintStyle: AppStyles.hintTextStyle,
                                ),
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                validator: validateAmount,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                      if (newValue.text.isEmpty) {
                                        return newValue;
                                      }
                                      final number =
                                          int.tryParse(newValue.text);
                                      if (number == null) {
                                        return oldValue;
                                      }
                                      final formattedValue =
                                          formatNumber(number);
                                      return TextEditingValue(
                                        text: formattedValue,
                                        selection: TextSelection.collapsed(
                                            offset: formattedValue.length),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft:
                                        Radius.circular(PaddingSizes.medium),
                                    bottomRight:
                                        Radius.circular(PaddingSizes.medium),
                                  ),
                                  color: AppColors.grey,
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(PaddingSizes.medium),
                                  child: Text(
                                    "Minimal Rp. 10.000",
                                    style: AppStyles.hintTextStyle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: PaddingSizes.small),
                  Text("Type Iuran", style: AppStyles.labelBoldTextStyle),
                  SizedBox(height: PaddingSizes.extrasmall),
                  Consumer<AllocationProvider>(
                      builder: (context, value, child) {
                    if (value.state == AllocationState.initial ||
                        value.state == AllocationState.loading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    if (value.state == AllocationState.error) {
                      return Center(
                        child: TextButton(
                            onPressed: () => context
                                .read<AllocationProvider>()
                                .fetchAllocations(),
                            child: Text("Retry"),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.redColor,
                                disabledBackgroundColor:
                                    AppColors.halfRedColor)),
                      );
                    }

                    if (value.state == AllocationState.loaded &&
                        value.allocations.isEmpty) {
                      return Center(child: Text("Belum ada alokasi"));
                    }

                    return DropdownButtonFormField<String>(
                      validator: validateDropDown,
                      value: _selectedAlmsTypeCode,
                      style: AppStyles.labelTextStyle,
                      hint: Text("Pilih Alokasi Iuran",
                          style: AppStyles.hintTextStyle),
                      items: value.state == AllocationState.loading ||
                              value.state == AllocationState.initial
                          ? []
                          : value.allocations.map((Allocation allocation) {
                              return DropdownMenuItem<String>(
                                  value: allocation.code,
                                  child: Text(allocation.name));
                            }).toList(),
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(PaddingSizes.extraLarge)),
                      ),
                      onChanged: (Object? newValue) {
                        setState(() {
                          _selectedAlmsTypeCode = newValue as String;
                        });
                      },
                    );
                    ;
                  }),
                  SizedBox(height: PaddingSizes.small),
                  Text("Pesan (Opsional)", style: AppStyles.labelBoldTextStyle),
                  SizedBox(height: PaddingSizes.extrasmall),
                  TextFormField(
                    controller: _messageController,
                    style: AppStyles.labelTextStyle,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(PaddingSizes.extraLarge)),
                      hintText: "Tambahkan pesan...",
                      hintStyle: AppStyles.hintTextStyle,
                    ),
                    // maxLength: 200,
                  ),
                  SizedBox(height: PaddingSizes.small),
                  Text("Bukti Transfer", style: AppStyles.labelBoldTextStyle),
                  SizedBox(height: PaddingSizes.extrasmall),
                  InkWell(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _transactionProofImage == null
                              ? Colors.grey
                              : AppColors.primaryColor,
                        ),
                        borderRadius:
                            BorderRadius.circular(PaddingSizes.medium),
                      ),
                      child: _transactionProofImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: PaddingSizes.small),
                                Text("Pilih atau Ambil Foto",
                                    style: AppStyles.hintTextStyle),
                              ],
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(PaddingSizes.medium),
                              child: Image.file(
                                _transactionProofImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  if (_transactionProofImage != null) ...[
                    SizedBox(height: PaddingSizes.extrasmall),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _transactionProofImage = null;
                          });
                        },
                        icon: Icon(Icons.delete, color: AppColors.redColor),
                        label: Text("Hapus Gambar",
                            style: TextStyle(color: AppColors.redColor)),
                      ),
                    ),
                  ],
                  SizedBox(height: PaddingSizes.small),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ButtonBuilder(
            onPressed: _isSubmitting ? () async {} : _onSubmit,
            child: _isSubmitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.whiteColor,
                      strokeWidth: 2,
                    ),
                  )
                : Text("Kirim")),
      )),
    );
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_transactionProofImage == null) {
        showCostumSnackBar(
            context: context, message: "Silakan pilih bukti transfer");
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      final int numericAmount =
          int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
      final String allocationTypeCode = _selectedAlmsTypeCode ?? "";
      final String? message = _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim();

      try {
        print("numericAmount $numericAmount");
        final CreateAlmsResponse response = await almsService.createAlms(
          amount: numericAmount,
          allocationTypeCode: allocationTypeCode,
          transactionProof: _transactionProofImage!,
          message: message,
        );

        print("Alms Created: ${response.orderId}");

        setState(() {
          _amountController.clear();
          _messageController.clear();
          _selectedAlmsTypeCode = null;
          _transactionProofImage = null;
        });

        showCostumSnackBar(
            context: context,
            message: response.message,
            backgroundColor: AppColors.greenColor);

        Navigator.pop(context);
      } catch (e) {
        showCostumSnackBar(context: context, message: e.toString());
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
