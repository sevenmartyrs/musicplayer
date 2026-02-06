import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import 'playlist_detail_page.dart';

enum ViewMode {
  grid,
  list,
}

class PlaylistsPage extends StatefulWidget {
  final Function(String)? onPlaylistTap;
  final List<Song>? allSongs;
  final Function(Song)? onSongTap;
  final bool Function(String)? isFavorite;
  final Function(String)? onToggleFavorite;
  final List<Playlist>? playlists;
  final Function(List<Playlist>)? onPlaylistsUpdated;
  final Function(Playlist)? onEditPlaylist;
  final Function(String)? onDeletePlaylist;

  const PlaylistsPage({
    super.key,
    this.onPlaylistTap,
    this.allSongs,
    this.onSongTap,
    this.isFavorite,
    this.onToggleFavorite,
    this.playlists,
    this.onPlaylistsUpdated,
    this.onEditPlaylist,
    this.onDeletePlaylist,
  });

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  List<Playlist> _playlists = [];
  ViewMode _viewMode = ViewMode.grid;

  @override
  void initState() {
    super.initState();
    _loadMockPlaylists();
  }

  void _loadMockPlaylists() {
    // 优先使用外部传入的歌单列表
    if (widget.playlists != null) {
      _playlists = widget.playlists!;
      return;
    }

    // Mock 数据 - "我喜欢的"是默认不可删除的歌单
    _playlists = [
      Playlist.create(
        name: '我喜欢的',
        songIds: ['1', '2'],
        isDefault: true,
        description: '我收藏的所有喜欢的音乐',
      ),
      Playlist.create(
        name: '工作音乐',
        songIds: ['3', '4', '5'],
        description: '适合工作时听的专注音乐',
      ),
      Playlist.create(
        name: '放松音乐',
        songIds: ['1', '3'],
        description: '舒缓的音乐，让人放松心情',
      ),
      Playlist.create(
        name: '运动歌单',
        songIds: ['2', '4', '5'],
        description: '充满活力的运动音乐',
      ),
      Playlist.create(
        name: '晚间冥想',
        songIds: ['1', '2', '3'],
        description: '适合晚间冥想和睡眠的轻音乐',
      ),
      Playlist.create(
        name: '旅途时光',
        songIds: ['3', '4'],
        description: '旅途中陪伴的音乐',
      ),
      Playlist.create(
        name: '电子乐',
        songIds: ['1', '5'],
        description: '精选电子音乐合集',
      ),
      Playlist.create(
        name: '经典老歌',
        songIds: ['2', '3', '4'],
        description: '怀旧经典，时光回响',
      ),
    ];
  }

  Future<void> _showCreatePlaylistDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建歌单'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: '输入歌单名称',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: '输入歌单简介（可选）',
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
              
              final playlist = Playlist.create(
                name: name,
                description: descriptionController.text.trim().isEmpty 
                    ? null 
                    : descriptionController.text.trim(),
              );
              setState(() {
                _playlists.add(playlist);
              });
              
              // 通知外部更新歌单列表
              if (widget.onPlaylistsUpdated != null) {
                widget.onPlaylistsUpdated!(_playlists);
              }
              
              Navigator.pop(context);
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPlaylistDialog(Playlist playlist) async {
    final nameController = TextEditingController(text: playlist.name);
    final descriptionController = TextEditingController(
      text: playlist.description ?? '',
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
              
              final updatedPlaylist = playlist.copyWith(
                name: name,
                description: descriptionController.text.trim().isEmpty 
                    ? null 
                    : descriptionController.text.trim(),
                updatedAt: DateTime.now(),
              );
              
              setState(() {
                final index = _playlists.indexWhere((p) => p.id == playlist.id);
                if (index >= 0) {
                  _playlists[index] = updatedPlaylist;
                }
              });
              
              // 通知外部更新歌单列表
              if (widget.onPlaylistsUpdated != null) {
                widget.onPlaylistsUpdated!(_playlists);
              }
              
              // 调用编辑回调
              if (widget.onEditPlaylist != null) {
                widget.onEditPlaylist!(updatedPlaylist);
              }
              
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeletePlaylistDialog(Playlist playlist) async {
    if (playlist.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('默认歌单不能删除')),
      );
      return;
    }
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除歌单'),
        content: Text('确定要删除歌单"${playlist.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _playlists.removeWhere((p) => p.id == playlist.id);
              });
              
