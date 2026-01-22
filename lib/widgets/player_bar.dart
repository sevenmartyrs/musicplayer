import 'package:flutter/material.dart';
import 'dart:io';
import '../models/player_state.dart';

class PlayerBar extends StatelessWidget {
  final PlayerState playerState;
  final VoidCallback onPlayPause;
  final VoidCallback onTap;

  const PlayerBar({
    super.key,
    required this.playerState,
    required this.onPlayPause,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (playerState.currentSong == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Album Cover
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: const Color(0xFFE0E0E0),
                ),
                child: _buildCover(playerState.currentSong!),
              ),
              const SizedBox(width: 12),
              // Song Info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        playerState.currentSong!.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        playerState.currentSong!.artist,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF888888),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Play/Pause Button
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: const Color(0xFFFF8C00),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover(dynamic song) {
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