// File: widgets/video_card.dart

import 'package:flutter/material.dart';

// Import Model
import '../consts/app_styles.dart';
import '../models/content_model.dart';

// Import file-file UI/Utils
import '../consts/app_colors.dart';
import '../utils/format_duration.dart';
import '../utils/format_upload_date.dart';
import '../utils/format_view.dart';
import '../../../../main.dart';

class VideoCard extends StatelessWidget {
  final Content content;
  final VoidCallback onTap;

  const VideoCard({
    super.key,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const String defaultThumbnailUrl =
        'https://placehold.co/640x360/E2E8F0/4A5568?text=Image+Not+Available';

    final String thumbnailUrl = content.thumbnailUrl.startsWith('http')
        ? content.thumbnailUrl
        : '$serverPath/${content.thumbnailUrl}';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  thumbnailUrl.isNotEmpty ? thumbnailUrl : defaultThumbnailUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: AppColors.darkGrey,
                      child: const Center(
                        child: CircularProgressIndicator(
                          // DIGANTI: Menggunakan warna primer
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: AppColors.primaryColor,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.accentColor,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (content.duration != null && content.duration! > 0)
                Container(
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    formatDuration(content.duration!),
                    style: const TextStyle(
                        color: AppColors.whiteColor, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    'images/ayah-hebat-logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.title,
                      style: AppStyles.heading3BoldTextStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatViews(content.views)} • ${formatUploadDate(content.publishedAt)}',
                      style: AppStyles.miniHintTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.description ?? '',
                      style: AppStyles.hintTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.accentColor),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  print('More options tapped for ${content.title}');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
