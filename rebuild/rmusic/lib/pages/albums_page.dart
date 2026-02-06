import 'package:flutter/material.dart';
import '../models/album.dart';
import '../models/song.dart';
import '../theme/app_colors.dart';
import 'album_detail_page.dart';

enum ViewMode {
  grid,
  list,
}

class AlbumsPage extends StatefulWidget {
  final List<Album>? albums;
  final List<Song>? allSongs;
  final Function(Song)? onSongTap;
  final bool Function(String)? isFavorite;
  final Function(String)? onToggleFavorite;

  const AlbumsPage({
    super.key,
    this.albums,
    this.allSongs,
    this.onSongTap,
    this.isFavorite,
    this.onToggleFavorite,
  });

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  List<Album> _albums = [];
  ViewMode _viewMode = ViewMode.grid;

  @override
  void initState() {
    super.initState();
    _loadMockAlbums();
  }

  void _loadMockAlbums() {
    if (widget.albums != null) {
      _albums = widget.albums!;
      return;
    }

    _albums = [
      Album(
        id: '1',
        name: '最伟大的作品',
        artist: '周杰伦',
        songCount: 12,
        year: 2022,
      ),
      Album(
        id: '2',
        name: '摩天动物园',
        artist: '邓紫棋',
        songCount: 10,
        year: 2019,
      ),
      Album(
        id: '3',
        name: '幸存者',
        artist: '林俊杰',
        songCount: 11,
        year: 2021,
      ),
      Album(
        id: '4',
        name: 'Rising',
        artist: '华晨宇',
        songCount: 8,
        year: 2020,
      ),
      Album(
        id: '5',
        name: '无限',
        artist: '薛之谦',
        songCount: 9,
        year: 2018,
      ),
      Album(
        id: '6',
        name: '平凡的一天',
        artist: '毛不易',
        songCount: 11,
        year: 2018,
      ),
      Album(
        id: '7',
        name: '模特',
        artist: '李荣浩',
        songCount: 10,
        year: 2013,
      ),
      Album(
        id: '8',
        name: 'U87',
        artist: '陈奕迅',
        songCount: 11,
        year: 2005,
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
              child: _albums.isEmpty
                  ? _buildEmptyState()
                  : _viewMode == ViewMode.grid ? _buildAlbumsGrid() : _buildAlbumsList(),
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
                  '专辑',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_albums.length} 张专辑',
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
            Icons.album,
            size: 64,
            color: AppColors.borderLight,
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有专辑',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumsGrid() {
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
        children: _albums.map((album) => _buildAlbumCard(album)).toList(),
      ),
    );
  }

  Widget _buildAlbumsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _albums.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final album = _albums[index];
        return _buildAlbumListItem(album);
      },
    );
  }

  Widget _buildAlbumCard(Album album) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailPage(
              album: album,
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
                    Icons.album,
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
                    album.name,
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
                    album.artist,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${album.songCount} 首歌曲${album.year != null ? ' · ${album.year}' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
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

  Widget _buildAlbumListItem(Album album) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.album,
          color: AppColors.primary,
        ),
      ),
      title: Text(
        album.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${album.artist}${album.year != null ? ' · ${album.year}' : ''}',
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Text(
        '${album.songCount} 首',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textTertiary,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailPage(
              album: album,
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