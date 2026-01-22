import 'package:flutter/material.dart';
import 'dart:io';
import '../models/song.dart';

class PlaylistPage extends StatefulWidget {
  final List<Song> songs;
  final Song? currentSong;
  final Function(Song) onSongTap;

  const PlaylistPage({
    super.key,
    required this.songs,
    this.currentSong,
    required this.onSongTap,
  });

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  String _searchQuery = '';
  SortOption _sortOption = SortOption.nameAsc;

  List<Song> get _filteredSongs {
    var songs = widget.songs;

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
      case SortOption.timeAsc:
        songs.sort((a, b) => a.lastModified.compareTo(b.lastModified));
        break;
      case SortOption.timeDesc:
        songs.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        break;
      case SortOption.durationAsc:
        songs.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case SortOption.durationDesc:
        songs.sort((a, b) => b.duration.compareTo(a.duration));
        break;
    }

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
            _buildQueueHeader(),
            Expanded(
              child: Builder(
                builder: (context) {
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
                    itemBuilder: (context, index) {
                      return _buildSongItem(songs[index], index);
                    },
                  );
                },
              ),
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
                      '播放列表',
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF8E8E93), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '搜索歌名、歌手、专辑',
                hintStyle: TextStyle(color: Color(0xFF8E8E93)),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              color: const Color(0xFF8E8E93),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  void _showSearchBar() {
    setState(() {
      _searchQuery = '';
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
      case SortOption.timeAsc:
        return '添加时间 (最早)';
      case SortOption.timeDesc:
        return '添加时间 (最新)';
      case SortOption.durationAsc:
        return '时长 (最短)';
      case SortOption.durationDesc:
        return '时长 (最长)';
    }
  }

  Widget _buildQueueHeader() {
    final songs = _filteredSongs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        '正在播放队列 (${songs.length})',
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF999999),
        ),
      ),
    );
  }

  Widget _buildSongItem(Song song, int index) {
    final isCurrent = widget.currentSong?.id == song.id;
    final isPlaying = isCurrent && widget.currentSong != null;
    
    return InkWell(
      onTap: () => widget.onSongTap(song),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFFE6F2FF) : Colors.transparent,
        ),
        child: Row(
          children: [
            // Index or Playing Icon
            SizedBox(
              width: 32,
              child: isPlaying
                  ? const Icon(
                      Icons.equalizer,
                      color: Color(0xFF007AFF),
                      size: 24,
                    )
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        color: isCurrent ? const Color(0xFF007AFF) : const Color(0xFF333333),
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Album Cover
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFFE0E0E0),
              ),
              child: _buildCover(song),
            ),
            const SizedBox(width: 12),
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? const Color(0xFF007AFF) : const Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF888888),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              song.formattedDuration,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(Song song) {
    // 检查是否有专辑封面
    if (song.coverUrl != null && song.coverUrl!.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(
            File(song.coverUrl!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // 加载失败显示默认图标
              return const Icon(
                Icons.music_note,
                color: Color(0xFF888888),
                size: 24,
              );
            },
          ),
        );
      } catch (e) {
        // 文件不存在或加载失败，显示默认图标
        return const Icon(
          Icons.music_note,
          color: Color(0xFF888888),
          size: 24,
        );
      }
    }
    
    // 没有封面，显示默认图标
    return const Icon(
      Icons.music_note,
      color: Color(0xFF888888),
      size: 24,
    );
  }
}

enum SortOption {
  nameAsc,
  nameDesc,
  artistAsc,
  artistDesc,
  timeAsc,
  timeDesc,
  durationAsc,
  durationDesc,
}