import 'package:flutter/material.dart';

class EqualizerPage extends StatefulWidget {
  const EqualizerPage({super.key});

  @override
  State<EqualizerPage> createState() => _EqualizerPageState();
}

class _EqualizerPageState extends State<EqualizerPage> {
  // 预设均衡器
  final List<String> _presets = [
    '流行',
    '摇滚',
    '古典',
    '爵士',
    '电子',
    '自定义',
  ];
  
  String _selectedPreset = '流行';
  
  // 均衡器频段值（10个频段）
  final List<double> _frequencies = [
    32, 64, 125, 250, 500, 1000, 2000, 4000, 8000, 16000
  ];
  
  // 当前各频段的增益值（-12 到 +12）
  final List<double> _bandValues = List.filled(10, 0.0);
  
  // 预设配置
  final Map<String, List<double>> _presetConfigs = {
    '流行': [0, 0, 0, -2, -4, -4, -2, 0, 0, 0],
    '摇滚': [5, 4, 3, 0, -2, -2, 0, 2, 4, 5],
    '古典': [4, 3, 2, 0, 0, 0, 0, 2, 3, 4],
    '爵士': [2, 2, 0, 0, -2, -2, 0, 2, 3, 4],
    '电子': [4, 4, 2, 0, -2, -2, 0, 2, 4, 4],
    '自定义': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  };

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
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPresetSelector(),
            const SizedBox(height: 24),
            _buildEqualizerSliders(),
            const SizedBox(height: 24),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '预设',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((preset) {
              final isSelected = _selectedPreset == preset;
              return GestureDetector(
                onTap: () => _selectPreset(preset),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF007AFF) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    preset,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : const Color(0xFF333333),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEqualizerSliders() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // 频段标签
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _frequencies.map((freq) {
                return SizedBox(
                  width: 30,
                  child: Text(
                    _formatFrequency(freq),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF999999),
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // 均衡器滑块
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(10, (index) {
                  return _buildBandSlider(index);
                }),
              ),
            ),
            const SizedBox(height: 8),
            // dB 标签
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('+12dB', style: TextStyle(fontSize: 10, color: Color(0xFF999999))),
                const Text('0dB', style: TextStyle(fontSize: 10, color: Color(0xFF999999))),
                const Text('-12dB', style: TextStyle(fontSize: 10, color: Color(0xFF999999))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBandSlider(int index) {
    return Column(
      children: [
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                activeTrackColor: const Color(0xFF007AFF),
                inactiveTrackColor: const Color(0xFFE0E0E0),
                thumbColor: const Color(0xFF007AFF),
                overlayColor: const Color(0x1A007AFF),
              ),
              child: Slider(
                value: _bandValues[index],
                min: -12,
                max: 12,
                divisions: 24,
                onChanged: (value) {
                  setState(() {
                    _bandValues[index] = value;
                    if (_selectedPreset != '自定义') {
                      _selectedPreset = '自定义';
                    }
                  });
                },
              ),
            ),
          ),
        ),
        Text(
          '${_bandValues[index].toInt()}',
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _resetEqualizer,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF8E8E93)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                '重置',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveEqualizer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                '保存',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFrequency(double freq) {
    if (freq >= 1000) {
      return '${(freq / 1000).toStringAsFixed(0)}k';
    }
    return freq.toStringAsFixed(0);
  }

  void _selectPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      _bandValues.setAll(0, _presetConfigs[preset]!);
    });
  }

  void _resetEqualizer() {
    setState(() {
      _selectedPreset = '流行';
      _bandValues.setAll(0, _presetConfigs['流行']!);
    });
  }

  void _saveEqualizer() {
    // Mock: 保存均衡器设置
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已保存均衡器设置: $_selectedPreset'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}