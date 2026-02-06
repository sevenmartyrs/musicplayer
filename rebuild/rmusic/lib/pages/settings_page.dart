import 'package:flutter/material.dart';
import '../models/song.dart';
import 'history_page.dart';
import 'equalizer_page.dart';
import 'jellyfin_page.dart';

class SettingsPage extends StatefulWidget {
  final List<Song>? allSongs;
  final Function(Song)? onSongTap;

  const SettingsPage({
    super.key,
    this.allSongs,
    this.onSongTap,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoUpdateLibrary = true;
  bool _highQualityAudio = false;

  @override
  Widget build(BuildContext context) {
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryPage(
                            allSongs: widget.allSongs,
                            onSongTap: widget.onSongTap,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildSectionHeader('乐库'),
                  _buildNavigationItem(
                    title: '音乐库',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JellyfinPage(),
                        ),
                      );
                    },
                  ),
                  _buildSettingItem(
                    title: '扫描',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('扫描功能暂不可用')),
                      );
                    },
                  ),
                  _buildSwitchItem(
                    title: '自动更新乐库',
                    value: _autoUpdateLibrary,
                    onChanged: (value) {
                      setState(() {
                        _autoUpdateLibrary = value;
                      });
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