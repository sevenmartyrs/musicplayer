import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/player_state.dart';
import '../models/song.dart';
import '../models/lyric.dart';

/// 播放器状态提供者 - Mock 版本，用于 UI 展示
class PlayerProvider extends ChangeNotifier {
  PlayerState _state = PlayerState();
  List<Song> _playlist = [];
  Timer? _positionTimer;
  Timer? _sleepTimer;
  DateTime? _sleepEndTime;
  Lyric? _currentLyric;
  final Set<String> _favoriteSongIds = {}; // 收藏歌曲ID集合
  double _lyricFontSize = 16.0; // 歌词字体大小
  
  // 使用 ValueNotifier 只通知进度变化，避免不必要的重建
  final ValueNotifier<double> _positionNotifier = ValueNotifier(0.0);

  PlayerState get state => _state;
  List<Song> get playlist => _playlist;
  Lyric? get currentLyric => _currentLyric;
  Duration? get remainingSleepTime {
    if (_sleepEndTime == null) return null;
    final remaining = _sleepEndTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
  List<Song> get favoriteSongs => _playlist.where((s) => _favoriteSongIds.contains(s.id)).toList();
  double get lyricFontSize => _lyricFontSize;
  
  /// 进度值监听器（0.0 - 1.0），用于更新进度条而不重建整个页面
  ValueListenable<double> get positionProgress => _positionNotifier;

  PlayerProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // 创建一些 mock 歌曲
    final mockSongs = [
      Song(
        id: '1',
        title: '示例歌曲 1',
        artist: '艺术家 A',
        album: '专辑 A',
        duration: 210,
      ),
      Song(
        id: '2',
        title: '示例歌曲 2',
        artist: '艺术家 B',
        album: '专辑 B',
        duration: 185,
      ),
      Song(
        id: '3',
        title: '示例歌曲 3',
        artist: '艺术家 C',
        album: '专辑 C',
        duration: 240,
      ),
      Song(
        id: '4',
        title: '示例歌曲 4',
        artist: '艺术家 D',
        album: '专辑 D',
        duration: 195,
      ),
      Song(
        id: '5',
        title: '示例歌曲 5',
        artist: '艺术家 E',
        album: '专辑 E',
        duration: 225,
      ),
    ];

    _playlist = mockSongs;
    _state = PlayerState(
      currentSong: mockSongs.first,
      playlist: mockSongs,
      currentIndex: 0,
      currentPosition: 0,
      isPlaying: false,
    );

    // 创建 mock 歌词
    _currentLyric = Lyric(lines: [
      LyricLine(time: 0, text: '夜幕降临 星光璀璨'),
      LyricLine(time: 5000, text: '风中传来 悠扬旋律'),
      LyricLine(time: 10000, text: '回忆如潮 涌上心头'),
      LyricLine(time: 15000, text: '那段时光 刻骨铭心'),
      LyricLine(time: 20000, text: '灯火阑珊 人影阑珊'),
      LyricLine(time: 25000, text: '岁月匆匆 如白驹过隙'),
      LyricLine(time: 30000, text: '思念如歌 轻轻哼唱'),
      LyricLine(time: 35000, text: '梦中相见 亦真亦幻'),
      LyricLine(time: 40000, text: '晨曦微露 露珠晶莹'),
      LyricLine(time: 45000, text: '鸟儿啼鸣 唤醒清晨'),
      LyricLine(time: 50000, text: '时光荏苒 春去秋来'),
      LyricLine(time: 55000, text: '花开花落 云卷云舒'),
      LyricLine(time: 60000, text: '心之所向 素履以往'),
      LyricLine(time: 65000, text: '岁月静好 安之若素'),
      LyricLine(time: 70000, text: '梦想在前 勇往直前'),
      LyricLine(time: 75000, text: '风雨兼程 无所畏惧'),
      LyricLine(time: 80000, text: '星光不问 赶路人'),
      LyricLine(time: 85000, text: '时光不负 有心人'),
      LyricLine(time: 90000, text: '愿你出走 归来仍是少年'),
      LyricLine(time: 95000, text: '愿你历尽千帆 归来仍少年'),
    ]);

    notifyListeners();
  }

  Future<void> loadPlaylist(List<Song> allSongs) async {
    _playlist = allSongs;
    if (_state.currentSong == null && _playlist.isNotEmpty) {
      _state = _state.copyWith(
        currentSong: _playlist.first,
        playlist: _playlist,
        currentIndex: 0,
      );
    }
    notifyListeners();
  }

  Future<void> playSong(Song song, List<Song> playlist, int index) async {
    _state = _state.copyWith(
      currentSong: song,
      playlist: playlist,
      currentIndex: index,
      currentPosition: 0,
      isPlaying: true,
    );
    _updatePositionNotifier();
    notifyListeners();
    _startPositionTimer();
  }

  Future<void> pause() async {
    _state = _state.copyWith(isPlaying: false);
    notifyListeners();
    _stopPositionTimer();
  }

