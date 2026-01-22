import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/song.dart';

/// 隔离函数：在后台线程解析音频元数据
/// 这个函数必须在顶层定义，不能是类方法
/// 注意：compute函数必须是同步的，不能使用async/await
Song? parseAudioMetadata(File file) {
  try {
    final fileName = file.path.split('/').last;
    
    // 默认值
    String title = fileName;
    String artist = 'Unknown Artist';
    String album = 'Unknown Album';
    int duration = 180; // 默认3分钟
    
    // 尝试从文件名解析歌手和歌名
    if (fileName.contains(' - ')) {
      final parts = fileName.split(' - ');
      if (parts.length >= 2) {
        artist = parts[0].trim();
        title = parts.sublist(1).join(' - ').trim();
      }
    }
    
    // 获取文件最后修改时间
    final lastModified = file.lastModifiedSync().millisecondsSinceEpoch;
    
    return Song(
      id: file.path,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      audioUrl: file.path,
      lastModified: lastModified,
    );
  } catch (e) {
    return null;
  }
}