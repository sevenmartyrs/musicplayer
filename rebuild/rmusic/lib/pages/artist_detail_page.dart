import 'package:flutter/material.dart';
import '../models/artist.dart';
import '../models/song.dart';
import '../theme/app_colors.dart';
import '../widgets/song_list_item.dart';

class ArtistDetailPage extends StatefulWidget {
  final Artist artist;
  final List<Song>? songs;
  final Function(Song)? onSongTap;
  final bool Function(String)? isFavorite;
  final Function(String)? onToggleFavorite;

  const ArtistDetailPage({
    super.key,
    required this.artist,
    this.songs,
    this.onSongTap,
    this.isFavorite,
    this.onToggleFavorite,
  });

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  List<Song> get _artistSongs {
    if (widget.songs != null) {
      return widget.songs!;
    }
    // Mock 数据
    return [
      Song(
        id: '1',
        title: '示例歌曲 1',
        artist: widget.artist.name,
        album: '专辑 A',
        duration: 210,
      ),
      Song(
        id: '2',
        title: '示例歌曲 2',
        artist: widget.artist.name,
        album: '专辑 B',
        duration: 185,
      ),
      Song(
        id: '3',
        title: '示例歌曲 3',
        artist: widget.artist.name,
        album: '专辑 A',
        duration: 240,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildSongList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 24),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          // 封面
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.artist.coverUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.artist.coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.textSecondary,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.artist.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_artistSongs.length} 首歌曲',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '这位艺术家有 ${_artistSongs.length} 首精彩音乐作品',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    final songs = _artistSongs;
    
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 64,
              color: AppColors.borderLight,
            ),
            const SizedBox(height: 16),
            const Text(
              '暂无歌曲',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: songs.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final song = songs[index];
        final isFavorite = widget.isFavorite?.call(song.id) ?? false;
        return SongListItem(
          song: song,
          index: index + 1,
          onTap: () => widget.onSongTap?.call(song),
          showIndex: true,
          showFavorite: widget.onToggleFavorite != null,
          isFavorite: isFavorite,
          onToggleFavorite: widget.onToggleFavorite != null
              ? () => widget.onToggleFavorite!(song.id)
              : null,
          showMoreOptions: false,
        );
      },
    );
  }
}