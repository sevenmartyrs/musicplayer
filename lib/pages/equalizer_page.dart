import 'package:flutter/material.dart';

class EqualizerPage extends StatefulWidget {
  const EqualizerPage({super.key});

  @override
  State<EqualizerPage> createState() => _EqualizerPageState();
}

class _EqualizerPageState extends State<EqualizerPage> {
  int _selectedPreset = 0;
  
  final List<String> _presets = [
    '流行',
    '摇滚',
    '爵士',
    '古典',
    '电子',
    '人声',
    '自定义',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '均衡器',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('预设'),
          ..._presets.asMap().entries.map((entry) {
            final index = entry.key;
            final preset = entry.value;
            return _buildPresetItem(
              title: preset,
              isSelected: _selectedPreset == index,
              onTap: () {
                setState(() {
                  _selectedPreset = index;
                });
              },
            );
          }).toList(),
          _buildSectionHeader('频段调节'),
          _buildFrequencySliders(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF999999),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPresetItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFE0E0E0),
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF333333),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Color(0xFF007AFF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySliders() {
    final frequencies = ['60Hz', '230Hz', '910Hz', '3.6kHz', '14kHz'];
    final labels = ['低音', '低中音', '中音', '中高音', '高音'];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(frequencies.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildFrequencySlider(
              label: labels[index],
              frequency: frequencies[index],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFrequencySlider({
    required String label,
    required String frequency,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            Text(
              frequency,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF007AFF),
            inactiveTrackColor: const Color(0xFFE0E0E0),
            thumbColor: const Color(0xFF007AFF),
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: 0.5,
            min: 0,
            max: 1,
            divisions: 20,
            onChanged: (value) {
              // 应用均衡器设置
            },
          ),
        ),
      ],
    );
  }
}