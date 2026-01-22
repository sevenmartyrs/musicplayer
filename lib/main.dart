import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:collection/collection.dart';
import 'models/song.dart';
import 'services/song_database.dart';
import 'services/music_scanner.dart';
import 'providers/player_provider.dart';
import 'pages/library_page.dart';
import 'pages/playlist_page.dart';
import 'pages/playlists_page.dart';
import 'pages/history_page.dart';
import 'pages/settings_page.dart';
import 'pages/now_playing_page.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/player_bar.dart';

void main() {
  // 移除 MetadataGod.initialize()，延迟到应用启动后
  runApp(const MusicPlayerApp());
}

class MusicPlayerApp extends StatefulWidget {
  const MusicPlayerApp({super.key});

  @override
  State<MusicPlayerApp> createState() => _MusicPlayerAppState();
}

class _MusicPlayerAppState extends State<MusicPlayerApp> {
  int _currentIndex = 0;
  bool _showNowPlaying = false;
  final List<Song> _localSongs = []; // 本地歌曲列表
  final SongDatabase _database = SongDatabase.instance;
  late MusicScanner _scanner;
  bool _hasRestoredPlaybackState = false; // 是否已恢复播放状态
  bool _isInitialized = false; // 是否已初始化完成
  bool _isMetadataInitialized = false; // MetadataGod 是否已初始化

  // 提供不可变视图
  UnmodifiableListView<Song> get localSongs => 
      UnmodifiableListView(_localSongs);

  @override
  void initState() {
    super.initState();
    _scanner = MusicScanner(_database);
    _initializeAsync();
  }

