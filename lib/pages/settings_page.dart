import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';
import 'history_page.dart';
import 'equalizer_page.dart';
import '../services/music_scanner.dart';
import '../services/song_database.dart';

class SettingsPage extends StatefulWidget {
  final List<Song>? allSongs;
  final Function(Song)? onSongTap;
  final MusicScanner? scanner;
  final SongDatabase? database;
  final Function(List<Song>)? onSongsUpdated;

  const SettingsPage({
    super.key,
    this.allSongs,
    this.onSongTap,
    this.scanner,
    this.database,
    this.onSongsUpdated,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoUpdateLibrary = true;
  bool _highQualityAudio = false;
  bool _showHistory = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoUpdateLibrary = prefs.getBool('autoUpdateLibrary') ?? true;
      _highQualityAudio = prefs.getBool('highQualityAudio') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoUpdateLibrary', _autoUpdateLibrary);
    await prefs.setBool('highQualityAudio', _highQualityAudio);
  }

  Future<void> _scanMusic() async {
    if (widget.scanner == null || widget.database == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('扫描功能不可用')),
      );
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      // 请求权限
      final hasPermission = await widget.scanner!.requestPermissions();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('需要访问存储权限才能扫描音乐')),
          );
        }
        setState(() {
          _isScanning = false;
        });
        return;
      }

      // 扫描音乐
      final songs = await widget.scanner!.scanMusicFiles(forceFullScan: true);

      // 保存到数据库
      await widget.database!.saveSongs(songs);

      // 通知主应用更新
      if (widget.onSongsUpdated != null) {
        widget.onSongsUpdated!(songs);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('扫描完成，找到 ${songs.length} 首歌曲')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('扫描失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showHistory) {
      return HistoryPage(
        allSongs: widget.allSongs,
        onSongTap: widget.onSongTap,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                children: [
                  _buildNavigationItem(
                    title: '播放历史',
                    onTap: () {
                      setState(() {
                        _showHistory = true;
                      });
                    },
                  ),
                  _buildSectionHeader('乐库'),
                  _buildSettingItem(
                    title: _isScanning ? '扫描中...' : '扫描',
                    onTap: _isScanning ? null : () => _scanMusic(),
                  ),
                  _buildSwitchItem(
                    title: '自动更新乐库',
                    value: _autoUpdateLibrary,
                    onChanged: (value) {
                      setState(() {
                        _autoUpdateLibrary = value;
                      });
                      _saveSettings();
                    },
                  ),
                  _buildSectionHeader('音频'),
                  _buildNavigationItem(
                    title: '均衡器',
                    subtitle: '流行',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EqualizerPage(),
                        ),
                      );
                    },
                  ),
                  _buildSwitchItem(
                    title: '高品质音频',
                    value: _highQualityAudio,
                    onChanged: (value) {
                      setState(() {
                        _highQualityAudio = value;
                      });
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '设置',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF999999),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
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
                '$subtitle >',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF007AFF),
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF8E8E93),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4CD964),
            activeTrackColor: const Color(0xFF4CD964).withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}