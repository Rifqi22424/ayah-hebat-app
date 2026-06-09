import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../models/user_profile_model.dart';

class RankingListItem extends StatelessWidget {
  const RankingListItem({
    super.key,
    required this.rank,
    required this.userProfile,
    required this.score,
  });

  final int rank;
  final UserProfile userProfile;
  final int score;

  @override
  Widget build(BuildContext context) {
    final profile = userProfile.profile;

    return Padding(
      // 14px top/bottom spacing between content and separator
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: rank number + avatar + name (gap 10px)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Rank number — SemiBold 14
                SizedBox(
                  width: 24,
                  child: Text(
                    '$rank.',
                    style: AppStyles.mediumTextStyle,
                  ),
                ),
                const SizedBox(width: 10),
                // Avatar — 40×40 with shimmer placeholder while loading
                _RankingAvatar(photo: profile.photo),
                const SizedBox(width: 10),
                // Name
                Flexible(
                  child: Text(
                    profile.nama,
                    style: AppStyles.mediumTextStyle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          // Right: trophy icon (20×20) + score (gap 4px)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('images/trophy.png', width: 20, height: 20),
              const SizedBox(width: 4),
              Text('$score Point', style: AppStyles.hintTextStyle),
            ],
          ),
        ],
      ),
    );
  }
}

/// Avatar widget that shows a shimmer placeholder until the network image loads,
/// then clips it to a perfect 40×40 circle.
class _RankingAvatar extends StatefulWidget {
  const _RankingAvatar({required this.photo});
  final String photo;

  @override
  State<_RankingAvatar> createState() => _RankingAvatarState();
}

class _RankingAvatarState extends State<_RankingAvatar> {
  bool _loaded = false;
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    const double size = 40;

    if (widget.photo.isEmpty || _error) {
      return _fallback(size);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Shimmer shown while image hasn't loaded yet
          if (!_loaded)
            Shimmer.fromColors(
              baseColor: AppColors.grey,
              highlightColor: AppColors.darkGrey,
              child: Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          // Actual image — constrained + clipped to circle
          ClipOval(
            child: Image.network(
              '$serverPath/uploads/${widget.photo}',
              width: size,
              height: size,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) {
                  // Image is ready — hide shimmer
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_loaded) setState(() => _loaded = true);
                  });
                  return child;
                }
                // Still loading — return transparent so shimmer shows through
                return const SizedBox.shrink();
              },
              errorBuilder: (_, __, ___) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _error = true);
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.lightgrey,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 20, color: AppColors.accentColor),
    );
  }
}
