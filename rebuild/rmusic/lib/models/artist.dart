/// 艺术家模型
class Artist {
  final String id;
  final String name;
  final String? coverUrl;
  final int songCount;

  Artist({
    required this.id,
    required this.name,
    this.coverUrl,
    this.songCount = 0,
  });

  Artist copyWith({
    String? id,
    String? name,
    String? coverUrl,
    int? songCount,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      coverUrl: coverUrl ?? this.coverUrl,
      songCount: songCount ?? this.songCount,
    );
  }
}