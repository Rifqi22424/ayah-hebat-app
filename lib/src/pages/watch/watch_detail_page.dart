// File: watch_detail_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Import Provider
import '../../models/playlist_content_item_model.dart';
import '../../providers/watch_provider.dart';
import '../../providers/playlist_provider.dart';

// Import Model
import '../../models/content_model.dart';

// Import file-file UI/Utils
import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../utils/format_duration.dart';
import '../../utils/format_upload_date.dart';
import '../../utils/format_view.dart';
import '../../utils/share_utils.dart';

// Import Widget
import '../../widgets/video_card.dart';
import '../../../../main.dart'; // <-- Pastikan ini benar (import serverPath)

class WatchDetailPage extends StatefulWidget {
  final Content content;
  const WatchDetailPage({super.key, required this.content});

  @override
  State<WatchDetailPage> createState() => _WatchDetailPageState();
}

class _WatchDetailPageState extends State<WatchDetailPage> {
  late YoutubePlayerController _controller;
  String? _videoId;
  final UniqueKey _visibilityKey = UniqueKey();

  late ScrollController _scrollController;
  bool _isScrolledDown = false;
  bool _isPlaying = false;
  bool _isDescriptionExpanded = false;

  bool _isPlaylist = false;
  int? _playlistId;

  // --- State untuk View Count ---
  bool _hasIncrementedView = false;
  late int _currentViews;

  /// [Baru] 'Stopwatch' untuk menghitung total waktu tonton aktif
  Duration _cumulativeWatchTime = Duration.zero;

  /// [Baru] Menyimpan posisi terakhir untuk mendeteksi 'scrubbing'
  Duration _lastPlayerPosition = Duration.zero;
  // --- State Selesai ---

  final double _appBarHideThreshold = 50.0;

