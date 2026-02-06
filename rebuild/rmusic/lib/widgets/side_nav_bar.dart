import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 桌面端左侧导航栏
class SideNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SideNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildNavItem(
            icon: Icons.music_note,
            label: '乐库',
            index: 0,
            isActive: currentIndex == 0,
          ),
          const SizedBox(height: 8),
          _buildNavItem(
            icon: Icons.person,
            label: '艺术家',
            index: 1,
            isActive: currentIndex == 1,
          ),
          const SizedBox(height: 8),
          _buildNavItem(
            icon: Icons.album,
            label: '专辑',
            index: 2,
            isActive: currentIndex == 2,
          ),
          const SizedBox(height: 8),
          _buildNavItem(
            icon: Icons.library_music,
            label: '歌单',
            index: 3,
            isActive: currentIndex == 3,
          ),
          const SizedBox(height: 8),
          _buildNavItem(
            icon: Icons.settings,
            label: '设置',
            index: 4,
            isActive: currentIndex == 4,
          ),
          const Spacer(),
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
    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.backgroundSecondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}