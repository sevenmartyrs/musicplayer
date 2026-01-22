import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:metadata_god/metadata_god.dart';
import 'package:file_picker/file_picker.dart';
import '../models/song.dart';
import 'song_database.dart';
import 'cover_cache.dart';
import 'music_scanner_isolate.dart';

class MusicScanner {
  final SongDatabase _database;
  final CoverCache _coverCache = CoverCache.instance;
  static bool _isMetadataInitialized = false;
  
  MusicScanner(this._database) {
    _coverCache.init();
  }

  // 确保 MetadataGod 已初始化
  static Future<void> _ensureMetadataInitialized() async {
    if (!_isMetadataInitialized) {
      await MetadataGod.initialize();
      _isMetadataInitialized = true;
      debugPrint('MetadataGod initialized in MusicScanner');
    }
  }

  // 支持的音频格式
  static const List<String> _supportedFormats = [
    '.mp3',
    '.m4a',
    '.wav',
    '.ogg',
    '.flac',
    '.aac',
  ];

  Future<bool> requestPermissions() async {
    // Android 13+ 使用 READ_MEDIA_AUDIO
    // Android 12 及以下使用 READ_EXTERNAL_STORAGE
    
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        // Android 13+
        final status = await Permission.audio.request();
        return status.isGranted;
      } else {
        // Android 12 及以下
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    
    if (Platform.isIOS) {
      // iOS：应用沙盒内不需要权限，直接返回 true
      return true;
    }
    
    return false;
  }

  Future<int> _getAndroidVersion() async {
    // 简化版本检测，实际应该使用 device_info_plus
    return 33; // 假设是 Android 13+
  }

  // 增量扫描：使用 Isolate 扫描文件路径，在主线程解析元数据
  Future<List<Song>> scanMusicFiles({bool forceFullScan = false}) async {
    try {
      // 获取现有歌曲
      final existingSongs = await _database.getAllSongs();
      final existingPaths = existingSongs.map((s) => s.id).toSet();
      final existingSongsMap = {for (var s in existingSongs) s.id: s};
      
      // 获取音乐目录
      final directories = await _getMusicDirectories();
      final dirPaths = directories.map((d) => d.path).toList();
      
      // 使用 compute 在 Isolate 中执行扫描（只扫描文件路径）
      final scanParams = ScanParams(
        directories: dirPaths,
        existingPaths: existingPaths,
        forceFullScan: forceFullScan,
      );
      
      final scanResults = await compute(scanMusicFilesInIsolate, scanParams);
      
      // 在主线程中解析元数据（分批处理，避免阻塞）
      final songs = <Song>[];
      final batchSize = 10; // 每批处理10个文件
      
      for (int i = 0; i < scanResults.length; i += batchSize) {
        final batch = scanResults.skip(i).take(batchSize).toList();
        
        for (final result in batch) {
          Song? song;
          
          // 如果文件已存在且未修改，使用缓存
          if (!result.isNew && !result.isModified && existingSongsMap.containsKey(result.filePath)) {
            song = existingSongsMap[result.filePath];
          } else {
            // 解析新文件或修改的文件
            song = await _parseFileMetadata(File(result.filePath));
          }
          
          if (song != null) {
            songs.add(song);
          }
        }
        
        // 每批处理后让出控制权，避免阻塞
        await Future.delayed(const Duration(milliseconds: 1));
      }
      
      // 按标题排序
      songs.sort((a, b) => a.title.compareTo(b.title));
      
      return songs;
    } catch (e) {
      debugPrint('Scan error: $e');
      return [];
    }
  }

