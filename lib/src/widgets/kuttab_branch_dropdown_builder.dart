import 'package:flutter/material.dart';

import '../consts/app_styles.dart';
import '../consts/padding_sizes.dart';
import '../models/kuttab_branch_model.dart';

/// Dropdown for selecting a Kuttab branch.
///
/// [branches] must contain only the branches that belong to the currently
/// selected zone — filtering is the caller's responsibility (use
/// [KuttabLocationProvider.availableBranches]).
class KuttabBranchDropdown extends StatelessWidget {
  const KuttabBranchDropdown({
    super.key,
    required this.value,
    required this.branches,
    required this.onChanged,
    this.validator,
  });

  final KuttabBranch? value;
  final List<KuttabBranch> branches;
  final ValueChanged<KuttabBranch?> onChanged;

  /// Custom validator. Defaults to a required-selection check with the message
  /// "Lokasi Kuttab wajib dipilih".
  final FormFieldValidator<KuttabBranch>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<KuttabBranch>(
      initialValue: value,
      style: AppStyles.labelTextStyle,
      hint: Text('Pilih lokasi Kuttab', style: AppStyles.hintTextStyle),
      validator: validator ??
          (v) {
            if (v == null) return 'Lokasi Kuttab wajib dipilih';
            return null;
          },
      decoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PaddingSizes.extraLarge),
        ),
      ),
      items: branches.map((KuttabBranch branch) {
        return DropdownMenuItem<KuttabBranch>(
          value: branch,
          child: Text(branch.name),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
