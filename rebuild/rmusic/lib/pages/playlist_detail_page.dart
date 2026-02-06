import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../widgets/song_list_item.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;
  final List<Song> allSongs;
  final Function(Song) onSongTap;
  final bool Function(String)? isFavorite;
  final Function(String)? onToggleFavorite;
  final Function(Playlist)? onEditPlaylist;
  final Function(String)? onDeletePlaylist;

  const PlaylistDetailPage({
    super.key,
    required this.playlist,
    required this.allSongs,
    required this.onSongTap,
    this.isFavorite,
    this.onToggleFavorite,
    this.onEditPlaylist,
    this.onDeletePlaylist,
  });

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late List<Song> _playlistSongs;

  @override
  void initState() {
    super.initState();
    _loadPlaylistSongs();
  }

  void _loadPlaylistSongs() {
    _playlistSongs = widget.allSongs
        .where((song) => widget.playlist.songIds.contains(song.id))
        .toList();
  }

  void _showPlaylistOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.playlist.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF007AFF)),
                title: const Text('编辑歌单'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditPlaylistDialog();
                },
              ),
              if (!widget.playlist.isDefault)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('删除歌单'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeletePlaylistDialog();
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditPlaylistDialog() async {
    final nameController = TextEditingController(text: widget.playlist.name);
    final descriptionController = TextEditingController(
      text: widget.playlist.description ?? '',
    );
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑歌单'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '歌单名称',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '歌单简介（可选）',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              
              final updatedPlaylist = widget.playlist.copyWith(
                name: name,
                description: descriptionController.text.trim().isEmpty 
                    ? null 
                    : descriptionController.text.trim(),
                updatedAt: DateTime.now(),
              );
              
              // 调用编辑回调
              if (widget.onEditPlaylist != null) {
                widget.onEditPlaylist!(updatedPlaylist);
              }
              
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeletePlaylistDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除歌单'),
        content: Text('确定要删除歌单"${widget.playlist.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 调用删除回调
              if (widget.onDeletePlaylist != null) {
                widget.onDeletePlaylist!(widget.playlist.id);
              }
              
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPlaylistInfo(),
                    const Divider(height: 1, color: Color(0xFFE5E5E5)),
                    _buildSongList(),
                  ],
                ),
              ),
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
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 24),
            color: const Color(0xFF333333),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.playlist.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 24),
            color: const Color(0xFF8E8E93),
            onPressed: () => _showPlaylistOptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 封面图和标题
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面图
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF5F5F5),
                ),
                child: widget.playlist.coverUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.playlist.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.playlist_play,
                              color: Color(0xFF007AFF),
                              size: 48,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.playlist_play,
                        color: Color(0xFF007AFF),
                        size: 48,
                      ),
              ),
              const SizedBox(width: 16),
              // 歌单信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.playlist.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.playlist.songCount} 首歌曲',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 简介
          if (widget.playlist.description != null &&
              widget.playlist.description!.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.playlist.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    if (_playlistSongs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.music_note,
              size: 64,
              color: const Color(0xFFE0E0E0),
            ),
            const SizedBox(height: 16),
            const Text(
              '歌单里还没有歌曲',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _playlistSongs.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return _buildSongItem(_playlistSongs[index], index + 1);
      },
    );
  }

  Widget _buildSongItem(Song song, int index) {
    final isFavorite = widget.isFavorite?.call(song.id) ?? false;

    return SongListItem(
      song: song,
      index: index,
      onTap: () => widget.onSongTap(song),
      showIndex: true,
      showFavorite: widget.onToggleFavorite != null,
      isFavorite: isFavorite,
      onToggleFavorite: widget.onToggleFavorite != null
          ? () => widget.onToggleFavorite!(song.id)
          : null,
      showMoreOptions: false,
    );
  }
}