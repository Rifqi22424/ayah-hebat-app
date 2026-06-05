// File: watch_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Provider
import '../../consts/rounded_sizes.dart';
import '../../providers/watch_provider.dart';

// Import file-file UI/Utils
import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';

// Import Widget & Page baru
import '../../widgets/video_card.dart';
import './watch_detail_page.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final watchProvider = Provider.of<WatchProvider>(context, listen: false);
    watchProvider.fetchWatches(refresh: true, limit: 10);

    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final watchProvider = Provider.of<WatchProvider>(context, listen: false);
      if (watchProvider.watchListState != WatchListState.loading) {
        watchProvider.fetchMoreWatches(
          limit: 10,
          search: _searchController.text,
        );
      }
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      Provider.of<WatchProvider>(context, listen: false).fetchWatches(
        refresh: true,
        search: _searchController.text,
        limit: 10,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Consumer<WatchProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchWatches(
                refresh: true,
                search: _searchController.text,
                limit: 10,
              ),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text('Kajian & Streaming',
                      style: AppStyles.heading2TextStyle),
                  const SizedBox(height: 4),
                  Text(
                    'Investasi Abadi untuk Masa Depan Gemilang',
                    style: AppStyles.hintTextStyle,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari disini...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.accentColor),
                      filled: true,
                      fillColor: AppColors.whiteColor,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 15.0),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(RoundedSizes.extraLarge),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(RoundedSizes.extraLarge),
                        borderSide:
                            BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(RoundedSizes.extraLarge),
                        borderSide:
                            BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildContentBody(provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContentBody(WatchProvider provider) {
    if (provider.watchListState == WatchListState.loading &&
        provider.contentList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.watchListState == WatchListState.error &&
        provider.contentList.isEmpty) {
      return Center(
        child: Text(
          'Gagal memuat data: ${provider.watchListError ?? "Error tidak diketahui"}',
          style: AppStyles.miniHintTextStyle,
        ),
      );
    }

    if (provider.contentList.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada video ditemukan',
          style: AppStyles.miniHintTextStyle,
        ),
      );
    }

    return Column(
      children: [
        ...provider.contentList.map((content) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: VideoCard(
              content: content,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchDetailPage(content: content),
                  ),
                );
              },
            ),
          );
        }).toList(),
        if (provider.watchListState == WatchListState.loading &&
            provider.contentList.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (!provider.hasMoreData && provider.contentList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text(
                'Semua video sudah ditampilkan',
                style: AppStyles.miniHintTextStyle,
              ),
            ),
          ),
      ],
    );
  }
}
