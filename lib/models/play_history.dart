class PlayHistory {
  final String id;
  final String songId;
  final DateTime playedAt;
  final int playCount;

  PlayHistory({
    required this.id,
    required this.songId,
    required this.playedAt,
    required this.playCount,
  });

  // 创建新的播放历史记录
  factory PlayHistory.create({
    required String songId,
    int playCount = 1,
  }) {
    final now = DateTime.now();
    return PlayHistory(
      id: _generateId(songId),
      songId: songId,
      playedAt: now,
      playCount: playCount,
    );
  }

  // 从Map创建（用于从数据库读取）
  factory PlayHistory.fromMap(Map<String, dynamic> map) {
    return PlayHistory(
      id: map['id'] as String,
      songId: map['songId'] as String,
      playedAt: DateTime.parse(map['playedAt'] as String),
      playCount: map['playCount'] as int,
    );
  }

  // 转换为Map（用于保存到数据库）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'songId': songId,
      'playedAt': playedAt.toIso8601String(),
      'playCount': playCount,
    };
  }

  // 更新播放记录
  PlayHistory updatePlayCount() {
    return PlayHistory(
      id: id,
      songId: songId,
      playedAt: DateTime.now(),
      playCount: playCount + 1,
    );
  }

  // 生成唯一ID
  static String _generateId(String songId) {
    return '$songId-${DateTime.now().millisecondsSinceEpoch}';
  }
}