import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/lyric.dart';

class LyricService {
  static LyricService? _instance;
  
  LyricService._();
  
  static LyricService get instance {
    _instance ??= LyricService._();
    return _instance!;
  }
  
  // 支持的歌词文件扩展名
  static const List<String> _supportedExtensions = ['.lrc', '.txt'];
  
  // 根据音频文件路径查找歌词文件
  Future<Lyric?> findLyric(String audioPath) async {
    final audioDir = p.dirname(audioPath);
    final audioBaseName = p.basenameWithoutExtension(audioPath);
    
    // 尝试查找同目录下的歌词文件
    for (final ext in _supportedExtensions) {
      final lyricPath = p.join(audioDir, '$audioBaseName$ext');
      final lyricFile = File(lyricPath);
      
      if (await lyricFile.exists()) {
        try {
          final lyricText = await lyricFile.readAsString();
          return Lyric.fromLrcText(lyricText);
        } catch (e) {
          // 读取失败，继续尝试下一个
          continue;
        }
      }
    }
    
    // 尝试在Lyrics子目录中查找
    final lyricsDir = Directory(p.join(audioDir, 'Lyrics'));
    if (await lyricsDir.exists()) {
      for (final ext in _supportedExtensions) {
        final lyricPath = p.join(lyricsDir.path, '$audioBaseName$ext');
        final lyricFile = File(lyricPath);
        
        if (await lyricFile.exists()) {
          try {
            final lyricText = await lyricFile.readAsString();
            return Lyric.fromLrcText(lyricText);
          } catch (e) {
            continue;
          }
        }
      }
    }
    
    return null;
  }
  
  // 从文本解析歌词
  Lyric? parseLyricText(String text) {
    if (text.trim().isEmpty) return null;
    try {
      return Lyric.fromLrcText(text);
    } catch (e) {
      return null;
    }
  }
}