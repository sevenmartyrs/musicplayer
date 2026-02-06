class LyricLine {
  final int time; // 毫秒
  final String text;

  LyricLine({
    required this.time,
    required this.text,
  });
}

class Lyric {
  final List<LyricLine> lines;

  Lyric({required this.lines});

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