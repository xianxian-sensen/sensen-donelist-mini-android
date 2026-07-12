import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 空状态占位（对应 React 版的 EmptyState）
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.paperWarm.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.paperEdge.withValues(alpha: 0.4),
            style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: AppColors.amber),
          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkSoft)),
          const SizedBox(height: 4),
          Text(description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.inkMute)),
        ],
      ),
    );
  }
}
