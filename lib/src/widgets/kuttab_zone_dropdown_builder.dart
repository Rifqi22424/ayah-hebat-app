import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../models/kuttab_zone_model.dart';
import '../providers/kuttab_location_provider.dart';

/// Dropdown for selecting a Kuttab zone.
///
/// Renders a loading indicator while the provider is fetching, an error/empty
/// message when locations are unavailable, and a [DropdownButtonFormField]
/// once data is loaded.
///
/// Visual style matches the existing [FormBuilder] text fields in the profile
/// form: circular-32 border, 16/12 content padding, Lato label text.
class KuttabZoneDropdown extends StatelessWidget {
  const KuttabZoneDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  final KuttabZone? value;
  final ValueChanged<KuttabZone?> onChanged;

  /// Custom validator. Defaults to a required-selection check with the message
  /// "Zona Kuttab wajib dipilih".
  final FormFieldValidator<KuttabZone>? validator;

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
    return Consumer<KuttabLocationProvider>(
      builder: (context, provider, _) {
        if (provider.state == KuttabLocationState.initial ||
            provider.state == KuttabLocationState.loading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        if (provider.state == KuttabLocationState.error ||
            (provider.state == KuttabLocationState.loaded &&
                provider.zones.isEmpty)) {
          return Center(
            child: Text(
              'Lokasi tidak tersedia',
              style: AppStyles.hintTextStyle,
            ),
          );
        }

        return DropdownButtonFormField<KuttabZone>(
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
          items: provider.zones.map((KuttabZone zone) {
            return DropdownMenuItem<KuttabZone>(
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
