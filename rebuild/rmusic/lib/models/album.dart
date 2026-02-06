/// 专辑模型
class Album {
  final String id;
  final String name;
  final String artist;
  final String? coverUrl;
  final int songCount;
  final int? year;

  Album({
    required this.id,
    required this.name,
    required this.artist,
    this.coverUrl,
    this.songCount = 0,
    this.year,
  });

  Album copyWith({
    String? id,
    String? name,
    String? artist,
    String? coverUrl,
    int? songCount,
    int? year,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      coverUrl: coverUrl ?? this.coverUrl,
      songCount: songCount ?? this.songCount,
      year: year ?? this.year,
    );
  }
}