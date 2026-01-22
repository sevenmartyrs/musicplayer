import 'dart:io';
import 'package:path/path.dart' as p;

// 扫描参数
class ScanParams {
  final List<String> directories;
  final Set<String> existingPaths;
  final bool forceFullScan;

  ScanParams({
    required this.directories,
    required this.existingPaths,
    required this.forceFullScan,
  });
}

// 扫描结果
class ScanResult {
  final String filePath;
  final int lastModified;
  final bool isNew;
  final bool isModified;

  ScanResult({
    required this.filePath,
    required this.lastModified,
    required this.isNew,
    required this.isModified,
  });
}

// Isolate 中运行的扫描函数 - 只扫描文件路径，不解析元数据
Future<List<ScanResult>> scanMusicFilesInIsolate(ScanParams params) async {
  final results = <ScanResult>[];
  final supportedFormats = ['.mp3', '.m4a', '.wav', '.ogg', '.flac', '.aac'];

  try {
    for (final dirPath in params.directories) {
      final directory = Directory(dirPath);
      if (!await directory.exists()) continue;

      final entities = directory.listSync(recursive: true, followLinks: false);

      for (final entity in entities) {
        if (entity is File) {
          final extension = p.extension(entity.path).toLowerCase();
          if (!supportedFormats.contains(extension)) continue;

          final lastModified = entity.lastModifiedSync().millisecondsSinceEpoch;
          final isNew = !params.existingPaths.contains(entity.path);
          final isModified = !isNew && params.forceFullScan;

          results.add(ScanResult(
            filePath: entity.path,
            lastModified: lastModified,
            isNew: isNew,
            isModified: isModified,
          ));
        }
      }
    }
  } catch (e) {
    // 静默处理错误
  }

  return results;
}