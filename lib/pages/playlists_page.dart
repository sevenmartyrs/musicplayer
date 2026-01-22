import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/song_database.dart';

class PlaylistsPage extends StatefulWidget {
  final Function(String)? onPlaylistTap;
  final List<Song>? allSongs;

  const PlaylistsPage({
    super.key,
    this.onPlaylistTap,
    this.allSongs,
  });

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final SongDatabase _database = SongDatabase.instance;
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    setState(() => _isLoading = true);
    try {
      final playlists = await _database.getAllPlaylists();
      if (mounted) {
        setState(() {
          _playlists = playlists;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading playlists: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showCreatePlaylistDialog() async {
    final controller = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建歌单'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入歌单名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              
              final playlist = Playlist.create(name: name);
              await _database.savePlaylist(playlist);
              
              Navigator.pop(context);
              _loadPlaylists();
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPlaylistDialog(Playlist playlist) async {
    final controller = TextEditingController(text: playlist.name);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑歌单'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入歌单名称',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              
              final updated = playlist.copyWith(name: name);
              await _database.savePlaylist(updated);
              
              Navigator.pop(context);
              _loadPlaylists();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeletePlaylistDialog(Playlist playlist) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除歌单'),
        content: Text('确定要删除"${playlist.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await _database.deletePlaylist(playlist.id);
              Navigator.pop(context);
              _loadPlaylists();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showPlaylistSongsDialog(Playlist playlist) async {
    final allSongs = widget.allSongs ?? [];
    final songMap = {for (var song in allSongs) song.id: song};
    final songs = playlist.songIds
        .map((id) => songMap[id])
        .where((song) => song != null && song.id.isNotEmpty)
        .cast<Song>()
        .toList();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlaylistHeader(playlist, songs),
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return _buildPlaylistSongItem(songs[index], index, playlist);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistHeader(Playlist playlist, List<Song> songs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5)),
        ),
      ),
      child: Row(
        children: [
          Text(
            playlist.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${songs.length} 首歌',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistSongItem(Song song, int index, Playlist playlist) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          color: const Color(0xFF007AFF),
          child: const Icon(
            Icons.music_note,
            color: Colors.white,
          ),
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        color: const Color(0xFF8E8E93),
        onPressed: () async {
          final updated = playlist.copyWith(
            songIds: List.from(playlist.songIds)..remove(song.id),
          );
          await _database.savePlaylist(updated);
          _loadPlaylists();
          Navigator.pop(context);
          _showPlaylistSongsDialog(updated);
        },
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _playlists.isEmpty
                      ? _buildEmptyState()
                      : _buildPlaylistsGrid(),
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
            icon: const Icon(Icons.refresh, size: 24),
            color: const Color(0xFF8E8E93),
            onPressed: _loadPlaylists,
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          _buildCreateCard(),
          ..._playlists.map((playlist) => _buildPlaylistCard(playlist)),
        ],
      ),
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 32,
                color: const Color(0xFF8E8E93),
              ),
              SizedBox(height: 8),
              Text(
                '新建歌单',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF8E8E93),
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
        if (widget.onPlaylistTap != null) {
          widget.onPlaylistTap!(playlist.id);
        } else {
          _showPlaylistSongsDialog(playlist);
        }
      },
      onLongPress: () => _showEditPlaylistDialog(playlist),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                playlist.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${playlist.songCount} 首歌曲',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: const Color(0xFF8E8E93),
                    onPressed: () => _showEditPlaylistDialog(playlist),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: const Color(0xFF8E8E93),
                    onPressed: () => _showDeletePlaylistDialog(playlist),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}