  @override
  void initState() {
    super.initState();

    _currentViews = widget.content.views;
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _videoId = YoutubePlayer.convertUrlToId(widget.content.videoUrl);

    if (_videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          forceHD: true,
        ),
      );
      _controller.addListener(_playerListener);
    }

    if (widget.content.playlistContent.isNotEmpty) {
      _isPlaylist = true;
      _playlistId = widget.content.playlistContent[0].playlist.id;
      Provider.of<PlaylistProvider>(context, listen: false)
          .fetchPlaylistById(_playlistId!);
    } else {
      _isPlaylist = false;
    }
  }

  void _scrollListener() {
    final bool isNowScrolledDown =
        _scrollController.offset > _appBarHideThreshold;
    if (isNowScrolledDown != _isScrolledDown) {
      setState(() {
        _isScrolledDown = isNowScrolledDown;
      });
    }
  }

  /// Listener yang diperbarui dengan logika "Stopwatch Kumulatif"
  void _playerListener() {
    final currentPosition = _controller.value.position;
    final isNowPlaying = _controller.value.isPlaying;

    // Hanya proses jika view belum dihitung DAN player siap
    if (!_hasIncrementedView && _controller.value.isReady) {
      final totalDuration = _controller.value.metaData.duration;

      // Pastikan durasi valid
      if (totalDuration > Duration.zero) {
        // --- Logika Stopwatch Kumulatif ---
        // 1. Kita hanya menambah waktu jika videonya sedang 'PLAYING'
        if (isNowPlaying) {
          // 2. Hitung selisih waktu dari pengecekan terakhir
          final delta = currentPosition - _lastPlayerPosition;

          // 3. Tentukan batas 'scrubbing' (misal 2 detik)
          // Jika selisihnya lebih dari 2 detik, itu lompatan/scrub.
          const int scrubThresholdMs = 2000;

          // 4. Cek apakah ini pemutaran alami
          // (selisihnya positif dan di bawah batas scrub)
          bool isNaturalPlayback = delta.inMilliseconds > 0 &&
              delta.inMilliseconds < scrubThresholdMs;

          if (isNaturalPlayback) {
            // 5. Tambahkan ke 'Stopwatch' kita
            _cumulativeWatchTime += delta;

            // debugPrint('Waktu tonton aktif: ${_cumulativeWatchTime.inSeconds} detik');
          }
        }

        // --- Logika Pengecekan View ---
        // Hitung target 50%
        final halfWayPointMs = totalDuration.inMilliseconds / 2;

        // Cek apakah 'Stopwatch' kita sudah mencapai target
        if (_cumulativeWatchTime.inMilliseconds >= halfWayPointMs) {
          // SUDAH MENCAPAI 50% SECARA KUMULATIF!
          Provider.of<WatchProvider>(context, listen: false)
              .incrementView(widget.content.id);

          setState(() {
            _hasIncrementedView = true;
            _currentViews++;
          });

          debugPrint(
              'View incremented (CUMULATIVE 50%) for video ${widget.content.id}');
        }
      }
    }

    // Selalu update posisi terakhir untuk pengecekan berikutnya
    _lastPlayerPosition = currentPosition;

    // Logika untuk play/pause (state overlay)
    if (isNowPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isNowPlaying;
      });
    }
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteColor,
      builder: (BuildContext bContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.share, color: AppColors.accentColor),
                title: Text('Bagikan', style: AppStyles.heading3TextStyle),
                onTap: () {
                  Navigator.of(bContext).pop();
                  shareVideo(
                    context,
                    widget.content.title,
                    widget.content.videoUrl,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: AppColors.accentColor),
                title: Text('Salin Link', style: AppStyles.heading3TextStyle),
                onTap: () {
                  Navigator.of(bContext).pop();
                  copyLink(context, widget.content.videoUrl);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    if (_videoId != null) {
      _controller.removeListener(_playerListener);
      _controller.dispose();
    }
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Error")),
        body: Center(child: Text("URL Video tidak valid.")),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.redColor,
        progressColors: ProgressBarColors(
          playedColor: AppColors.redColor,
          handleColor: AppColors.redColor,
        ),
      ),
      builder: (context, player) {
        final bool isOverlayVisible = !_isScrolledDown && !_isPlaying;
        return VisibilityDetector(
          key: _visibilityKey,
          onVisibilityChanged: (visibilityInfo) {
            if (visibilityInfo.visibleFraction == 0.0 && _videoId != null) {
              if (_controller.value.isReady && _controller.value.isPlaying) {
                _controller.pause();
              }
            }
          },
          child: WillPopScope(
            onWillPop: () async {
              _controller.pause();
              _controller.dispose();
              return true;
            },
            child: Scaffold(
              backgroundColor: AppColors.whiteColor,
              body: Stack(
                children: [
                  Consumer2<WatchProvider, PlaylistProvider>(
                    builder: (context, watchProvider, playlistProvider, child) {
                      return ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          // 1. Video Player
                          SafeArea(
                            bottom: false,
                            child: player,
                          ),

                          // 2. Playlist Dropdown (HANYA jika video ini bagian dari playlist)
                          _buildPlaylistSection(context, playlistProvider),

                          // 3. Detail Video (Judul, Views, Deskripsi)
                          _buildVideoDetails(context),

                          // 4. List Rekomendasi (Selalu tampil di bawah)
                          _buildRecommendationSection(context, watchProvider),
                        ],
                      );
                    },
                  ),
                  _buildAnimatedGradientOverlay(context, isOverlayVisible),
                  _buildAnimatedCustomBackButton(context, isOverlayVisible),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget untuk menampilkan Judul, Views, dan Deskripsi Video
  Widget _buildVideoDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.content.title,
                        style: AppStyles.heading2TextStyle),
                    const SizedBox(height: 4),
                    Text(
                      '${formatViews(_currentViews)} • ${formatUploadDate(widget.content.publishedAt)}',
                      style: AppStyles.hintTextStyle,
                    ),
                    const SizedBox(height: 8),
                    _buildExpandableDescription(context),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.accentColor),
                onPressed: () {
                  _showShareOptions(context);
                },
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Divider(),
        ),
      ],
    );
  }

  Widget _buildPlaylistSection(
      BuildContext context, PlaylistProvider playlistProvider) {
    if (!_isPlaylist) {
      return const SizedBox.shrink();
    }

    String nextTitle = "Tidak ada video berikutnya";
    String nextDesc = "";
    if (playlistProvider.playlistDetailState == PlaylistDetailState.loaded) {
      final items = playlistProvider.currentPlaylist!.contents;
      final currentIndex =
          items.indexWhere((item) => item.content.id == widget.content.id);
      if (currentIndex != -1 && currentIndex < items.length - 1) {
        nextTitle = items[currentIndex + 1].content.title;
        nextDesc = items[currentIndex + 1].content.description ?? "";
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.darkYellow,
          collapsedIconColor: AppColors.accentColor,
          tilePadding: const EdgeInsets.all(8.0),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Berikutnya: $nextTitle',
                      style: AppStyles.heading2TextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nextDesc,
                      style: AppStyles.hintTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
              child: _buildPlaylistItems(playlistProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistItems(PlaylistProvider playlistProvider) {
    if (playlistProvider.playlistDetailState == PlaylistDetailState.loading) {
      // DIGANTI: Menambahkan warna primer
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor));
    }
    if (playlistProvider.playlistDetailState == PlaylistDetailState.error) {
      return Center(
          child: Text(
        'Gagal memuat playlist: ${playlistProvider.playlistDetailError}',
        style: AppStyles.heading3TextStyle,
      ));
    }
    if (playlistProvider.playlistDetailState == PlaylistDetailState.loaded) {
      final playlistItems = playlistProvider.currentPlaylist!.contents.toList();

      if (playlistItems.isEmpty) {
        return Center(
            child: Text(
          'Tidak ada video di playlist ini.',
          style: AppStyles.heading3TextStyle,
        ));
      }

      return Column(
        children: playlistItems.asMap().entries.map((entry) {
          int index = entry.key;
          PlaylistContentItem item = entry.value;

          Content contentFromPlaylist = Content(
            id: item.content.id,
            title: item.content.title,
            description: item.content.description,
            thumbnailUrl: '$serverPath/${item.content.thumbnailUrl}',
            videoUrl: item.content.videoUrl,
            duration: item.content.duration,
            views: item.content.views,
            publishedAt: item.content.publishedAt,
            uploaderId: item.content.uploaderId,
            uploader: item.content.uploader,
            playlistContent: widget.content.playlistContent,
          );

          bool isCurrentlyPlaying = (item.content.id == widget.content.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildPlaylistVideoCard(
              contentFromPlaylist,
              isCurrentlyPlaying,
              index + 1,
            ),
          );
        }).toList(),
      );
    }
    return Center(
        child: Text(
      'Memuat playlist...',
      style: AppStyles.heading3TextStyle,
    ));
  }

  Widget _buildRecommendationSection(
      BuildContext context, WatchProvider watchProvider) {
    final recommendedVideos = watchProvider.contentList
        .where((c) => c.id != widget.content.id)
        .toList();

    if (recommendedVideos.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Tidak ada rekomendasi lain.',
            style: AppStyles.heading3TextStyle,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rekomendasi',
            style: AppStyles.heading1TextStyle,
          ),
          const SizedBox(height: 12.0),
          ...recommendedVideos
              .map((recContent) => Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: _buildRecommendationCard(recContent, false),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildExpandableDescription(BuildContext context) {
    final style = const TextStyle(color: AppColors.accentColor, fontSize: 15);
    final text = widget.content.description ?? "Tidak ada deskripsi.";

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: text, style: style);
        final painter = TextPainter(
          text: span,
          maxLines: 2,
          textDirection: TextDirection.ltr,
        );
        painter.layout(maxWidth: constraints.maxWidth);

        if (painter.didExceedMaxLines) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: style,
                maxLines: _isDescriptionExpanded ? null : 2,
                overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDescriptionExpanded = !_isDescriptionExpanded;
                  });
                },
                child: Text(
                  _isDescriptionExpanded ? 'Tutup' : '...selengkapnya',
                  style: AppStyles.heading3PrimaryTextStyle,
                ),
              ),
            ],
          );
        } else {
          return Text(text, style: style);
        }
      },
    );
  }

  Widget _buildPlaylistVideoCard(
      Content content, bool isCurrentlyPlaying, int playlistIndex) {
    return InkWell(
      onTap: () {
        if (isCurrentlyPlaying) return;

        _controller.pause();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WatchDetailPage(content: content),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isCurrentlyPlaying
              ? AppColors.redColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 8.0),
              child: Text(
                '$playlistIndex',
                style: isCurrentlyPlaying
                    ? AppStyles.heading3BoldTextStyle
                        .copyWith(color: AppColors.darkYellow)
                    : AppStyles.hintTextStyle,
              ),
            ),
            SizedBox(
              width: 100,
              height: 56,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.network(
                      content.thumbnailUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                              ? child
                              : Container(
                                  color: AppColors.grey,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      // DIGANTI: Menggunakan warna primer
                                      color: AppColors.primaryColor,
                                      strokeWidth: 2.0,
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                ),
                      errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.grey,
                          child: Icon(Icons.broken_image, size: 24)),
                    ),
                  ),
                  if (content.duration != null && content.duration! > 0)
                    Positioned(
                      bottom: 4.0,
                      right: 4.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                        child: Text(
                          formatDuration(content.duration!),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: isCurrentlyPlaying
                        ? AppStyles.heading3BoldTextStyle
                        : AppStyles.heading3TextStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    content.uploader.username,
                    style: AppStyles.miniHintTextStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.more_vert, color: AppColors.accentColor, size: 20.0),
          ],
        ),
      ),
    );
  }

  /// Helper untuk membuat card rekomendasi (menggunakan VideoCard)
  Widget _buildRecommendationCard(Content recContent, bool inPlaylist) {
    return VideoCard(
      content: recContent,
      onTap: () {
        _controller.pause();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WatchDetailPage(content: recContent),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedGradientOverlay(BuildContext context, bool isVisible) {
    final double topPosition = isVisible ? 0 : -100.0;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      top: topPosition,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        child: SafeArea(
          bottom: false,
          child: IgnorePointer(
            child: Container(
              height: 100.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCustomBackButton(BuildContext context, bool isVisible) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topPosition =
        isVisible ? statusBarHeight + 8.0 : -(statusBarHeight + 50.0);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      top: topPosition,
      left: 16.0,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        child: GestureDetector(
          onTap: () {
            _controller.pause();
            _controller.dispose();
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.darkYellow,
              size: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}
