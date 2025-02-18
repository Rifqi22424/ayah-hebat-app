import 'package:ayahhebat/src/consts/padding_sizes.dart';
import 'package:ayahhebat/src/mixins/validation_mixin.dart';
import 'package:ayahhebat/src/models/response/create_infaq_response.dart';
import 'package:ayahhebat/src/providers/allocation_provider.dart';
import 'package:ayahhebat/src/utils/format_number.dart';
import 'package:ayahhebat/src/utils/shared_preferences.dart';
import 'package:ayahhebat/src/widgets/button_builder.dart';
import 'package:ayahhebat/src/widgets/snack_bar_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../api/infaq_api.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../models/entity/allocation_model.dart';
import '../../widgets/app_bar_builder.dart';

class SendInfaqPage extends StatefulWidget {
  const SendInfaqPage({super.key});

  @override
  State<SendInfaqPage> createState() => _SendInfaqPageState();
}

class _SendInfaqPageState extends State<SendInfaqPage> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _gmailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _selectedInfaqTypeCode;
  final InfaqApi infaqService = InfaqApi();

  @override
  void initState() {
    super.initState();
    context.read<AllocationProvider>().fetchAllocations();
    _fetchDefaultValue();
  }

  _fetchDefaultValue() async {
    String? gmail = await SharedPreferencesHelper.getEmail();
    String? phoneNumber = await SharedPreferencesHelper.getPhoneNumber();
    _gmailController.text = gmail ?? "";
    _phoneNumberController.text = phoneNumber ?? "";
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
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
                                String formatted =
                                    formatStringToNumber(newValue.text);
                                return TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(
                                      offset: formatted.length),
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
                            // border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.only(
                                bottomLeft:
                                    Radius.circular(PaddingSizes.medium),
                                bottomRight:
                                    Radius.circular(PaddingSizes.medium)),
                            color: AppColors.grey,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(PaddingSizes.small),
                            child: Text("Minimum Rp. 10.000",
                                style: AppStyles.hintTextStyle),
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
            Container(
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(PaddingSizes.extraLarge),
              //   border: Border.all(color: AppColors.pureGrey),
              // ),
              child: Consumer<AllocationProvider>(
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
                            disabledBackgroundColor: AppColors.halfRedColor)),
                  );
                }

                if (value.state == AllocationState.loaded &&
                    value.allocations.isEmpty) {
                  return Center(child: Text("Belum ada alokasi"));
                }

                return Expanded(
                  child: DropdownButtonFormField<String>(
                    validator: validateDropDown,
                    value: _selectedInfaqTypeCode,
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
                        _selectedInfaqTypeCode = newValue as String;
                      });
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: PaddingSizes.small),
            Text("Masukan Gmail", style: AppStyles.labelBoldTextStyle),
            SizedBox(height: PaddingSizes.extrasmall),
            TextFormField(
              style: AppStyles.labelTextStyle,
              validator: validateEmail,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(PaddingSizes.extraLarge)),
                  hintText: "example@gmail.com",
                  hintStyle: AppStyles.hintTextStyle,
                  isDense: true),
              controller: _gmailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: PaddingSizes.small),
            Text("Masukan Nomor Handphone",
                style: AppStyles.labelBoldTextStyle),
            SizedBox(height: PaddingSizes.extrasmall),
            Expanded(
              child: TextFormField(
                validator: validatePhone,
                style: AppStyles.labelTextStyle,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(PaddingSizes.extraLarge)),
                  hintText: "08123456789",
                  hintStyle: AppStyles.hintTextStyle,
                ),
                controller: _phoneNumberController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ButtonBuilder(onPressed: _onSubmit, child: Text("Kirim")),
      )),
    );
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final int numericAmount =
          int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
      final String email = _gmailController.text;
      final String phoneNumber = _phoneNumberController.text.toString();
      final String allocationTypeCode = _selectedInfaqTypeCode ?? "";

      try {
        final CreateInfaqResponse response = await infaqService.createInfaq(
            amount: numericAmount,
            phoneNumber: phoneNumber,
            email: email,
            allocationTypeCode: allocationTypeCode);

        print("Redirect URL: ${response.redirectUrl}");

        SharedPreferencesHelper.savePhoneNumber(phoneNumber);

        Navigator.pushNamed(context, '/payMethodInfaq', arguments: {
          'redirectUrl': response.redirectUrl,
        });
      } catch (e) {
        showCostumSnackBar(context: context, message: e.toString());
      }
    }
  }
}
