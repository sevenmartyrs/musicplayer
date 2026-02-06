import 'package:flutter/material.dart';
import '../models/song.dart';

class HistoryPage extends StatefulWidget {
  final Function(Song)? onSongTap;
  final List<Song>? allSongs;

  const HistoryPage({
    super.key,
    this.onSongTap,
    this.allSongs,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Mock 播放历史
  final List<Map<String, dynamic>> _history = [
    {'songId': '1', 'playedAt': DateTime.now().subtract(const Duration(minutes: 5)), 'playCount': 3},
    {'songId': '2', 'playedAt': DateTime.now().subtract(const Duration(hours: 1)), 'playCount': 5},
    {'songId': '3', 'playedAt': DateTime.now().subtract(const Duration(days: 1)), 'playCount': 2},
  ];

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '播放历史',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    final allSongs = widget.allSongs ?? [];
    final songMap = {for (var song in allSongs) song.id: song};

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final history = _history[index];
        final song = songMap[history['songId'] as String];
        
        if (song == null) return const SizedBox.shrink();

        return _buildHistoryItem(song, history);
      },
    );
  }

  Widget _buildHistoryItem(Song song, Map<String, dynamic> history) {
    return InkWell(
      onTap: () {
        if (widget.onSongTap != null) {
          widget.onSongTap!(song);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Album Cover
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFFE0E0E0),
              ),
              child: const Icon(
                Icons.music_note,
                color: Color(0xFF888888),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        song.artist,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF888888),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '·',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDateTime(history['playedAt'] as DateTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Play Count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${history['playCount']}次',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}