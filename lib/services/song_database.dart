import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/play_history.dart';

class SongDatabase {
  static const String _databaseName = 'songs.db';
  static const int _databaseVersion = 3; // 升级版本号
  static const String _songTableName = 'songs';
  static const String _playlistTableName = 'playlists';
  static const String _historyTableName = 'play_history';

  static SongDatabase? _instance;
  static Database? _database;

  // 私有构造函数
  SongDatabase._();

  // 获取单例实例
  static SongDatabase get instance {
    _instance ??= SongDatabase._();
    return _instance!;
  }

  // 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // 创建表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_songTableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        coverUrl TEXT,
        audioUrl TEXT,
        duration INTEGER NOT NULL,
        album TEXT NOT NULL,
        lastModified INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_playlistTableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        songIds TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_historyTableName (
        id TEXT PRIMARY KEY,
        songId TEXT NOT NULL,
        playedAt TEXT NOT NULL,
        playCount INTEGER NOT NULL,
        FOREIGN KEY (songId) REFERENCES $_songTableName (id) ON DELETE CASCADE
      )
    ''');
  }

  // 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 创建播放列表表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_playlistTableName (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          songIds TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // 创建播放历史记录表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_historyTableName (
          id TEXT PRIMARY KEY,
          songId TEXT NOT NULL,
          playedAt TEXT NOT NULL,
          playCount INTEGER NOT NULL,
          FOREIGN KEY (songId) REFERENCES $_songTableName (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // 保存歌曲列表（全量更新）
  Future<void> saveSongs(List<Song> songs) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(_songTableName);
      for (final song in songs) {
        await txn.insert(_songTableName, song.toMap());
      }
    });
  }

  // 添加或更新单个歌曲
  Future<void> saveSong(Song song) async {
    final db = await database;
    await db.insert(
      _songTableName,
      song.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取所有歌曲
  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_songTableName);
    return maps.map((map) => Song.fromMap(map)).toList();
  }

  // 根据ID获取歌曲
  Future<Song?> getSongById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _songTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Song.fromMap(maps.first);
  }

  // 删除歌曲
  Future<void> deleteSong(String id) async {
    final db = await database;
    await db.delete(
      _songTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 清空所有歌曲
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(_songTableName);
  }

  // 检查歌曲是否需要更新（基于文件修改时间）
  Future<bool> needsUpdate(Song song) async {
    final existingSong = await getSongById(song.id);
    if (existingSong == null) return true;
    
    // 检查文件是否存在
    final file = File(song.audioUrl ?? song.id);
    if (!file.existsSync()) return true;
    
    // 检查修改时间
    final lastModified = file.lastModifiedSync().millisecondsSinceEpoch;
    if (lastModified != song.lastModified) return true;
    
    return false;
  }

  // 检查文件是否存在
  bool fileExists(String filePath) {
    return File(filePath).existsSync();
  }

  // 移除不存在的歌曲
  Future<List<String>> removeMissingFiles() async {
    final db = await database;
    final songs = await getAllSongs();
    final songsToRemove = <String>[];
    
    for (final song in songs) {
      final filePath = song.audioUrl ?? song.id;
      if (!File(filePath).existsSync()) {
        songsToRemove.add(song.id);
      }
    }
    
    if (songsToRemove.isNotEmpty) {
      await db.transaction((txn) async {
        for (final id in songsToRemove) {
          await txn.delete(
            _songTableName,
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      });
    }
    
    return songsToRemove;
  }

  // 批量检查文件是否存在
  Future<Map<String, bool>> checkFilesExist(List<String> filePaths) async {
    final result = <String, bool>{};
    for (final filePath in filePaths) {
      result[filePath] = File(filePath).existsSync();
    }
    return result;
  }

  // 获取歌曲数量
  Future<int> get songCount async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_songTableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ========== 播放列表管理 ==========

  // 保存播放列表
  Future<void> savePlaylist(Playlist playlist) async {
    final db = await database;
    await db.insert(
      _playlistTableName,
      playlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取所有播放列表
  Future<List<Playlist>> getAllPlaylists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _playlistTableName,
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => Playlist.fromMap(map)).toList();
  }

  // 根据ID获取播放列表
  Future<Playlist?> getPlaylistById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _playlistTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Playlist.fromMap(maps.first);
  }

  // 删除播放列表
  Future<void> deletePlaylist(String id) async {
    final db = await database;
    await db.delete(
      _playlistTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== 播放历史记录管理 ==========

  // 添加或更新播放记录
  Future<void> addOrUpdatePlayHistory(String songId) async {
    final db = await database;
    final existing = await getPlayHistoryBySongId(songId);
    
    if (existing != null) {
      final updated = existing.updatePlayCount();
      await db.update(
        _historyTableName,
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      final history = PlayHistory.create(songId: songId);
      await db.insert(
        _historyTableName,
        history.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // 根据歌曲ID获取播放记录
  Future<PlayHistory?> getPlayHistoryBySongId(String songId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _historyTableName,
      where: 'songId = ?',
      whereArgs: [songId],
      orderBy: 'playedAt DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return PlayHistory.fromMap(maps.first);
  }

  // 获取所有播放历史（按时间倒序）
  Future<List<PlayHistory>> getAllPlayHistory({int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _historyTableName,
      orderBy: 'playedAt DESC',
      limit: limit,
    );
    return maps.map((map) => PlayHistory.fromMap(map)).toList();
  }

  // 删除播放记录
  Future<void> deletePlayHistory(String id) async {
    final db = await database;
    await db.delete(
      _historyTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 清空所有播放记录
  Future<void> clearAllPlayHistory() async {
    final db = await database;
    await db.delete(_historyTableName);
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}