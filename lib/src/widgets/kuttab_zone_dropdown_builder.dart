import 'package:ayahhebat/src/models/zone_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../providers/zone_branch_provider.dart';

/// Dropdown for selecting a Kuttab zone.
///
/// Renders a loading indicator while the provider is fetching, an error/empty
/// message when locations are unavailable, and a [DropdownButtonFormField]
/// once data is loaded.
///
/// Visual style matches the existing [FormBuilder] text fields in the profile
/// form: circular-32 border, 16/12 content padding, Lato label text.
class ZoneDropdown extends StatelessWidget {
  const ZoneDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  final Zone? value;
  final ValueChanged<Zone?> onChanged;

  /// Custom validator. Defaults to a required-selection check with the message
  /// "Zona Kuttab wajib dipilih".
  final FormFieldValidator<Zone>? validator;

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
    return Consumer<ZoneBranchProvider>(
      builder: (context, provider, _) {
        if (provider.state == ZoneBranchState.initial ||
            provider.state == ZoneBranchState.loading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        if (provider.state == ZoneBranchState.error ||
            (provider.state == ZoneBranchState.loaded &&
                provider.zones.isEmpty)) {
          return Center(
            child: Text(
              'Lokasi tidak tersedia',
              style: AppStyles.hintTextStyle,
            ),
          );
        }

        return DropdownButtonFormField<Zone>(
          initialValue: value,
          // Suppress the default built-in arrow — we supply our own suffixIcon.
          icon: const SizedBox.shrink(),
          isExpanded: true,
          style: AppStyles.labelTextStyle,
          hint: Text('Pilih zona Kuttab', style: AppStyles.hintTextStyle),
          validator: validator ??
              (v) {
                if (v == null) return 'Zona Kuttab wajib dipilih';
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
          items: provider.zones.map((Zone zone) {
            return DropdownMenuItem<Zone>(
              value: zone,
              child: Text(zone.name),
            );
          }).toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}
