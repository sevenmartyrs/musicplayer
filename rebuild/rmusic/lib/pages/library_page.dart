import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/sort_option.dart';
import '../widgets/search_bar.dart';
import '../widgets/song_list_item.dart';

class LibraryPage extends StatefulWidget {
  final List<Song> songs;
  final Function(Song) onSongTap;
  final Function(List<Song>) onSongsUpdated;
  final List<Playlist>? playlists;
  final Function(String, String)? onAddSongToPlaylist;

  const LibraryPage({
    super.key,
    required this.songs,
    required this.onSongTap,
    required this.onSongsUpdated,
    this.playlists,
    this.onAddSongToPlaylist,
  });

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String _searchQuery = '';
  SortOption _sortOption = SortOption.nameAsc;
  List<Song>? _filteredSongsCache;
  bool _isCacheValid = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(LibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果歌曲列表变化，使缓存无效
    if (oldWidget.songs != widget.songs) {
      _invalidateCache();
    }
  }

  void _invalidateCache() {
    _isCacheValid = false;
  }

  List<Song> get _filteredSongs {
    if (_isCacheValid && _filteredSongsCache != null) {
      return _filteredSongsCache!;
    }

    var songs = List<Song>.from(widget.songs);

    // 搜索过滤
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      songs = songs.where((song) {
        return song.title.toLowerCase().contains(query) ||
               song.artist.toLowerCase().contains(query) ||
               song.album.toLowerCase().contains(query);
      }).toList();
    }

    // 排序
    switch (_sortOption) {
      case SortOption.nameAsc:
        songs.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.nameDesc:
        songs.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.artistAsc:
        songs.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case SortOption.artistDesc:
        songs.sort((a, b) => b.artist.compareTo(a.artist));
        break;
      case SortOption.durationAsc:
        songs.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case SortOption.durationDesc:
        songs.sort((a, b) => b.duration.compareTo(a.duration));
        break;
    }

    _filteredSongsCache = songs;
    _isCacheValid = true;
    return songs;
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
              child: widget.songs.isEmpty
                  ? _buildEmptyState()
                  : _buildSongList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '乐库',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.songs.length} SONGS · LOCAL',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, size: 24),
                color: _searchQuery.isEmpty 
                    ? const Color(0xFF8E8E93) 
                    : const Color(0xFF007AFF),
                onPressed: () => _showSearchBar(),
              ),
              IconButton(
                icon: const Icon(Icons.sort, size: 24),
                color: const Color(0xFF8E8E93),
                onPressed: _showSortMenu,
              ),
            ],
          ),
        ),
        if (_searchQuery.isNotEmpty)
          _buildSearchBar(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return AppSearchBar(
      query: _searchQuery,
      hintText: '搜索歌名、歌手、专辑',
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _invalidateCache();
        });
      },
      onClear: () {
        setState(() {
          _searchQuery = '';
          _invalidateCache();
        });
      },
    );
  }

  void _showSearchBar() {
    setState(() {
      _searchQuery = '';
      _invalidateCache();
    });
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '排序方式',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: SortOption.values.map((option) => ListTile(
                        title: Text(_getSortOptionLabel(option)),
                        trailing: _sortOption == option
                            ? const Icon(Icons.check, color: Color(0xFF007AFF))
                            : null,
                        onTap: () {
                          setState(() {
                            _sortOption = option;
                            _invalidateCache();
                          });
                          Navigator.pop(context);
                        },
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSortOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return '歌名 (A-Z)';
      case SortOption.nameDesc:
        return '歌名 (Z-A)';
      case SortOption.artistAsc:
        return '歌手 (A-Z)';
      case SortOption.artistDesc:
        return '歌手 (Z-A)';
      case SortOption.durationAsc:
        return '时长 (最短)';
      case SortOption.durationDesc:
        return '时长 (最长)';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note,
            size: 80,
            color: const Color(0xFFE0E0E0),
          ),
          const SizedBox(height: 16),
          const Text(
            '没有找到音乐文件',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    final songs = _filteredSongs;
    
    if (songs.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: const Color(0xFFE0E0E0),
            ),
            const SizedBox(height: 16),
            const Text(
              '未找到匹配的歌曲',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: songs.length,
      itemExtent: 74, // 优化滚动性能：固定每个item的高度
      itemBuilder: (context, index) {
        return _buildSongItem(songs[index]);
      },
    );
  }

  Widget _buildSongItem(Song song) {
    return SongListItem(
      song: song,
      onTap: () => widget.onSongTap(song),
      showIndex: false,
      showFavorite: false,
      showMoreOptions: widget.playlists != null && widget.playlists!.isNotEmpty,
      onMoreOptions: () => _showSongOptions(song),
    );
  }

  void _showSongOptions(Song song) {
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
              const Text(
                '歌曲选项',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.playlist_add,
                  color: Color(0xFF007AFF),
                ),
                title: const Text(
                  '加歌单',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showPlaylistSelection(song);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaylistSelection(Song song) {
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
              const Text(
                '添加到歌单',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.playlists!.length,
                  itemBuilder: (context, index) {
                    final playlist = widget.playlists![index];
                    final isInPlaylist = playlist.songIds.contains(song.id);
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.playlist_play,
                          color: Color(0xFF007AFF),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        playlist.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: isInPlaylist
                          ? const Icon(
                              Icons.check,
                              color: Color(0xFF007AFF),
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        if (widget.onAddSongToPlaylist != null) {
                          widget.onAddSongToPlaylist!(song.id, playlist.id);
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}