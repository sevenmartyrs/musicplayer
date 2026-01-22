import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/player_state.dart';
import '../models/song.dart';
import '../models/lyric.dart';
import '../services/audio_service.dart' as audio;
import '../services/persistence_service.dart';
import '../services/song_database.dart';
import '../services/lyric_service.dart';

/// 播放器状态提供者 - 管理音频播放状态和播放列表
class PlayerProvider extends ChangeNotifier {
  final audio.AudioService _audioService = audio.AudioService();
  final PersistenceService _persistenceService = PersistenceService.instance;
  final SongDatabase _database = SongDatabase.instance;
  
  PlayerState _state = PlayerState();
  List<Song> _playlist = []; // 播放列表
  
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playingSubscription;
  StreamSubscription? _completionSubscription;
  
  // 睡眠定时器
  Timer? _sleepTimer;
  DateTime? _sleepEndTime;
  
  // 歌词
  Lyric? _currentLyric;
  final LyricService _lyricService = LyricService.instance;

  PlayerState get state => _state;
  List<Song> get playlist => _playlist;
  Lyric? get currentLyric => _currentLyric;

  PlayerProvider() {
    _initListeners();
    _loadPlaybackState();
  }

  // 加载播放状态（只加载基本状态，不恢复播放）
  Future<void> _loadPlaybackState() async {
    final stateData = await _persistenceService.loadPlayerState();
    
    _state = _state.copyWith(
      currentPosition: stateData.currentPosition,
      isPlaying: stateData.isPlaying,
      playMode: PlayMode.values[stateData.playMode],
    );
  }

  // 恢复播放状态（需要在播放列表加载后调用）
  Future<void> restorePlaybackState(List<Song> playlist) async {
    final stateData = await _persistenceService.loadPlayerState();
    
    if (stateData.currentSongId != null && playlist.isNotEmpty) {
      final songIndex = playlist.indexWhere((s) => s.id == stateData.currentSongId);
      
      if (songIndex >= 0) {
        final song = playlist[songIndex];
        
        _state = _state.copyWith(
          currentSong: song,
          playlist: playlist,
          currentIndex: songIndex,
          currentPosition: stateData.currentPosition,
          isPlaying: false, // 始终恢复为暂停状态
        );
        
        notifyListeners();
        
        // 使用 load 方法加载歌曲，并直接设置初始位置
        final initialPosition = Duration(seconds: stateData.currentPosition);
        await _audioService.load(song, initialPosition: initialPosition);
        
        // 恢复为暂停状态后，更新保存的状态
        await _persistenceService.savePlayerState(
          currentSongId: stateData.currentSongId,
          currentPosition: stateData.currentPosition,
          isPlaying: false,
          playMode: stateData.playMode,
        );
      }
    }
  }

  // 保存播放状态
  Future<void> savePlaybackState() async {
    await _persistenceService.savePlayerState(
      currentSongId: _state.currentSong?.id,
      currentPosition: _state.currentPosition,
      isPlaying: _state.isPlaying,
      playMode: _state.playMode.index,
    );
  }

  void _initListeners() async {
    // 监听播放位置变化 - 使用节流减少更新频率
    _positionSubscription = _audioService.positionStream.listen((position) {
      final newPosition = position.inSeconds;
      // 只在位置真正改变时才更新（每秒最多更新一次）
      if (newPosition != _state.currentPosition) {
        _state = _state.copyWith(currentPosition: newPosition);
        notifyListeners();
      }
    });

    // 监听音频时长变化
    _durationSubscription = _audioService.durationStream.listen((duration) {
      if (duration != null && _state.currentSong != null) {
        notifyListeners();
      }
    });

    // 监听播放状态变化
    _playingSubscription = _audioService.playingStream.listen((isPlaying) {
      _state = _state.copyWith(isPlaying: isPlaying);
      notifyListeners();
    });

    // 监听播放完成
    _completionSubscription = _audioService.completionStream.listen((_) {
      _onPlaybackComplete();
    });
  }

