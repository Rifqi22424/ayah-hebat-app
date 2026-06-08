import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../consts/padding_sizes.dart';
import '../mixins/validation_mixin.dart';
import '../models/kuttab_zone_model.dart';
import '../providers/kuttab_location_provider.dart';

/// Dropdown for selecting a Kuttab zone.
///
/// Renders a loading indicator while the provider is fetching, an error/empty
/// message when locations are unavailable, and a [DropdownButtonFormField]
/// once data is loaded.
class KuttabZoneDropdown extends StatelessWidget with ValidationMixin {
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
          style: AppStyles.labelTextStyle,
          hint: Text('Pilih zona Kuttab', style: AppStyles.hintTextStyle),
          validator: validator ??
              (v) {
                if (v == null) return 'Zona Kuttab wajib dipilih';
                return null;
              },
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(PaddingSizes.extraLarge),
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
