import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// 持久化服务 - 集中管理应用数据的持久化
class PersistenceService {
  // 播放状态相关键
  static const String _keyCurrentSongId = 'current_song_id';
  static const String _keyCurrentPosition = 'current_position';
  static const String _keyIsPlaying = 'is_playing';
  static const String _keyPlayMode = 'play_mode';
  
  // 播放列表相关键
  static const String _keyPlaylist = 'playlist';

  static PersistenceService? _instance;
  
  // 私有构造函数
  PersistenceService._();
  
  // 获取单例实例
  static PersistenceService get instance {
    _instance ??= PersistenceService._();
    return _instance!;
  }

  /// 保存播放状态
  Future<void> savePlayerState({
    String? currentSongId,
    int? currentPosition,
    bool? isPlaying,
    int? playMode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (currentSongId != null) {
        await prefs.setString(_keyCurrentSongId, currentSongId);
      }
      if (currentPosition != null) {
        await prefs.setInt(_keyCurrentPosition, currentPosition);
      }
      if (isPlaying != null) {
        await prefs.setBool(_keyIsPlaying, isPlaying);
      }
      if (playMode != null) {
        await prefs.setInt(_keyPlayMode, playMode);
      }
    } catch (e) {
      // 忽略保存错误，避免影响用户体验
      debugPrint('Error saving player state: $e');
    }
  }

  /// 加载播放状态
  Future<PlayerStateData> loadPlayerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return PlayerStateData(
        currentSongId: prefs.getString(_keyCurrentSongId),
        currentPosition: prefs.getInt(_keyCurrentPosition) ?? 0,
        isPlaying: prefs.getBool(_keyIsPlaying) ?? false,
        playMode: prefs.getInt(_keyPlayMode) ?? 0,
      );
    } catch (e) {
      debugPrint('Error loading player state: $e');
      return PlayerStateData();
    }
  }

  /// 保存播放列表
  Future<void> savePlaylist(List<String> songIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPlaylist, jsonEncode(songIds));
    } catch (e) {
      debugPrint('Error saving playlist: $e');
    }
  }

  /// 加载播放列表
  Future<List<String>> loadPlaylist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistJson = prefs.getString(_keyPlaylist);
      
      if (playlistJson != null) {
        final List<dynamic> decoded = jsonDecode(playlistJson);
        return decoded.cast<String>();
      }
      return [];
    } catch (e) {
      debugPrint('Error loading playlist: $e');
      return [];
    }
  }

  /// 清除所有播放状态
  Future<void> clearPlayerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCurrentSongId);
      await prefs.remove(_keyCurrentPosition);
      await prefs.remove(_keyIsPlaying);
      await prefs.remove(_keyPlayMode);
    } catch (e) {
      debugPrint('Error clearing player state: $e');
    }
  }

  /// 清除播放列表
  Future<void> clearPlaylist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPlaylist);
    } catch (e) {
      debugPrint('Error clearing playlist: $e');
    }
  }
}

/// 播放状态数据模型
class PlayerStateData {
  final String? currentSongId;
  final int currentPosition;
  final bool isPlaying;
  final int playMode;

  PlayerStateData({
    this.currentSongId,
    this.currentPosition = 0,
    this.isPlaying = false,
    this.playMode = 0,
  });
}