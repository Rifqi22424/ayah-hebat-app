import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../consts/padding_sizes.dart';
import '../consts/rounded_sizes.dart';

class ManageLoadingShimmer extends StatelessWidget {
  const ManageLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.only(
          left: PaddingSizes.medium,
          right: PaddingSizes.medium,
          bottom: PaddingSizes.medium,
        ),
        child: Column(
          children: [
            // Placeholder untuk image status
            Container(
              width: 126,
              height: 126,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(63),
              ),
            ),
            SizedBox(height: PaddingSizes.large),

            // Placeholder untuk title status
            Container(
              height: 20,
              width: 200,
              color: Colors.white,
            ),
            SizedBox(height: PaddingSizes.small),

            // Placeholder untuk description status
            Container(
              height: 14,
              width: 250,
              color: Colors.white,
            ),
            SizedBox(height: PaddingSizes.large),

            // Placeholder untuk gambar buku
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
              ),
            ),
            SizedBox(height: PaddingSizes.large),
            Divider(color: Colors.grey[300]),

            SizedBox(height: PaddingSizes.small),

            // Placeholder untuk rows informasi
            _buildShimmerRow(width1: 80, width2: 150),
            SizedBox(height: PaddingSizes.small),
            _buildShimmerRow(width1: 80, width2: 100),
            SizedBox(height: PaddingSizes.small),
            _buildShimmerRow(width1: 150, width2: 120),
            SizedBox(height: PaddingSizes.small),
            _buildShimmerRow(width1: 70, width2: 180),

            SizedBox(height: PaddingSizes.small),
            Divider(color: Colors.grey[300]),
            SizedBox(height: PaddingSizes.small),

            // Placeholder untuk tombol
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(RoundedSizes.extraLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerRow({required double width1, required double width2}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 12,
          width: width1,
          color: Colors.white,
        ),
        Container(
          height: 12,
          width: width2,
          color: Colors.white,
        ),
      ],
    );
  }
}
