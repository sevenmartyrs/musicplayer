class LyricLine {
  final int time; // 毫秒
  final String text;

  LyricLine({
    required this.time,
    required this.text,
  });

  factory LyricLine.fromLrcLine(String line) {
    // LRC格式: [mm:ss.xx]歌词内容
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');
    final match = regex.firstMatch(line);
    
    if (match == null) {
      return LyricLine(time: 0, text: line);
    }
    
    final minutes = int.parse(match.group(1)!);
    final seconds = int.parse(match.group(2)!);
    final milliseconds = int.parse(match.group(3)!);
    final text = match.group(4)!.trim();
    
    final totalTime = minutes * 60000 + seconds * 1000 + milliseconds;
    
    return LyricLine(time: totalTime, text: text);
  }
}

class Lyric {
  final List<LyricLine> lines;
  
  Lyric({required this.lines});
  
  factory Lyric.fromLrcText(String lrcText) {
    final lines = <LyricLine>[];
    final lrcLines = lrcText.split('\n');
    
    for (final line in lrcLines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      // 处理多时间标签的情况，如 [00:01.00][00:02.00]歌词
      final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]');
      final matches = regex.allMatches(trimmedLine);
      
      if (matches.isEmpty) continue;
      
      // 提取歌词文本
      final textMatch = RegExp(r'\](.*)').firstMatch(trimmedLine);
      final text = textMatch != null ? textMatch.group(1)!.trim() : '';
      
      if (text.isEmpty) continue;
      
      // 为每个时间标签创建一行
      for (final match in matches) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!);
        final totalTime = minutes * 60000 + seconds * 1000 + milliseconds;
        
        lines.add(LyricLine(time: totalTime, text: text));
      }
    }
    
    // 按时间排序
    lines.sort((a, b) => a.time.compareTo(b.time));
    
    return Lyric(lines: lines);
  }
  
  // 获取当前时间对应的歌词行索引
  int getCurrentLineIndex(int currentTimeMs) {
    if (lines.isEmpty) return -1;
    
    for (int i = lines.length - 1; i >= 0; i--) {
      if (lines[i].time <= currentTimeMs) {
        return i;
      }
    }
    
    return -1;
  }
  
  // 获取当前歌词行
  LyricLine? getCurrentLine(int currentTimeMs) {
    final index = getCurrentLineIndex(currentTimeMs);
    if (index >= 0 && index < lines.length) {
      return lines[index];
    }
    return null;
  }
  
  // 获取显示的歌词行（当前行及其前后几行）
  List<LyricLine> getDisplayLines(int currentTimeMs, {int beforeLines = 2, int afterLines = 2}) {
    final currentIndex = getCurrentLineIndex(currentTimeMs);
    if (currentIndex < 0) return [];
    
    final startIndex = (currentIndex - beforeLines).clamp(0, lines.length);
    final endIndex = (currentIndex + afterLines + 1).clamp(0, lines.length);
    
    return lines.sublist(startIndex, endIndex);
  }
  
  bool get isEmpty => lines.isEmpty;
  int get length => lines.length;
}