import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 可复用的搜索栏组件
class AppSearchBar extends StatelessWidget {
  final String query;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const AppSearchBar({
    super.key,
    required this.query,
    this.hintText = '搜索',
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppColors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: onChanged,
            ),
          ),
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              color: AppColors.textTertiary,
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}