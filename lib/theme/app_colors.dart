import 'package:flutter/material.dart';

/// DoneList 色彩与字体常量
/// 对齐 React 版的暖米白纸张 / 深墨绿 / 琥珀金设计系统
class AppColors {
  // 纸张色 - 暖米白系列
  static const paper = Color(0xFFF5F1E8);
  static const paperWarm = Color(0xFFEFE9DA);
  static const paperCard = Color(0xFFE8DFC8);
  static const paperEdge = Color(0xFFD9CFB5);

  // 墨色 - 文字
  static const ink = Color(0xFF1A1A1A);
  static const inkSoft = Color(0xFF3D3D3D);
  static const inkMute = Color(0xFF6B6B6B);

  // 深墨绿 - 主色
  static const moss = Color(0xFF1F3A2E);
  static const mossSoft = Color(0xFF2E5443);
  static const mossDeep = Color(0xFF14271E);

  // 琥珀金 - 强调色
  static const amber = Color(0xFFC9A961);
  static const amberSoft = Color(0xFFD9BE83);
  static const amberDeep = Color(0xFFA8893E);

  // 黏土红 - 危险色
  static const clay = Color(0xFFB85042);
  static const claySoft = Color(0xFFC76A5C);

  // 半透明辅助
  static Color paperEdgeSoft = const Color(0xFFD9CFB5).withValues(alpha: 0.4);
  static Color mossOverlay = const Color(0xFF14271E).withValues(alpha: 0.4);
  static Color amberTint = const Color(0xFFC9A961).withValues(alpha: 0.12);
  static Color amberTintSoft = const Color(0xFFC9A961).withValues(alpha: 0.08);
}

/// 显示字体（用于标题，对应 React 版的 Fraunces 衬线字体）
const String kDisplayFont = 'serif';

/// 正文字体（对应 React 版的 Noto Sans SC）
const String kBodyFont = 'Roboto';
