import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 移动端底部导航栏
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildNavItem(
            icon: Icons.music_note,
            label: '乐库',
            index: 0,
            isActive: currentIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.library_music,
            label: '歌单',
            index: 1,
            isActive: currentIndex == 1,
          ),
          _buildNavItem(
            icon: Icons.settings,
            label: '设置',
            index: 2,
            isActive: currentIndex == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}