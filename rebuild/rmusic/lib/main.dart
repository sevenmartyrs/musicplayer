import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/song.dart';
import 'models/playlist.dart';
import 'providers/player_provider.dart';
import 'pages/library_page.dart';
import 'pages/playlists_page.dart';
import 'pages/settings_page.dart';
import 'pages/now_playing_page.dart';
import 'pages/artists_page.dart';
import 'pages/albums_page.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/side_nav_bar.dart';
import 'widgets/player_bar.dart';

void main() {
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

  // 使用 mock 数据
  final List<Song> _localSongs = [
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

  // 歌单列表
  List<Playlist> _playlists = [
    Playlist.create(
      name: '我喜欢的',
      songIds: ['1', '2'],
      isDefault: true,
      description: '我收藏的所有喜欢的音乐',
    ),
    Playlist.create(
      name: '工作音乐',
      songIds: ['3', '4', '5'],
      description: '适合工作时听的专注音乐',
    ),
    Playlist.create(
      name: '放松音乐',
      songIds: ['1', '3'],
      description: '舒缓的音乐，让人放松心情',
    ),
    Playlist.create(
      name: '运动歌单',
      songIds: ['2', '4', '5'],
      description: '充满活力的运动音乐',
    ),
    Playlist.create(
      name: '晚间冥想',
      songIds: ['1', '2', '3'],
      description: '适合晚间冥想和睡眠的轻音乐',
    ),
    Playlist.create(
      name: '旅途时光',
      songIds: ['3', '4'],
      description: '旅途中陪伴的音乐',
    ),
    Playlist.create(
      name: '电子乐',
      songIds: ['1', '5'],
      description: '精选电子音乐合集',
    ),
    Playlist.create(
      name: '经典老歌',
      songIds: ['2', '3', '4'],
      description: '怀旧经典，时光回响',
    ),
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        home: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 600;
            
            if (isDesktop) {
              // 桌面端：左侧导航栏 + 右侧内容
              return Stack(
                children: [
                  Scaffold(
                    backgroundColor: Colors.white,
                    body: Row(
                      children: [
                        // 左侧导航栏
                        SideNavBar(
                          currentIndex: _currentIndex,
                          onTap: _onNavBarTap,
                        ),
                        // 右侧内容
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: RepaintBoundary(
                                  child: _buildCurrentPage(),
                                ),
                              ),
                              RepaintBoundary(
                                child: Consumer<PlayerProvider>(
                                  builder: (context, playerProvider, _) => PlayerBar(
                                    playerState: playerProvider.state,
                                    onPlayPause: playerProvider.togglePlayPause,
                                    onTap: () => setState(() => _showNowPlaying = true),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showNowPlaying)
                    RepaintBoundary(
                      child: Consumer<PlayerProvider>(
                        builder: (context, playerProvider, _) => NowPlayingPage(
                          playerState: playerProvider.state,
                          onClose: () => setState(() => _showNowPlaying = false),
                          onPlayPause: playerProvider.togglePlayPause,
                          onPrevious: playerProvider.playPrevious,
                          onNext: playerProvider.playNext,
                          onShuffle: playerProvider.toggleShuffle,
                          onRepeat: playerProvider.toggleRepeat,
                          onTogglePlayMode: playerProvider.togglePlayMode,
                          onSeek: playerProvider.seekTo,
                          remainingSleepTime: playerProvider.remainingSleepTime,
                          onSetSleepTimer: playerProvider.setSleepTimer,
                          onCancelSleepTimer: playerProvider.cancelSleepTimer,
                          lyric: playerProvider.currentLyric,
                          currentLyricIndex: playerProvider.getCurrentLyricIndex(),
                          isFavorite: playerProvider.state.currentSong != null ? playerProvider.isFavorite(playerProvider.state.currentSong!.id) : false,
                          onToggleFavorite: () {
                            if (playerProvider.state.currentSong != null) {
                              playerProvider.toggleFavorite(playerProvider.state.currentSong!);
                            }
                          },
                          lyricFontSize: playerProvider.lyricFontSize,
                          onSetLyricFontSize: playerProvider.setLyricFontSize,
                          onPlaySongAt: (index) => playerProvider.playSong(
                            playerProvider.playlist[index],
                            playerProvider.playlist,
                            index,
                          ),
                          positionProgress: playerProvider.positionProgress,
                        ),
                      ),
                    ),
                ],
              );
            } else {
              // 移动端：底部导航栏
              return Stack(
                children: [
                  Scaffold(
                    backgroundColor: Colors.white,
                    body: RepaintBoundary(
                      child: _buildCurrentPage(),
                    ),
                    bottomNavigationBar: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RepaintBoundary(
                          child: Consumer<PlayerProvider>(
                            builder: (context, playerProvider, _) => PlayerBar(
                              playerState: playerProvider.state,
                              onPlayPause: playerProvider.togglePlayPause,
                              onTap: () => setState(() => _showNowPlaying = true),
                            ),
                          ),
                        ),
                        BottomNavBar(
                          currentIndex: _currentIndex,
                          onTap: _onNavBarTap,
                        ),
                      ],
                    ),
                  ),
                  if (_showNowPlaying)
                    RepaintBoundary(
                      child: Consumer<PlayerProvider>(
                        builder: (context, playerProvider, _) => NowPlayingPage(
                          playerState: playerProvider.state,
                          onClose: () => setState(() => _showNowPlaying = false),
                          onPlayPause: playerProvider.togglePlayPause,
                          onPrevious: playerProvider.playPrevious,
                          onNext: playerProvider.playNext,
                          onShuffle: playerProvider.toggleShuffle,
                          onRepeat: playerProvider.toggleRepeat,
                          onTogglePlayMode: playerProvider.togglePlayMode,
                          onSeek: playerProvider.seekTo,
                          remainingSleepTime: playerProvider.remainingSleepTime,
                          onSetSleepTimer: playerProvider.setSleepTimer,
                          onCancelSleepTimer: playerProvider.cancelSleepTimer,
                          lyric: playerProvider.currentLyric,
                          currentLyricIndex: playerProvider.getCurrentLyricIndex(),
                          isFavorite: playerProvider.state.currentSong != null ? playerProvider.isFavorite(playerProvider.state.currentSong!.id) : false,
                          onToggleFavorite: () {
                            if (playerProvider.state.currentSong != null) {
                              playerProvider.toggleFavorite(playerProvider.state.currentSong!);
                            }
                          },
                          lyricFontSize: playerProvider.lyricFontSize,
                          onSetLyricFontSize: playerProvider.setLyricFontSize,
                          onPlaySongAt: (index) => playerProvider.playSong(
                            playerProvider.playlist[index],
                            playerProvider.playlist,
                            index,
                          ),
                          positionProgress: playerProvider.positionProgress,
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, _) {
        switch (_currentIndex) {
          case 0:
            return LibraryPage(
              songs: _localSongs,
              onSongTap: (song) => _playSongFromLibrary(song, playerProvider),
              onSongsUpdated: (songs) {
                setState(() {
                  _localSongs.clear();
                  _localSongs.addAll(songs);
                });
              },
              playlists: _playlists,
              onAddSongToPlaylist: _addSongToPlaylist,
            );
          case 1:
            return ArtistsPage(
              allSongs: _localSongs,
              onSongTap: (song) => _playSongFromLibrary(song, playerProvider),
              isFavorite: playerProvider.isFavorite,
              onToggleFavorite: (songId) => playerProvider.toggleFavorite(_localSongs.firstWhere((s) => s.id == songId)),
            );
          case 2:
            return AlbumsPage(
              allSongs: _localSongs,
              onSongTap: (song) => _playSongFromLibrary(song, playerProvider),
              isFavorite: playerProvider.isFavorite,
              onToggleFavorite: (songId) => playerProvider.toggleFavorite(_localSongs.firstWhere((s) => s.id == songId)),
            );
          case 3:
            return PlaylistsPage(
              allSongs: _localSongs,
              onSongTap: (song) => _playSongFromLibrary(song, playerProvider),
              isFavorite: playerProvider.isFavorite,
              onToggleFavorite: (songId) => playerProvider.toggleFavorite(_localSongs.firstWhere((s) => s.id == songId)),
              playlists: _playlists,
              onPlaylistsUpdated: _updatePlaylists,
              onEditPlaylist: _editPlaylist,
              onDeletePlaylist: _deletePlaylist,
            );
          case 4:
            return SettingsPage(
              allSongs: _localSongs,
              onSongTap: (song) => _playSongFromHistory(song, playerProvider),
            );
          default:
            return LibraryPage(
              songs: _localSongs,
              onSongTap: (song) => _playSongFromLibrary(song, playerProvider),
              onSongsUpdated: (songs) {
                setState(() {
                  _localSongs.clear();
                  _localSongs.addAll(songs);
                });
              },
            );
        }
      },
    );
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

  // 添加歌曲到歌单
  void _addSongToPlaylist(String songId, String playlistId) {
    setState(() {
      final playlistIndex = _playlists.indexWhere((p) => p.id == playlistId);
      if (playlistIndex >= 0) {
        final playlist = _playlists[playlistIndex];
        if (!playlist.songIds.contains(songId)) {
          // 添加歌曲ID到歌单
          _playlists[playlistIndex] = playlist.copyWith(
            songIds: [...playlist.songIds, songId],
            updatedAt: DateTime.now(),
          );
        }
      }
    });
  }

  // 更新歌单列表
  void _updatePlaylists(List<Playlist> playlists) {
    setState(() {
      _playlists = playlists;
    });
  }

  // 编辑歌单
  void _editPlaylist(Playlist updatedPlaylist) {
    setState(() {
      final index = _playlists.indexWhere((p) => p.id == updatedPlaylist.id);
      if (index >= 0) {
        _playlists[index] = updatedPlaylist;
      }
    });
  }

  // 删除歌单
  void _deletePlaylist(String playlistId) {
    setState(() {
      _playlists.removeWhere((p) => p.id == playlistId);
    });
  }
}