import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CoverCache {
  static CoverCache? _instance;
  String? _cacheDir;

  CoverCache._();

  static CoverCache get instance {
    _instance ??= CoverCache._();
    return _instance!;
  }

  // 初始化缓存目录
  Future<void> init() async {
    if (_cacheDir != null) return;

    final directory = await getApplicationDocumentsDirectory();
    _cacheDir = p.join(directory.path, 'covers');
    
    final cacheDir = Directory(_cacheDir!);
    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }
  }

  // 生成缓存文件名（使用MD5哈希）
  String _generateCacheKey(String sourcePath) {
    final bytes = utf8.encode(sourcePath);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  // 获取缓存文件路径
  String _getCachePath(String sourcePath) {
    if (_cacheDir == null) {
      throw Exception('CoverCache not initialized. Call init() first.');
    }
    final key = _generateCacheKey(sourcePath);
    return p.join(_cacheDir!, '$key.jpg');
  }

  // 检查缓存是否存在
  bool hasCache(String sourcePath) {
    final cachePath = _getCachePath(sourcePath);
    return File(cachePath).existsSync();
  }

  // 获取缓存的封面路径
  String? getCachedCover(String sourcePath) {
    if (hasCache(sourcePath)) {
      return _getCachePath(sourcePath);
    }
    return null;
  }

  // 保存封面到缓存
  Future<String?> saveCover(String sourcePath, List<int> imageBytes) async {
    await init();
    
    try {
      final cachePath = _getCachePath(sourcePath);
      final cacheFile = File(cachePath);
      await cacheFile.writeAsBytes(imageBytes);
      return cachePath;
    } catch (e) {
      return null;
    }
  }

  // 删除指定封面缓存
  Future<void> deleteCover(String sourcePath) async {
    await init();
    
    try {
      final cachePath = _getCachePath(sourcePath);
      final cacheFile = File(cachePath);
      if (cacheFile.existsSync()) {
        await cacheFile.delete();
      }
    } catch (e) {
      // 忽略删除失败
    }
  }

  // 清理过期缓存（可选）
  Future<void> clearCache({Duration? olderThan}) async {
    await init();
    
    if (_cacheDir == null) return;

    final cacheDir = Directory(_cacheDir!);
    if (!cacheDir.existsSync()) return;

    final now = DateTime.now();
    final files = cacheDir.listSync();

    for (final file in files) {
      if (file is File) {
        final stat = file.statSync();
        final age = now.difference(stat.modified);
        
        if (olderThan == null || age > olderThan) {
          try {
            file.deleteSync();
          } catch (e) {
            // 忽略删除失败
          }
        }
      }
    }
  }

  // 获取缓存大小
  Future<int> getCacheSize() async {
    await init();
    
    if (_cacheDir == null) return 0;

    final cacheDir = Directory(_cacheDir!);
    if (!cacheDir.existsSync()) return 0;

    int totalSize = 0;
    final files = cacheDir.listSync();

    for (final file in files) {
      if (file is File) {
        try {
          totalSize += file.lengthSync();
        } catch (e) {
          // 忽略读取失败
        }
      }
    }

    return totalSize;
  }

  // 清空所有缓存
  Future<void> clearAllCache() async {
    await init();
    
    if (_cacheDir == null) return;

    final cacheDir = Directory(_cacheDir!);
    if (!cacheDir.existsSync()) return;

    try {
      cacheDir.deleteSync(recursive: true);
      cacheDir.createSync(recursive: true);
    } catch (e) {
      // 忽略删除失败
    }
  }
}