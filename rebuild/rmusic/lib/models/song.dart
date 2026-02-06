class Song {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
  final String? audioUrl;
  final int duration; // in seconds
  final String album;
  final int lastModified; // 文件最后修改时间
  final bool isFavorite; // 是否收藏

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.audioUrl,
    required this.duration,
    required this.album,
    this.lastModified = 0,
    this.isFavorite = false,
  });

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 创建一个空的 Song 对象
  static Song empty() => Song(
    id: '',
    title: '',
    artist: '',
    album: '',
    duration: 0,
  );

  // 复制并更新部分字段
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? coverUrl,
    String? audioUrl,
    int? duration,
    String? album,
    int? lastModified,
    bool? isFavorite,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverUrl: coverUrl ?? this.coverUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      album: album ?? this.album,
      lastModified: lastModified ?? this.lastModified,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}