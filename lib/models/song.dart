class Song {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
  final String? audioUrl;
  final int duration; // in seconds
  final String album;
  final int lastModified; // 文件最后修改时间

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.audioUrl,
    required this.duration,
    required this.album,
    this.lastModified = 0,
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

  // 从 Map 创建 Song（用于从数据库读取）
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      coverUrl: map['coverUrl'] as String?,
      audioUrl: map['audioUrl'] as String?,
      duration: map['duration'] as int,
      album: map['album'] as String,
      lastModified: map['lastModified'] as int,
    );
  }

  // 转换为 Map（用于保存到数据库）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'coverUrl': coverUrl,
      'audioUrl': audioUrl,
      'duration': duration,
      'album': album,
      'lastModified': lastModified,
    };
  }
}