  Future<void> playSong(Song song, List<Song> playlist, int index) async {
    if (playlist.isEmpty || index < 0 || index >= playlist.length) {
      return;
    }
    
    try {
      _state = _state.copyWith(
        currentSong: song,
        playlist: playlist,
        currentIndex: index,
        currentPosition: 0,
        isPlaying: true,
      );
      notifyListeners();
      
      await _audioService.play(song);
      
      // 加载歌词
      _loadLyric(song.audioUrl ?? song.id);
      
      // 记录播放历史
      await _database.addOrUpdatePlayHistory(song.id);
      
      // 预加载下一首歌曲
      if (index < playlist.length - 1) {
        final nextSong = playlist[index + 1];
        _audioService.preloadNext(song, nextSong);
      }
    } catch (e) {
      debugPrint('Error playing song: $e');
    }
  }

  Future<void> pause() async {
    await _audioService.pause();
  }

  Future<void> resume() async {
    await _audioService.resume();
  }

  Future<void> togglePlayPause() async {
    // 使用音频引擎的实际状态
    final isCurrentlyPlaying = _audioService.isPlaying;
    
    // 先更新UI状态，确保立即响应
    _state = _state.copyWith(isPlaying: !isCurrentlyPlaying);
    notifyListeners();
    
    // 再调用音频操作
    if (isCurrentlyPlaying) {
      await pause();
    } else {
      await resume();
    }
    
    await savePlaybackState();
  }

  Future<void> seekTo(double value) async {
    if (_state.currentSong == null) return;
    
    final duration = _audioService.duration ?? Duration.zero;
    final position = Duration(
      milliseconds: (duration.inMilliseconds * value).round(),
    );
    
    await _audioService.seek(position);
  }

  Future<void> playNext() async {
    if (_state.playlist.isEmpty) return;
    
    try {
      final newIndex = (_state.currentIndex + 1) % _state.playlist.length;
      final newSong = _state.playlist[newIndex];
      
      await playSong(newSong, _state.playlist, newIndex);
    } catch (e) {
      debugPrint('Error playing next song: $e');
    }
  }

  Future<void> playPrevious() async {
    if (_state.playlist.isEmpty) return;
    
    try {
      final newIndex = (_state.currentIndex - 1 + _state.playlist.length) % _state.playlist.length;
      final newSong = _state.playlist[newIndex];
      
      await playSong(newSong, _state.playlist, newIndex);
    } catch (e) {
      debugPrint('Error playing previous song: $e');
    }
  }

  void toggleShuffle() {
    final newMode = _state.playMode == PlayMode.shuffle
        ? PlayMode.sequence
        : PlayMode.shuffle;
    _state = _state.copyWith(playMode: newMode);
    notifyListeners();
  }

  void toggleRepeat() {
    final newMode = _state.playMode == PlayMode.repeat
        ? PlayMode.sequence
        : PlayMode.repeat;
    _state = _state.copyWith(playMode: newMode);
    notifyListeners();
  }

  void _onPlaybackComplete() {
    switch (_state.playMode) {
      case PlayMode.repeat:
        // 单曲循环：重新播放当前歌曲
        if (_state.currentSong != null) {
          playSong(_state.currentSong!, _state.playlist, _state.currentIndex);
        }
        break;
      case PlayMode.shuffle:
        // 随机播放：随机选择下一首
        if (_state.playlist.length > 1) {
          final randomIndex = (_state.currentIndex + 1) % _state.playlist.length;
          playSong(_state.playlist[randomIndex], _state.playlist, randomIndex);
        }
        break;
      case PlayMode.sequence:
        // 顺序播放：播放下一首
        playNext();
        break;
    }
  }