  Future<void> resume() async {
    _state = _state.copyWith(isPlaying: true);
    notifyListeners();
    _startPositionTimer();
  }

  Future<void> togglePlayPause() async {
    if (_state.isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> seekTo(double value) async {
    if (_state.currentSong == null) return;
    final newPosition = (value * _state.currentSong!.duration).round();
    _state = _state.copyWith(currentPosition: newPosition);
    _updatePositionNotifier();
    notifyListeners();
  }

  Future<void> playNext() async {
    if (_state.playlist.isEmpty) return;
    final newIndex = (_state.currentIndex + 1) % _state.playlist.length;
    await playSong(_state.playlist[newIndex], _state.playlist, newIndex);
  }

  Future<void> playPrevious() async {
    if (_state.playlist.isEmpty) return;
    final newIndex = (_state.currentIndex - 1 + _state.playlist.length) % _state.playlist.length;
    await playSong(_state.playlist[newIndex], _state.playlist, newIndex);
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

  void togglePlayMode() {
    // 循环切换播放模式：顺序 → 随机 → 单曲循环 → 顺序
    PlayMode newMode;
    switch (_state.playMode) {
      case PlayMode.sequence:
        newMode = PlayMode.shuffle;
        break;
      case PlayMode.shuffle:
        newMode = PlayMode.repeat;
        break;
      case PlayMode.repeat:
        newMode = PlayMode.sequence;
        break;
    }
    _state = _state.copyWith(playMode: newMode);
    notifyListeners();
  }

  Future<void> addToPlaylist(Song song) async {
    if (!_playlist.any((s) => s.id == song.id)) {
      _playlist.add(song);
      notifyListeners();
    }
  }

  Future<void> removeFromPlaylist(Song song) async {
    _playlist.removeWhere((s) => s.id == song.id);
    notifyListeners();
  }

  Future<void> clearPlaylist() async {
    _playlist.clear();
    notifyListeners();
  }

  int getPlaylistIndex(String songId) {
    return _playlist.indexWhere((s) => s.id == songId);
  }

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

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _clearSleepTimer();
    notifyListeners();
  }

  void _clearSleepTimer() {
    _sleepTimer = null;
    _sleepEndTime = null;
    notifyListeners();
  }

  void _startPositionTimer() {
    _stopPositionTimer();
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.currentSong != null && _state.isPlaying) {
        final newPosition = _state.currentPosition + 1;
        if (newPosition >= _state.currentSong!.duration) {
          _onPlaybackComplete();
        } else {
          _state = _state.copyWith(currentPosition: newPosition);
          _updatePositionNotifier();
          // 只在需要歌词索引变化时通知其他监听者
          // 大部分 UI 变化由 positionNotifier 处理
        }
      }
    });
  }

  void _updatePositionNotifier() {
    if (_state.currentSong != null && _state.currentSong!.duration > 0) {
      _positionNotifier.value = _state.currentPosition / _state.currentSong!.duration;
    } else {
      _positionNotifier.value = 0.0;
    }
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  void _onPlaybackComplete() {
    _stopPositionTimer();
    switch (_state.playMode) {
      case PlayMode.repeat:
        if (_state.currentSong != null) {
          _state = _state.copyWith(currentPosition: 0);
          _updatePositionNotifier();
          notifyListeners();
          _startPositionTimer();
        }
        break;
      case PlayMode.shuffle:
        if (_state.playlist.length > 1) {
          final randomIndex = (_state.currentIndex + 1) % _state.playlist.length;
          playSong(_state.playlist[randomIndex], _state.playlist, randomIndex);
        }
        break;
      case PlayMode.sequence:
        playNext();
        break;
    }
  }

  int getCurrentLyricIndex() {
    if (_currentLyric == null || _currentLyric!.lines.isEmpty) {
      return -1;
    }

    final currentTime = _state.currentPosition * 1000;
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

  // ========== 收藏功能 ==========

  /// 切换收藏状态
  void toggleFavorite(Song song) {
    if (_favoriteSongIds.contains(song.id)) {
      _favoriteSongIds.remove(song.id);
    } else {
      _favoriteSongIds.add(song.id);
    }
    notifyListeners();
  }

  /// 检查歌曲是否已收藏
  bool isFavorite(String songId) {
    return _favoriteSongIds.contains(songId);
  }

  /// 获取收藏列表
  List<Song> getFavoriteSongs() {
    return _playlist.where((s) => _favoriteSongIds.contains(s.id)).toList();
  }

  // ========== 歌词字体大小调节 ==========

  /// 设置歌词字体大小
  void setLyricFontSize(double size) {
    _lyricFontSize = size.clamp(12.0, 24.0);
    notifyListeners();
  }

  /// 增加歌词字体大小
  void increaseLyricFontSize() {
    setLyricFontSize(_lyricFontSize + 2);
  }

  /// 减小歌词字体大小
  void decreaseLyricFontSize() {
    setLyricFontSize(_lyricFontSize - 2);
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _stopPositionTimer();
    _positionNotifier.dispose();
    super.dispose();
  }
}