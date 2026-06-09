import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../consts/padding_sizes.dart';
import '../providers/ranking_provider.dart';
import '../widgets/mobile_frame_builder.dart';
import '../widgets/ranking_list_item_builder.dart';
import '../widgets/ranking_period_filter_builder.dart';

class MyRangkingPage extends StatefulWidget {
  const MyRangkingPage({super.key});

  @override
  State<MyRangkingPage> createState() => _MyRangkingPageState();
}

class _MyRangkingPageState extends State<MyRangkingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RankingProvider>(context, listen: false).fetchRanking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // White background with subtle blur feel (blur is web-only; white gives the clean look)
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: MobileFrame(
          child: Consumer<RankingProvider>(
            builder: (context, provider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Custom AppBar ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        // Back button with proper margin from screen edge
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.grey),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.navigate_before,
                              color: AppColors.primaryColor,
                              size: 22,
                            ),
                          ),
                        ),
                        // Centered title
                        Expanded(
                          child: Center(
                            child: Text(
                              'Ranking',
                              style: AppStyles.heading2TextStyle,
                            ),
                          ),
                        ),
                        // Placeholder to balance the row
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Period filter ──────────────────────────────────────
                  RankingPeriodFilter(
                    selectedPeriod: provider.selectedPeriod,
                    onPeriodChanged: (period) => provider.changePeriod(period),
                  ),
                  const SizedBox(height: 16),

                  // ── Body ───────────────────────────────────────────────
                  Expanded(child: _buildBody(provider)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── State dispatcher ──────────────────────────────────────────────────────

  Widget _buildBody(RankingProvider provider) {
    switch (provider.state) {
      case RankingState.initial:
      case RankingState.loading:
        return _buildShimmer();
      case RankingState.error:
        return _buildErrorState(provider);
      case RankingState.loaded:
        return provider.users.isEmpty
            ? _buildEmptyState()
            : _buildLoadedContent(provider);
    }
  }

  // ── Shimmer skeleton ──────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey,
      highlightColor: AppColors.darkGrey,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // My rank card shimmer
            Column(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 12),
                // Name bar
                Container(
                    width: 120, height: 16, color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 8)),
                // Points bar
                Container(width: 80, height: 14, color: Colors.white),
                const SizedBox(height: 8),
                // Rank bar
                Container(width: 60, height: 14, color: Colors.white),
              ],
            ),
            const SizedBox(height: 24),
            // List item skeletons
            ...List.generate(6, (_) => _shimmerListItem()),
          ],
        ),
      ),
    );
  }

  Widget _shimmerListItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Row(
        children: [
          Container(width: 20, height: 14, color: Colors.white),
          const SizedBox(width: 10),
          Container(
            width: 40, height: 40, color: Colors.white,
            child: const CircleAvatar(backgroundColor: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(height: 14, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Container(width: 60, height: 14, color: Colors.white),
        ],
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────

  Widget _buildErrorState(RankingProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PaddingSizes.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.accentColor, size: 48),
            const SizedBox(height: PaddingSizes.medium),
            Text(
              provider.errorMessage ?? 'Terjadi kesalahan saat memuat data',
              style: AppStyles.hintTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PaddingSizes.medium),
            ElevatedButton(
              onPressed: () => provider.fetchRanking(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              child: Text(
                'Coba Lagi',
                style: AppStyles.labelWhiteTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Text('Belum ada data ranking', style: AppStyles.hintTextStyle),
    );
  }

  // ── Loaded content ────────────────────────────────────────────────────────

  Widget _buildLoadedContent(RankingProvider provider) {
    return Column(
      children: [
        _buildMyRankCard(provider),
        const SizedBox(height: 16),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Trigger load-more when within 200px of the bottom
              if (notification is ScrollUpdateNotification) {
                final metrics = notification.metrics;
                if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                  provider.fetchMore();
                }
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: provider.users.length + (provider.hasMore ? 1 : 0),
              separatorBuilder: (_, index) {
                // No separator after the last real item before the loader
                if (index == provider.users.length - 1 && provider.hasMore) {
                  return const SizedBox.shrink();
                }
                return const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F1F2),
                );
              },
              itemBuilder: (context, index) {
                // Load-more footer
                if (index == provider.users.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor),
                        ),
                      ),
                    ),
                  );
                }
                final user = provider.users[index];
                return RankingListItem(
                  rank: index + 1,
                  userProfile: user,
                  score: provider.getScoreForPeriod(user),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── My rank card (Figma node 390:1303) ────────────────────────────────────
  // Column, center, gap 12px
  // Avatar 60×60 circle
  // Name: Lato Bold 16 #090E13
  // Points row: trophy 20px + "X Point" Lato Regular 14 #7A8796, gap 4px
  // Rank: Lato Bold 14 #090E13

  Widget _buildMyRankCard(RankingProvider provider) {
    final user = provider.currentUser;
    final rank = provider.currentUserRank;
    final score = user != null ? provider.getScoreForPeriod(user) : 0;
    final photo = user?.profile.photo ?? '';
    final nama = user?.profile.nama ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar — 60×60 circle with shimmer placeholder
        _OwnAvatar(photo: photo),
        const SizedBox(height: 12),
        if (nama.isNotEmpty)
          Text(nama, style: AppStyles.heading2TextStyle),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/trophy.png', width: 20, height: 20),
            const SizedBox(width: 4),
            Text('$score Point', style: AppStyles.hintTextStyle),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          rank != null ? 'No. $rank' : 'No. -',
          style: AppStyles.labelBoldTextStyle,
        ),
      ],
    );
  }

  Widget _ownAvatarFallback() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.lightgrey,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 28, color: AppColors.accentColor),
    );
  }
}

// ── Own profile avatar with shimmer placeholder (60×60) ──────────────────────

class _OwnAvatar extends StatefulWidget {
  const _OwnAvatar({required this.photo});
  final String photo;

  @override
  State<_OwnAvatar> createState() => _OwnAvatarState();
}

class _OwnAvatarState extends State<_OwnAvatar> {
  bool _loaded = false;
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    const double size = 60;

    if (widget.photo.isEmpty || _error) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.lightgrey,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, size: 28, color: AppColors.accentColor),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Shimmer while image loads
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
          ClipOval(
            child: Image.network(
              '$serverPath/uploads/${widget.photo}',
              width: size,
              height: size,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_loaded) setState(() => _loaded = true);
                  });
                  return child;
                }
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
}
