import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/player_state.dart';
import '../models/lyric.dart';
import '../providers/player_provider.dart';

class NowPlayingPage extends StatefulWidget {
  final PlayerState playerState;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final VoidCallback onTogglePlayMode;
  final ValueChanged<double> onSeek;
  final Duration? remainingSleepTime;
  final Function(Duration) onSetSleepTimer;
  final VoidCallback onCancelSleepTimer;
  final Lyric? lyric;
  final int currentLyricIndex;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final double lyricFontSize;
  final Function(double) onSetLyricFontSize;
  final Function(int) onPlaySongAt;
  final ValueListenable<double> positionProgress; // 新增：进度监听器

  const NowPlayingPage({
    super.key,
    required this.playerState,
    required this.onClose,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onShuffle,
    required this.onRepeat,
    required this.onTogglePlayMode,
    required this.onSeek,
    this.remainingSleepTime,
    required this.onSetSleepTimer,
    required this.onCancelSleepTimer,
    this.lyric,
    this.currentLyricIndex = -1,
    this.isFavorite = false,
    required this.onToggleFavorite,
    this.lyricFontSize = 16.0,
    required this.onSetLyricFontSize,
    required this.onPlaySongAt,
    required this.positionProgress, // 新增必需参数
  });

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  Timer? _timer;
  final ScrollController _lyricScrollController = ScrollController();
  bool _isFullScreenLyric = false;
  int? _selectedLyricIndex; // 用户点击选中的歌词行索引

  @override
  void initState() {
    super.initState();
    if (widget.remainingSleepTime != null) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(NowPlayingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.remainingSleepTime != null && oldWidget.remainingSleepTime == null) {
      _startTimer();
    } else if (widget.remainingSleepTime == null && oldWidget.remainingSleepTime != null) {
      _timer?.cancel();
    }
    
    // 歌词滚动
    if (widget.currentLyricIndex != oldWidget.currentLyricIndex && 
        widget.currentLyricIndex >= 0) {
      _scrollToCurrentLyric();
    }
  }
  
