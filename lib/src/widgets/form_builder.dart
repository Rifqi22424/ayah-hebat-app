import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';

class FormBuilder extends StatefulWidget {
  final TextEditingController formController;
  final String hintText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool isDescription;
  final TextInputType keyboardType;

  const FormBuilder(
      {Key? key,
      required this.hintText,
      required this.formController,
      required this.validator,
      required this.isPassword,
      required this.isDescription, required this.keyboardType})
      : super(key: key);

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  bool isObsecure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.formController,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.blueColor,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        hintStyle: AppStyles.hintTextStyle,
        errorStyle: AppStyles.heading3RedTextStyle,
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    isObsecure = !isObsecure;
                  });
                },
                child: Icon(isObsecure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
              )
            : null,
      ),
      minLines: widget.isDescription ? 5 : null,
      maxLines: widget.isDescription ? 5 : 1,
      style: AppStyles.labelTextStyle,
      validator: widget.validator,
      inputFormatters:
          widget.isDescription ? [SingleLineInputFormatter()] : null,
      obscureText: widget.isPassword ? isObsecure : false,
    );
  }
}

class SingleLineInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String formattedText = newValue.text.replaceAll(RegExp(r'\n|\s{2,}'), ' ');

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