  @override
  void dispose() {
    // 退出时保存为暂停状态
    _savePlaybackStateForExit();
    
    _sleepTimer?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playingSubscription?.cancel();
    _completionSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  // 退出时保存为暂停状态
  Future<void> _savePlaybackStateForExit() async {
    await _persistenceService.savePlayerState(
      currentSongId: _state.currentSong?.id,
      currentPosition: _state.currentPosition,
      isPlaying: false, // 退出时总是保存为暂停
      playMode: _state.playMode.index,
    );
  }

  // ========== 播放列表管理 ==========

  /// 加载播放列表
  Future<void> loadPlaylist(List<Song> allSongs) async {
    final songIds = await _persistenceService.loadPlaylist();
    
    _playlist.clear();
    for (final songId in songIds) {
      final song = allSongs.firstWhere(
        (s) => s.id == songId,
        orElse: () => allSongs.isNotEmpty ? allSongs.first : Song.empty(),
      );
      if (song.id.isNotEmpty) {
        _playlist.add(song);
      }
    }
    
    notifyListeners();
  }

  /// 保存播放列表
  Future<void> savePlaylist() async {
    final songIds = _playlist.map((s) => s.id).toList();
    await _persistenceService.savePlaylist(songIds);
  }

  /// 添加歌曲到播放列表
  Future<void> addToPlaylist(Song song) async {
    if (!_playlist.any((s) => s.id == song.id)) {
      _playlist.add(song);
      await savePlaylist();
      notifyListeners();
    }
  }

  /// 从播放列表中移除歌曲
  Future<void> removeFromPlaylist(Song song) async {
    _playlist.removeWhere((s) => s.id == song.id);
    await savePlaylist();
    notifyListeners();
  }

  /// 清空播放列表
  Future<void> clearPlaylist() async {
    _playlist.clear();
    await _persistenceService.clearPlaylist();
    notifyListeners();
  }

  /// 获取播放列表中的歌曲索引
  int getPlaylistIndex(String songId) {
    return _playlist.indexWhere((s) => s.id == songId);
  }

  /// ========== 睡眠定时器 ==========

  /// 设置睡眠定时器
  void setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepEndTime = DateTime.now().add(duration);
    
    _sleepTimer = Timer(duration, () {
      if (_state.isPlaying) {
        pause();
      }
      _clearSleepTimer();
    });
    
    notifyListeners();
  }

  /// 取消睡眠定时器
  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _clearSleepTimer();
    notifyListeners();
  }

  /// 清空睡眠定时器状态
  void _clearSleepTimer() {
    _sleepTimer = null;
    _sleepEndTime = null;
    notifyListeners();
  }

  /// 获取剩余睡眠时间
  Duration? get remainingSleepTime {
    if (_sleepEndTime == null) return null;
    final remaining = _sleepEndTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 是否设置了睡眠定时器
  bool get hasSleepTimer => _sleepTimer != null;
  
  /// 加载歌词
  Future<void> _loadLyric(String audioPath) async {
    try {
      final lyric = await _lyricService.findLyric(audioPath);
      _currentLyric = lyric;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load lyric: $e');
      _currentLyric = null;
      notifyListeners();
    }
  }
  
  /// 获取当前歌词行
  String? getCurrentLyric() {
    if (_currentLyric == null || _currentLyric!.lines.isEmpty) {
      return null;
    }
    
    final currentTime = _state.currentPosition;
    for (int i = 0; i < _currentLyric!.lines.length; i++) {
      final line = _currentLyric!.lines[i];
      if (line.time <= currentTime) {
        // 检查下一行的时间，如果下一行的时间大于当前时间，则当前行是当前歌词
        if (i == _currentLyric!.lines.length - 1) {
          return line.text;
        }
        final nextLine = _currentLyric!.lines[i + 1];
        if (nextLine.time > currentTime) {
          return line.text;
        }
      }
    }
    return null;
  }
  
  /// 获取当前歌词行索引
  int getCurrentLyricIndex() {
    if (_currentLyric == null || _currentLyric!.lines.isEmpty) {
      return -1;
    }
    
    final currentTime = _state.currentPosition;
    for (int i = 0; i < _currentLyric!.lines.length; i++) {
      final line = _currentLyric!.lines[i];
      if (line.time <= currentTime) {
        if (i == _currentLyric!.lines.length - 1) {
          return i;
        }
        final nextLine = _currentLyric!.lines[i + 1];
        if (nextLine.time > currentTime) {
          return i;
        }
      }
    }
    return -1;
  }
}