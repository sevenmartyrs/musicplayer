/// 播放列表模型
class Playlist {
  final String id;
  final String name;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault; // 是否为默认歌单（不可删除）
  final String? coverUrl; // 封面图 URL
  final String? description; // 简介

  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
    this.coverUrl,
    this.description,
  });

  // 创建播放列表
  factory Playlist.create({
    required String name,
    List<String> songIds = const [],
    bool isDefault = false,
    String? coverUrl,
    String? description,
  }) {
    final now = DateTime.now();
    return Playlist(
      id: _generateId(),
      name: name,
      songIds: songIds,
      createdAt: now,
      updatedAt: now,
      isDefault: isDefault,
      coverUrl: coverUrl,
      description: description,
    );
  }

  // 歌曲数量
  int get songCount => songIds.length;

  // 复制并更新部分字段
  Playlist copyWith({
    String? id,
    String? name,
    List<String>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
    String? coverUrl,
    String? description,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
    );
  }

  // 生成唯一ID
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}