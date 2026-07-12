import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 区块标题（对应 React 版的 SectionTitle）
class SectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const SectionTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow,
            style: TextStyle(
                fontSize: 11,
                letterSpacing: 2,
                color: AppColors.amberDeep,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(title,
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.moss,
                fontFamily: kDisplayFont,
                height: 1.2)),
        const SizedBox(height: 8),
        Text(subtitle,
            style: TextStyle(
                fontSize: 13,
                color: AppColors.inkMute,
                height: 1.6)),
      ],
    );
  }
}