  void _scrollToCurrentLyric() {
    if (_lyricScrollController.hasClients && widget.lyric != null) {
      final itemHeight = 40.0; // 每行歌词的高度
      final targetOffset = widget.currentLyricIndex * itemHeight - 80; // 向上偏移80像素
      _lyricScrollController.animateTo(
        targetOffset.clamp(0.0, _lyricScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.playerState.currentSong == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('No song playing'),
        ),
      );
    }

    // 全屏歌词模式
    if (_isFullScreenLyric) {
      return _buildFullScreenLyric();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 判断是否为桌面端（宽度大于 600）
            final isDesktop = constraints.maxWidth > 600;
            
            return isDesktop
            ? Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _buildDesktopLayout(),
                  ),
                ],
              )
            : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildMobileLayout(),
                  const SizedBox(height: 16),
                  _buildProgressBar(context),
                  const SizedBox(height: 32),
                  _buildControls(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 桌面端布局：左边歌曲信息、专辑图、进度条、播放控件，右边歌词
  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左边：歌曲信息、专辑图、进度条、播放控件
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                _buildSongInfo(),
                const SizedBox(height: 20),
                _buildAlbumCover(),
                const SizedBox(height: 20),
                _buildProgressBar(context, showMenuButton: false),
                const SizedBox(height: 12),
                _buildControls(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(width: 48),
          // 右边：歌词（禁用全屏）
          Expanded(
            flex: 1,
            child: _buildLyricView(height: 600, enableFullScreen: false),
          ),
        ],
      ),
    );
  }

  // 移动端布局：原有布局
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildAlbumCover(),
        const SizedBox(height: 32),
        _buildSongInfo(),
        const SizedBox(height: 16),
        _buildLyricView(height: 120, enableFullScreen: true),
      ],
    );
  }

  Widget _buildHeader() {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 24),
            color: const Color(0xFF8E8E93),
            onPressed: widget.onClose,
          ),
          Expanded(
            child: Text(
              widget.remainingSleepTime != null
                  ? _formatDuration(widget.remainingSleepTime!)
                  : 'NOW PLAYING',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: widget.remainingSleepTime != null
                    ? const Color(0xFF007AFF)
                    : const Color(0xFF999999),
                letterSpacing: 2,
              ),
            ),
          ),
          if (isDesktop)
            GestureDetector(
              onTap: _showPlayerMenu,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.more_horiz,
                  color: Color(0xFF8E8E93),
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPlayerMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuSection(
                  title: '睡眠定时器',
                  children: _buildSleepTimerOptions(),
                ),
                const Divider(height: 1),
                _buildMenuSection(
                  title: '歌词字体大小',
                  children: _buildLyricFontSizeOptions(),
                ),
                const Divider(height: 1),
                _buildMenuSection(
                  title: '更多功能',
                  children: [
                    _buildMenuOption(
                      icon: Icons.playlist_add,
                      title: '加歌单',
                      onTap: () {
                        Navigator.pop(context);
                        _showAddToPlaylistDialog();
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.equalizer,
                      title: '音效',
                      onTap: () {
                        Navigator.pop(context);
                        _showEqualizerPage();
                      },
                    ),
                    _buildMenuOption(
                      icon: Icons.speed,
                      title: '倍速播放',
                      onTap: () {
                        Navigator.pop(context);
                        _showPlaybackSpeedDialog();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF333333)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF007AFF),
                ),
              ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF8E8E93)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSleepTimerOptions() {
    return [
      _buildMenuOption(
        icon: Icons.timer_outlined,
        title: '睡眠定时器',
        subtitle: widget.remainingSleepTime != null
            ? _formatDuration(widget.remainingSleepTime!)
            : '关闭',
        onTap: () {
          Navigator.pop(context);
          _showSleepTimerDialog();
        },
      ),
    ];
  }

  List<Widget> _buildLyricFontSizeOptions() {
    return [
      Consumer<PlayerProvider>(
        builder: (context, playerProvider, _) {
          return Row(
            children: [
              const Text(
                '歌词字体大小',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove, size: 20, color: Color(0xFF333333)),
                onPressed: () => widget.onSetLyricFontSize(playerProvider.lyricFontSize - 2),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${playerProvider.lyricFontSize.toInt()}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20, color: Color(0xFF333333)),
                onPressed: () => widget.onSetLyricFontSize(playerProvider.lyricFontSize + 2),
              ),
            ],
          );
        },
      ),
    ];
  }

  void _showAddToPlaylistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加到歌单'),
        content: const Text('歌单功能即将推出'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showEqualizerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('音效'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: const Center(
            child: Text('音效页面即将推出'),
          ),
        ),
      ),
    );
  }

  void _showPlaybackSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('倍速播放'),
        content: const Text('倍速播放功能即将推出'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSleepTimerDialog() {
    if (widget.remainingSleepTime != null) {
      // 已设置定时器，显示取消选项
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('睡眠定时器'),
          content: Text('剩余时间: ${_formatDuration(widget.remainingSleepTime!)}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onCancelSleepTimer();
              },
              child: const Text('取消定时器', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      // 未设置定时器，显示设置选项
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('设置睡眠定时器'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimerOption('15分钟', const Duration(minutes: 15)),
              _buildTimerOption('30分钟', const Duration(minutes: 30)),
              _buildTimerOption('45分钟', const Duration(minutes: 45)),
              _buildTimerOption('60分钟', const Duration(minutes: 60)),
              _buildTimerOption('90分钟', const Duration(minutes: 90)),
              _buildTimerOption('120分钟', const Duration(minutes: 120)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTimerOption(String label, Duration duration) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        widget.onSetSleepTimer(duration);
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildAlbumCover() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFE0E0E0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.music_note,
        color: Color(0xFF888888),
        size: 70,
      ),
    );
  }

  Widget _buildSongInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            widget.playerState.currentSong!.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.playerState.currentSong!.artist,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF007AFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, {bool showMenuButton = true}) {
    final song = widget.playerState.currentSong!;
    
    // 使用 ValueListenableBuilder 只更新进度条部分，避免整个页面重建
    return ValueListenableBuilder<double>(
      valueListenable: widget.positionProgress,
      builder: (context, progress, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.playerState.formattedPosition,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onToggleFavorite,
                          child: Icon(
                            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: widget.isFavorite ? Colors.red : const Color(0xFF8E8E93),
                            size: 20,
                          ),
                        ),
                        if (showMenuButton) ...[
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _showPlayerMenu,
                            child: const Icon(
                              Icons.more_horiz,
                              color: Color(0xFF8E8E93),
                              size: 20,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          song.formattedDuration,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: const Color(0xFF000000),
                  inactiveTrackColor: const Color(0xFFE0E0E0),
                  thumbColor: Colors.white,
                  overlayColor: const Color(0x1A000000),
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChanged: widget.onSeek,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPlayModeButton(),
          _buildControlButton(
            icon: Icons.skip_previous,
            onPressed: widget.onPrevious,
            size: 44,
          ),
          _buildPlayPauseButton(),
          _buildControlButton(
            icon: Icons.skip_next,
            onPressed: widget.onNext,
            size: 44,
          ),
          _buildPlaylistButton(),
        ],
      ),
    );
  }

  Widget _buildPlayModeButton() {
    IconData icon;
    switch (widget.playerState.playMode) {
      case PlayMode.sequence:
        icon = Icons.format_list_numbered;
        break;
      case PlayMode.shuffle:
        icon = Icons.shuffle;
        break;
      case PlayMode.repeat:
        icon = Icons.repeat_one;
        break;
    }

    return GestureDetector(
      onTap: widget.onTogglePlayMode,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          icon,
          color: const Color(0xFF333333),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildPlaylistButton() {
    return GestureDetector(
      onTap: _showPlaylistDialog,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          Icons.queue_music,
          color: const Color(0xFF8E8E93),
          size: 22,
        ),
      ),
    );
  }

  void _showPlaylistDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '播放列表',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              ),
              // 播放列表
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    itemCount: widget.playerState.playlist.length,
                    itemBuilder: (context, index) {
                      final song = widget.playerState.playlist[index];
                      final isCurrentSong = widget.playerState.currentIndex == index;
                      
                      return ListTile(
                        leading: isCurrentSong
                            ? const Icon(Icons.play_circle_filled, color: Color(0xFF007AFF))
                            : const Icon(Icons.play_circle_outline, color: Color(0xFF8E8E93)),
                        title: Text(
                          song.title,
                          style: TextStyle(
                            color: isCurrentSong ? const Color(0xFF007AFF) : const Color(0xFF333333),
                            fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          song.artist,
                          style: const TextStyle(
                            color: Color(0xFF999999),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onPlaySongAt(index);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 36,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF333333) : Colors.transparent,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(
          icon,
          size: size * 0.6,
          color: isActive ? Colors.white : const Color(0xFF8E8E93),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return GestureDetector(
      onTap: widget.onPlayPause,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          widget.playerState.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
  
  Widget _buildLyricView({required double height, bool enableFullScreen = false}) {
    if (widget.lyric == null || widget.lyric!.lines.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        child: const Text(
          '暂无歌词',
          style: TextStyle(
            color: Color(0xFF999999),
            fontSize: 16,
          ),
        ),
      );
    }
    
    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 100, right: 16),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: enableFullScreen
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _isFullScreenLyric = true;
                  });
                },
                child: ListView.builder(
                  controller: _lyricScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: widget.lyric!.lines.length,
                  itemBuilder: (context, index) {
                    return _buildLyricLine(index, enableFullScreen);
                  },
                ),
              )
            : ListView.builder(
                controller: _lyricScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: widget.lyric!.lines.length,
                itemBuilder: (context, index) {
                  return _buildLyricLine(index, false);
                },
              ),
      ),
    );
  }

  Widget _buildLyricLine(int index, bool isFullScreen) {
    final line = widget.lyric!.lines[index];
    final isCurrentLine = index == widget.currentLyricIndex;
    final isSelected = index == _selectedLyricIndex;
    
    final textColor = isCurrentLine 
        ? (isFullScreen ? Colors.white : const Color(0xFF007AFF))
        : (isFullScreen ? const Color(0xFF666666) : const Color(0xFF666666));
    
    final fontSize = isCurrentLine ? widget.lyricFontSize + 2 : widget.lyricFontSize;
    
    if (isSelected) {
      final backgroundColor = isFullScreen ? const Color(0xFF333333) : const Color(0xFFF5F5F5);
      final textColor = isFullScreen ? Colors.white : const Color(0xFF333333);
      final timeColor = isFullScreen ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);
      
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF007AFF), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                line.text,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatLyricTime(line.time),
              style: TextStyle(
                fontSize: 12,
                color: timeColor,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                _jumpToLyric(index);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLyricIndex = index;
        });
        _scrollToSelectedLyric(index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          line.text,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _formatLyricTime(int milliseconds) {
    final minutes = milliseconds ~/ 60000;
    final seconds = (milliseconds % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _scrollToSelectedLyric(int index) {
    if (_lyricScrollController.hasClients) {
      final itemHeight = widget.lyricFontSize + 16; // 字体 + padding
      final targetOffset = index * itemHeight - 80; // 向上偏移80像素
      _lyricScrollController.animateTo(
        targetOffset.clamp(0.0, _lyricScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _jumpToLyric(int index) {
    final line = widget.lyric!.lines[index];
    final targetSeconds = line.time / 1000;
    final progress = targetSeconds / widget.playerState.currentSong!.duration;
    widget.onSeek(progress);
    setState(() {
      _selectedLyricIndex = null; // 清除选中状态
    });
  }

  // 全屏歌词
  Widget _buildFullScreenLyric() {
    if (widget.lyric == null || widget.lyric!.lines.isEmpty) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Text(
          '暂无歌词',
          style: TextStyle(
            color: Color(0xFF999999),
            fontSize: 16,
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部关闭按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 24, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isFullScreenLyric = false;
                      });
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove, size: 24, color: Colors.white),
                    onPressed: () => widget.onSetLyricFontSize(widget.lyricFontSize - 2),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${widget.lyricFontSize.toInt()}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 24, color: Colors.white),
                    onPressed: () => widget.onSetLyricFontSize(widget.lyricFontSize + 2),
                  ),
                ],
              ),
            ),
            // 歌词
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 64, right: 24),
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: ListView.builder(
                    controller: _lyricScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: widget.lyric!.lines.length,
                    itemBuilder: (context, index) {
                      return _buildLyricLine(index, true);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}