  // 异步初始化，避免阻塞UI
  Future<void> _initializeAsync() async {
    try {
      // 立即标记为已初始化，显示主界面（空状态）
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      
      // 在后台并行初始化
      final futures = <Future>[];
      
      // 1. 初始化 MetadataGod（延迟到真正需要时）
      // 不在这里初始化，而是在扫描音乐时才初始化
      
      // 2. 初始化数据库
      futures.add(_database.database);
      
      // 3. 加载歌曲
      futures.add(_loadSongs());
      
      // 并行执行
      await Future.wait(futures);
      
      debugPrint('Background initialization completed');
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  // 恢复播放状态（移出 build 方法）
  void _restorePlayerState(PlayerProvider playerProvider) {
    if (!_hasRestoredPlaybackState && _localSongs.isNotEmpty) {
      _hasRestoredPlaybackState = true;
      playerProvider.loadPlaylist(_localSongs).then((_) {
        playerProvider.restorePlaybackState(playerProvider.playlist);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSongs() async {
    try {
      // 检查并移除不存在的文件
      await _database.removeMissingFiles();
      
      // 从数据库加载歌曲
      final updatedSongs = await _database.getAllSongs();
      
      // 只在数据真正变化时更新
      if (mounted) {
        final needsUpdate = _localSongs.length != updatedSongs.length ||
                           !_listsEqual(_localSongs, updatedSongs);
        
        if (needsUpdate) {
          setState(() {
            _localSongs.clear();
            _localSongs.addAll(updatedSongs);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading songs: $e');
    }
  }

  // 比较两个歌曲列表是否相等
  bool _listsEqual(List<Song> a, List<Song> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // 显示加载状态
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                ),
                const SizedBox(height: 16),
                Text(
                  '正在加载...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return ChangeNotifierProvider(
      create: (_) => PlayerProvider(),
      child: MaterialApp(
        title: '乐库',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
        ),
        home: Consumer<PlayerProvider>(
          builder: (context, playerProvider, _) {
            // 使用 addPostFrameCallback 延迟执行恢复播放状态
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _restorePlayerState(playerProvider);
            });
            
            return Stack(
              children: [
                Scaffold(
                  backgroundColor: Colors.white,
                  body: _buildCurrentPage(playerProvider),
                  bottomNavigationBar: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PlayerBar(
                        playerState: playerProvider.state,
                        onPlayPause: playerProvider.togglePlayPause,
                        onTap: () => setState(() => _showNowPlaying = true),
                      ),
                      BottomNavBar(
                        currentIndex: _currentIndex,
                        onTap: _onNavBarTap,
                      ),
                    ],
                  ),
                ),
                if (_showNowPlaying)
                  NowPlayingPage(
                    playerState: playerProvider.state,
                    onClose: () => setState(() => _showNowPlaying = false),
                    onPlayPause: playerProvider.togglePlayPause,
                    onPrevious: playerProvider.playPrevious,
                    onNext: playerProvider.playNext,
                    onShuffle: playerProvider.toggleShuffle,
                    onRepeat: playerProvider.toggleRepeat,
                    onSeek: playerProvider.seekTo,
                    remainingSleepTime: playerProvider.remainingSleepTime,
                    onSetSleepTimer: playerProvider.setSleepTimer,
                    onCancelSleepTimer: playerProvider.cancelSleepTimer,
                    lyric: playerProvider.currentLyric,
                    currentLyricIndex: playerProvider.getCurrentLyricIndex(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentPage(PlayerProvider playerProvider) {
    switch (_currentIndex) {
      case 0:
        return LibraryPage(
          songs: localSongs,
          onSongTap: (song) => _playSongFromLibrary(song, playerProvider),
          onSongsUpdated: (songs) async {
            // 保存到数据库
            await _database.saveSongs(songs);
            
            // 更新本地列表
            final needsUpdate = _localSongs.length != songs.length ||
                               !_listsEqual(_localSongs, songs);
            
            if (needsUpdate) {
              setState(() {
                _localSongs.clear();
                _localSongs.addAll(songs);
              });
            }
          },
          scanner: _scanner,
          database: _database,
        );
      case 1:
        return PlaylistPage(
          songs: playerProvider.playlist,
          currentSong: playerProvider.state.currentSong,
          onSongTap: (song) => _playSongFromPlaylist(song, playerProvider),
        );
      case 2:
        return PlaylistsPage(
          allSongs: localSongs,
        );
      case 3:
        return SettingsPage(
          allSongs: localSongs,
          onSongTap: (song) => _playSongFromHistory(song, playerProvider),
          scanner: _scanner,
          database: _database,
          onSongsUpdated: (songs) async {
            // 保存到数据库
            await _database.saveSongs(songs);
            
            // 更新本地列表
            final needsUpdate = _localSongs.length != songs.length ||
                               !_listsEqual(_localSongs, songs);
            
            if (needsUpdate) {
              setState(() {
                _localSongs.clear();
                _localSongs.addAll(songs);
              });
            }
          },
        );
      default:
        return LibraryPage(
          songs: localSongs,
          onSongTap: (song) => _playSongFromLibrary(song, playerProvider),
          onSongsUpdated: (songs) async {
            // 保存到数据库
            await _database.saveSongs(songs);
            
            // 更新本地列表
            final needsUpdate = _localSongs.length != songs.length ||
                               !_listsEqual(_localSongs, songs);
            
            if (needsUpdate) {
              setState(() {
                _localSongs.clear();
                _localSongs.addAll(songs);
              });
            }
          },
          scanner: _scanner,
          database: _database,
        );
    }
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _playSongFromLibrary(Song song, PlayerProvider playerProvider) async {
    // 来自乐库页面：只添加到列表，不切换歌曲
    await playerProvider.addToPlaylist(song);
    
    // 如果当前没有播放歌曲，则开始播放
    if (playerProvider.state.currentSong == null) {
      final index = playerProvider.getPlaylistIndex(song.id);
      await playerProvider.playSong(song, playerProvider.playlist, index);
    }
  }

  Future<void> _playSongFromPlaylist(Song song, PlayerProvider playerProvider) async {
    // 来自列表页面：切换到该歌曲
    // 如果点击的是当前正在播放的歌曲，不重新播放
    if (playerProvider.state.currentSong?.id == song.id) {
      // 当前正在播放这首歌，不做任何操作
      return;
    }
    
    final index = playerProvider.getPlaylistIndex(song.id);
    if (index >= 0) {
      await playerProvider.playSong(song, playerProvider.playlist, index);
    }
  }

  Future<void> _playSongFromHistory(Song song, PlayerProvider playerProvider) async {
    // 来自历史记录页面：切换到该歌曲
    final index = playerProvider.getPlaylistIndex(song.id);
    if (index >= 0) {
      await playerProvider.playSong(song, playerProvider.playlist, index);
    } else {
      // 如果歌曲不在播放列表中，先添加再播放
      await playerProvider.addToPlaylist(song);
      final newIndex = playerProvider.getPlaylistIndex(song.id);
      if (newIndex >= 0) {
        await playerProvider.playSong(song, playerProvider.playlist, newIndex);
      }
    }
  }
}