  // 在主线程中解析文件元数据
  Future<Song?> _parseFileMetadata(File file) async {
    try {
      // 确保 MetadataGod 已初始化（延迟初始化）
      await _ensureMetadataInitialized();
      
      final fileName = p.basenameWithoutExtension(file.path);
      
      // 默认值
      String title = fileName;
      String artist = 'Unknown Artist';
      String album = 'Unknown Album';
      int duration = 180;
      String? coverUrl;
      
      // 从文件名解析歌手和歌名
      if (fileName.contains(' - ')) {
        final parts = fileName.split(' - ');
        if (parts.length >= 2) {
          artist = parts[0].trim();
          title = parts.sublist(1).join(' - ').trim();
        }
      } else if (fileName.contains('_')) {
        final parts = fileName.split('_');
        if (parts.length >= 2) {
          artist = parts[0].trim();
          title = parts.sublist(1).join('_').trim();
        }
      }

      // 解析元数据
      try {
        final metadata = await MetadataGod.readMetadata(file: file.path);
        
        if (metadata.title != null && metadata.title!.isNotEmpty) {
          title = metadata.title!;
        }
        
        if (metadata.artist != null && metadata.artist!.isNotEmpty) {
          artist = metadata.artist!;
        }
        
        if (metadata.album != null && metadata.album!.isNotEmpty) {
          album = metadata.album!;
        }
        
        if (metadata.durationMs != null && metadata.durationMs! > 0) {
          duration = (metadata.durationMs! / 1000).round();
        }
        
        // 获取专辑封面
        if (metadata.picture != null) {
          final cachedCover = _coverCache.getCachedCover(file.path);
          if (cachedCover != null) {
            coverUrl = cachedCover;
          } else {
            coverUrl = await _saveCoverImage(metadata.picture!, file.path);
          }
        }
      } catch (e) {
        // 元数据解析失败，使用文件名解析的结果
      }

      final lastModified = file.lastModifiedSync().millisecondsSinceEpoch;

      return Song(
        id: file.path,
        title: title,
        artist: artist,
        album: album,
        duration: duration,
        audioUrl: file.path,
        coverUrl: coverUrl,
        lastModified: lastModified,
      );
    } catch (e) {
      debugPrint('Failed to parse file ${file.path}: $e');
      return null;
    }
  }

  // 保存专辑封面图片到缓存
  Future<String?> _saveCoverImage(Picture picture, String audioPath) async {
    try {
      // 先检查缓存
      if (_coverCache.hasCache(audioPath)) {
        return _coverCache.getCachedCover(audioPath);
      }
      
      // 保存到缓存
      return await _coverCache.saveCover(audioPath, picture.data);
    } catch (e) {
      debugPrint('Failed to save cover image: $e');
      return null;
    }
  }

  Future<List<Directory>> _getMusicDirectories() async {
    final directories = <Directory>[];
    
    if (Platform.isIOS) {
      // iOS：只扫描应用 Documents 目录
      final appDocDir = await getApplicationDocumentsDirectory();
      directories.add(appDocDir);
      return directories;
    }
    
    // Android：保持原有逻辑
    try {
      // 获取外部存储目录
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        // 添加常见的音乐目录
        directories.add(Directory(p.join(externalDir.path, 'Music')));
        directories.add(Directory(p.join(externalDir.path, 'Download')));
        
        // 添加根目录下的音乐文件夹
        final rootDir = Directory(externalDir.parent.parent.parent.path);
        if (await rootDir.exists()) {
          directories.add(Directory(p.join(rootDir.path, 'Music')));
        }
      }
      
      // 添加内部存储的音乐目录
      if (Platform.isAndroid) {
        directories.add(Directory('/storage/emulated/0/Music'));
        directories.add(Directory('/storage/emulated/0/Download'));
      }
      
    } catch (e) {
      // Error handling
    }
    
    return directories;
  }

  // 导入音乐文件（主要用于 iOS）
  Future<List<Song>> importMusicFiles() async {
    try {
      // 使用 file_picker 选择音乐文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
        allowedExtensions: _supportedFormats.map((e) => e.substring(1)).toList(),
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      // 获取应用 Documents 目录
      final appDocDir = await getApplicationDocumentsDirectory();
      final musicDir = Directory(p.join(appDocDir.path, 'Music'));
      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      // 复制文件到应用目录并解析元数据
      final songs = <Song>[];
      
      for (final file in result.files) {
        if (file.path == null) continue;
        
        final sourceFile = File(file.path!);
        final fileName = file.name;
        final destPath = p.join(musicDir.path, fileName);
        
        // 检查文件是否已存在
        if (await File(destPath).exists()) {
          debugPrint('File already exists: $fileName');
          continue;
        }
        
        // 复制文件到应用目录
        await sourceFile.copy(destPath);
        
        // 解析元数据
        final song = await _parseFileMetadata(File(destPath));
        if (song != null) {
          songs.add(song);
        }
      }
      
      // 保存到数据库
      for (final song in songs) {
        await _database.saveSong(song);
      }
      
      return songs;
    } catch (e) {
      debugPrint('Import music error: $e');
      return [];
    }
  }

  // 删除音乐文件
  Future<bool> deleteMusicFile(String songId) async {
    try {
      // 删除文件
      final file = File(songId);
      if (await file.exists()) {
        await file.delete();
      }
      
      // 删除封面缓存
      await _coverCache.deleteCover(songId);
      
      // 从数据库删除
      await _database.deleteSong(songId);
      
      return true;
    } catch (e) {
      debugPrint('Delete music file error: $e');
      return false;
    }
  }
}