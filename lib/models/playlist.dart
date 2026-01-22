/// 播放列表模型
class Playlist {
  final String id;
  final String name;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
  });

  // 创建播放列表
  factory Playlist.create({
    required String name,
    List<String> songIds = const [],
  }) {
    final now = DateTime.now();
    return Playlist(
      id: _generateId(),
      name: name,
      songIds: songIds,
      createdAt: now,
      updatedAt: now,
    );
  }

  // 从 Map 创建（用于从数据库读取）
  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] as String,
      name: map['name'] as String,
      songIds: (map['songIds'] as String).split(','),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // 转换为 Map（用于保存到数据库）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'songIds': songIds.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // 更新播放列表
  Playlist copyWith({
    String? name,
    List<String>? songIds,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // 歌曲数量
  int get songCount => songIds.length;

  // 生成唯一ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // 创建一个空的播放列表
  static Playlist empty() => Playlist(
    id: '',
    name: '',
    songIds: const [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}