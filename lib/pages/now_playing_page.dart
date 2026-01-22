import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/player_state.dart';
import '../models/lyric.dart';

class NowPlayingPage extends StatefulWidget {
  final PlayerState playerState;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final ValueChanged<double> onSeek;
  final Duration? remainingSleepTime;
  final Function(Duration) onSetSleepTimer;
  final VoidCallback onCancelSleepTimer;
  final Lyric? lyric;
  final int currentLyricIndex;

  const NowPlayingPage({
    super.key,
    required this.playerState,
    required this.onClose,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onShuffle,
    required this.onRepeat,
    required this.onSeek,
    this.remainingSleepTime,
    required this.onSetSleepTimer,
    required this.onCancelSleepTimer,
    this.lyric,
    this.currentLyricIndex = -1,
  });

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  Timer? _timer;
  final ScrollController _lyricScrollController = ScrollController();
  bool _showLyric = false;

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildAlbumCover(),
              const SizedBox(height: 32),
              _buildSongInfo(),
              const SizedBox(height: 16),
              _buildLyricToggle(),
              if (_showLyric) _buildLyricView(),
              const SizedBox(height: 16),
              _buildProgressBar(context),
              const SizedBox(height: 32),
              _buildControls(),
              const SizedBox(height: 32),
              _buildSleepTimer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 24),
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
                    ? const Color(0xFFFF8C00)
                    : const Color(0xFF999999),
                letterSpacing: 2,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              widget.remainingSleepTime != null ? Icons.timer : Icons.more_vert,
              size: 24,
            ),
            color: widget.remainingSleepTime != null
                ? const Color(0xFFFF8C00)
                : const Color(0xFF8E8E93),
            onPressed: () {
              if (widget.remainingSleepTime != null) {
                _showSleepTimerDialog();
              } else {
                _showSleepTimerDialog();
              }
            },
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
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildAlbumCover() {
    final song = widget.playerState.currentSong!;
    
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
      child: _buildCoverImage(song),
    );
  }

  Widget _buildCoverImage(dynamic song) {
    // 检查是否有专辑封面
    if (song.coverUrl != null && song.coverUrl!.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(song.coverUrl!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // 加载失败显示默认图标
              return const Icon(
                Icons.music_note,
                color: Color(0xFF888888),
                size: 80,
              );
            },
          ),
        );
      } catch (e) {
        // 文件不存在或加载失败，显示默认图标
        return const Icon(
          Icons.music_note,
          color: Color(0xFF888888),
          size: 80,
        );
      }
    }
    
    // 没有封面，显示默认图标
    return const Icon(
      Icons.music_note,
      color: Color(0xFF888888),
      size: 80,
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
              fontSize: 28,
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

  Widget _buildProgressBar(BuildContext context) {
    final song = widget.playerState.currentSong!;
    final progress = widget.playerState.currentPosition / song.duration;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
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
                Text(
                  song.formattedDuration,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlButton(
            icon: Icons.shuffle,
            onPressed: widget.onShuffle,
            isActive: widget.playerState.playMode == PlayMode.shuffle,
          ),
          _buildControlButton(
            icon: Icons.skip_previous,
            onPressed: widget.onPrevious,
            size: 40,
          ),
          _buildPlayPauseButton(),
          _buildControlButton(
            icon: Icons.skip_next,
            onPressed: widget.onNext,
            size: 40,
          ),
          _buildControlButton(
            icon: Icons.repeat,
            onPressed: widget.onRepeat,
            isActive: widget.playerState.playMode == PlayMode.repeat,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 32,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF8C00) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: size * 0.75,
          color: isActive ? Colors.white : const Color(0xFFFF8C00),
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
          color: Colors.black,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          widget.playerState.isPlaying ? Icons.pause : Icons.play_arrow,
          color: const Color(0xFFFF8C00),
          size: 32,
        ),
      ),
    );
  }
  
  Widget _buildLyricToggle() {
    return TextButton.icon(
      onPressed: () {
        setState(() {
          _showLyric = !_showLyric;
        });
      },
      icon: Icon(
        _showLyric ? Icons.expand_less : Icons.expand_more,
        color: const Color(0xFF007AFF),
        size: 20,
      ),
      label: Text(
        _showLyric ? '隐藏歌词' : '显示歌词',
        style: const TextStyle(
          color: Color(0xFF007AFF),
          fontSize: 14,
        ),
      ),
    );
  }
  
  Widget _buildLyricView() {
    if (widget.lyric == null || widget.lyric!.lines.isEmpty) {
      return Container(
        height: 200,
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
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        controller: _lyricScrollController,
        itemCount: widget.lyric!.lines.length,
        itemBuilder: (context, index) {
          final line = widget.lyric!.lines[index];
          final isCurrentLine = index == widget.currentLyricIndex;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              line.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isCurrentLine ? 18 : 14,
                color: isCurrentLine ? const Color(0xFF007AFF) : const Color(0xFF666666),
                fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSleepTimer() {
    if (widget.remainingSleepTime == null) {
      return const SizedBox.shrink();
    }
    
    final remaining = widget.remainingSleepTime!;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFF8C00),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer,
            color: Color(0xFFFF8C00),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '睡眠定时器: ${minutes}分${seconds}秒后停止',
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: const Color(0xFFFF8C00),
            onPressed: widget.onCancelSleepTimer,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}