              // 通知外部更新歌单列表
              if (widget.onPlaylistsUpdated != null) {
                widget.onPlaylistsUpdated!(_playlists);
              }
              
              // 调用删除回调
              if (widget.onDeletePlaylist != null) {
                widget.onDeletePlaylist!(playlist.id);
              }
              
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
              child: _playlists.isEmpty
                  ? _buildEmptyState()
                  : _viewMode == ViewMode.grid ? _buildPlaylistsGrid() : _buildPlaylistsList(),
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
                  '歌单',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_playlists.length} 个歌单',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF007AFF),
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
            color: const Color(0xFF007AFF),
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
            Icons.playlist_play,
            size: 64,
            color: const Color(0xFFD1D1D6),
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有歌单',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _showCreatePlaylistDialog,
            icon: const Icon(Icons.add),
            label: const Text('创建歌单'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsGrid() {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isDesktop ? 5 : 3;
    final aspectRatio = isDesktop ? 1.05 : 1.0;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: aspectRatio,
        children: [
          _buildCreateCard(),
          ..._playlists.map((playlist) => _buildPlaylistCard(playlist)),
        ],
      ),
    );
  }

  Widget _buildPlaylistsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _playlists.length + 1,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildCreateListItem();
        }
        final playlist = _playlists[index - 1];
        return _buildPlaylistListItem(playlist);
      },
    );
  }

  Widget _buildCreateCard() {
    return InkWell(
      onTap: _showCreatePlaylistDialog,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFD1D1D6),
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 28,
                color: Color(0xFF8E8E93),
              ),
              SizedBox(height: 6),
              Text(
                '新建',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(Playlist playlist) {
    return InkWell(
      onTap: () {
        _navigateToPlaylistDetail(playlist);
      },
      onLongPress: () {
        _showPlaylistOptions(playlist);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${playlist.songCount} 首歌曲',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _showPlaylistOptions(playlist);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_horiz,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateListItem() {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFD1D1D6),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.add,
          color: Color(0xFF8E8E93),
        ),
      ),
      title: const Text(
        '新建歌单',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
      onTap: _showCreatePlaylistDialog,
    );
  }

  Widget _buildPlaylistListItem(Playlist playlist) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.playlist_play,
          color: Color(0xFF007AFF),
        ),
      ),
      title: Text(
        playlist.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
      subtitle: Text(
        '${playlist.songCount} 首歌曲',
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF8E8E93),
        ),
      ),
      onTap: () {
        _navigateToPlaylistDetail(playlist);
      },
      onLongPress: () {
        _showPlaylistOptions(playlist);
      },
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        color: const Color(0xFF8E8E93),
        onPressed: () {
          _showPlaylistOptions(playlist);
        },
      ),
    );
  }

  void _showPlaylistOptions(Playlist playlist) {
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
                playlist.name,
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
                  _showEditPlaylistDialog(playlist);
                },
              ),
              if (!playlist.isDefault)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('删除歌单'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeletePlaylistDialog(playlist);
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPlaylistDetail(Playlist playlist) {
    if (widget.allSongs == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailPage(
          playlist: playlist,
          allSongs: widget.allSongs!,
          onSongTap: widget.onSongTap ?? (song) {},
          isFavorite: widget.isFavorite,
          onToggleFavorite: widget.onToggleFavorite,
          onEditPlaylist: (updatedPlaylist) {
            setState(() {
              final index = _playlists.indexWhere((p) => p.id == updatedPlaylist.id);
              if (index >= 0) {
                _playlists[index] = updatedPlaylist;
              }
            });
            if (widget.onPlaylistsUpdated != null) {
              widget.onPlaylistsUpdated!(_playlists);
            }
            if (widget.onEditPlaylist != null) {
              widget.onEditPlaylist!(updatedPlaylist);
            }
          },
          onDeletePlaylist: (playlistId) {
            setState(() {
              _playlists.removeWhere((p) => p.id == playlistId);
            });
            if (widget.onPlaylistsUpdated != null) {
              widget.onPlaylistsUpdated!(_playlists);
            }
            if (widget.onDeletePlaylist != null) {
              widget.onDeletePlaylist!(playlistId);
            }
          },
        ),
      ),
    );
  }
}