import 'package:ayahhebat/src/models/branch_model.dart';
import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_styles.dart';

/// Dropdown for selecting a Kuttab branch.
///
/// [branches] must contain only the branches that belong to the currently
/// selected zone — filtering is the caller's responsibility (use
/// [KuttabLocationProvider.availableBranches]).
///
/// Visual style matches the existing [FormBuilder] text fields in the profile
/// form: circular-32 border, 16/12 content padding, Lato label text.
class BranchDropdown extends StatelessWidget {
  const BranchDropdown({
    super.key,
    required this.value,
    required this.branches,
    required this.onChanged,
    this.validator,
  });

  final Branch? value;
  final List<Branch> branches;
  final ValueChanged<Branch?> onChanged;

  /// Custom validator. Defaults to a required-selection check with the message
  /// "Lokasi Kuttab wajib dipilih".
  final FormFieldValidator<Branch>? validator;

  // Shared border radius to match FormBuilder (circular 32).
  static const _radius = Radius.circular(32);
  static const _borderRadius = BorderRadius.all(_radius);

  static const _baseBorder = OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: BorderSide(color: AppColors.blueColor, width: 2.0),
  );

  static const _focusedBorder = OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
  );

  static const _errorBorder = OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: BorderSide(color: Colors.red, width: 2.0),
  );

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Branch>(
      initialValue: value,
      // Suppress the default built-in arrow — we supply our own suffixIcon.
      icon: const SizedBox.shrink(),
      isExpanded: true,
      style: AppStyles.labelTextStyle,
      hint: Text('Pilih lokasi Kuttab', style: AppStyles.hintTextStyle),
      validator: validator ??
          (v) {
            if (v == null) return 'Lokasi Kuttab wajib dipilih';
            return null;
          },
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        border: _baseBorder,
        enabledBorder: _baseBorder,
        focusedBorder: _focusedBorder,
        errorBorder: _errorBorder,
        focusedErrorBorder: _errorBorder,
        hintStyle: AppStyles.hintTextStyle,
        errorStyle: AppStyles.heading3RedTextStyle,
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.accentColor,
        ),
      ),
      items: branches.map((Branch branch) {
        return DropdownMenuItem<Branch>(
          value: branch,
          child: Text(branch.name),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
