import 'package:flutter/material.dart';
import '../models/artist.dart';
import '../models/song.dart';
import '../theme/app_colors.dart';
import 'artist_detail_page.dart';

enum ViewMode {
  grid,
  list,
}

class ArtistsPage extends StatefulWidget {
  final List<Artist>? artists;
  final List<Song>? allSongs;
  final Function(Song)? onSongTap;
  final bool Function(String)? isFavorite;
  final Function(String)? onToggleFavorite;

  const ArtistsPage({
    super.key,
    this.artists,
    this.allSongs,
    this.onSongTap,
    this.isFavorite,
    this.onToggleFavorite,
  });

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  List<Artist> _artists = [];
  ViewMode _viewMode = ViewMode.grid;

  @override
  void initState() {
    super.initState();
    _loadMockArtists();
  }

  void _loadMockArtists() {
    if (widget.artists != null) {
      _artists = widget.artists!;
      return;
    }

    _artists = [
      Artist(
        id: '1',
        name: '周杰伦',
        songCount: 25,
      ),
      Artist(
        id: '2',
        name: '邓紫棋',
        songCount: 18,
      ),
      Artist(
        id: '3',
        name: '林俊杰',
        songCount: 22,
      ),
      Artist(
        id: '4',
        name: '陈奕迅',
        songCount: 30,
      ),
      Artist(
        id: '5',
        name: '薛之谦',
        songCount: 15,
      ),
      Artist(
        id: '6',
        name: '毛不易',
        songCount: 12,
      ),
      Artist(
        id: '7',
        name: '李荣浩',
        songCount: 20,
      ),
      Artist(
        id: '8',
        name: '华晨宇',
        songCount: 16,
      ),
    ];
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    });
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
              child: _artists.isEmpty
                  ? _buildEmptyState()
                  : _viewMode == ViewMode.grid ? _buildArtistsGrid() : _buildArtistsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '艺术家',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_artists.length} 位艺术家',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _viewMode == ViewMode.grid ? Icons.view_list : Icons.grid_view,
              size: 24,
            ),
            color: AppColors.primary,
            onPressed: _toggleViewMode,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 64,
            color: AppColors.borderLight,
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有艺术家',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistsGrid() {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isDesktop ? 5 : 3;
    final aspectRatio = isDesktop ? 1.0 : 1.0;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: aspectRatio,
        children: _artists.map((artist) => _buildArtistCard(artist)).toList(),
      ),
    );
  }

  Widget _buildArtistsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _artists.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final artist = _artists[index];
        return _buildArtistListItem(artist);
      },
    );
  }

  Widget _buildArtistCard(Artist artist) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistDetailPage(
              artist: artist,
              songs: widget.allSongs,
              onSongTap: widget.onSongTap ?? (song) {},
              isFavorite: widget.isFavorite,
              onToggleFavorite: widget.onToggleFavorite,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${artist.songCount} 首歌曲',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistListItem(Artist artist) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.person,
          color: AppColors.primary,
        ),
      ),
      title: Text(
        artist.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${artist.songCount} 首歌曲',
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textTertiary,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistDetailPage(
              artist: artist,
              songs: widget.allSongs,
              onSongTap: widget.onSongTap ?? (song) {},
              isFavorite: widget.isFavorite,
              onToggleFavorite: widget.onToggleFavorite,
            ),
          ),
        );
      },
    );
  }
}