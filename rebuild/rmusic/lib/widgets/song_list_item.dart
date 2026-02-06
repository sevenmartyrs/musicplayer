import 'package:flutter/material.dart';
import '../models/song.dart';
import '../theme/app_colors.dart';

/// 可复用的歌曲列表项组件
class SongListItem extends StatelessWidget {
  final Song song;
  final int? index;
  final VoidCallback onTap;
  final bool showIndex;
  final bool showFavorite;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final bool showMoreOptions;
  final VoidCallback? onMoreOptions;

  const SongListItem({
    super.key,
    required this.song,
    this.index,
    required this.onTap,
    this.showIndex = false,
    this.showFavorite = false,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.showMoreOptions = false,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 序号
            if (showIndex && index != null)
              SizedBox(
                width: 32,
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            if (showIndex && index != null) const SizedBox(width: 8),
            // 封面
            Container(
              width: showIndex ? 44 : 50,
              height: showIndex ? 44 : 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.backgroundTertiary,
              ),
              child: song.coverUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        song.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.music_note,
                            color: AppColors.textSecondary,
                            size: showIndex ? 20 : 24,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.music_note,
                      color: AppColors.textSecondary,
                      size: showIndex ? 20 : 24,
                    ),
            ),
            const SizedBox(width: 12),
            // 歌曲信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      fontSize: showIndex ? 15 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: TextStyle(
                      fontSize: showIndex ? 13 : 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 收藏图标
            if (showFavorite && onToggleFavorite != null)
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 22,
                ),
                color: isFavorite ? AppColors.red : AppColors.textTertiary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                onPressed: () => onToggleFavorite!(),
              ),
            // 时长
            Text(
              song.formattedDuration,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textQuaternary,
              ),
            ),
            // 更多选项
            if (showMoreOptions && onMoreOptions != null)
              IconButton(
                icon: const Icon(Icons.more_horiz, size: 22),
                color: AppColors.textTertiary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                onPressed: () => onMoreOptions!(),
              ),
          ],
        ),
      ),
    );
  }
}