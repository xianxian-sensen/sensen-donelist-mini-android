import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../store/app_store.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart';

/// 设置页：同步、导出、清空
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showSyncInfo = false;

  Future<void> _confirmClear() async {
    final store = context.read<AppStore>();
    final count = store.records.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.clay, size: 22),
            const SizedBox(width: 8),
            Text('确认清空？',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: kDisplayFont,
                    fontWeight: FontWeight.w600,
                    color: AppColors.moss)),
          ],
        ),
        content: Text(
          '将永久删除全部 $count 条记录，此操作不可恢复。',
          style: TextStyle(
              fontSize: 13,
              color: AppColors.inkSoft,
              height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('取消',
                style: TextStyle(color: AppColors.inkMute)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('确认清空',
                style: TextStyle(
                    color: AppColors.clay,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await store.clearAll();
      _toast('已清空全部记录');
    }
  }

  Future<void> _exportIcs() async {
    final store = context.read<AppStore>();
    if (store.records.isEmpty) return;
    final ics = store.buildIcs();
    final fileName = 'donelist-${todayKey()}.ics';
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(ics);
      await Share.shareXFiles([XFile(file.path)],
          text: 'DoneList 记录导出');
      await store.setLastExport(todayKey());
      _toast('ICS 已导出，可保存或导入到日历应用');
    } catch (e) {
      _toast('导出失败：$e');
    }
  }

  Future<void> _exportJson() async {
    final store = context.read<AppStore>();
    if (store.records.isEmpty) return;
    final data = {
      'records': store.records.map((r) => r.toJson()).toList(),
      'settings': store.settings.toJson(),
      'exported_at': DateTime.now().toIso8601String(),
    };
    final json = JsonEncoder.withIndent('  ').convert(data);
    final fileName = 'donelist-backup-${todayKey()}.json';
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)],
          text: 'DoneList 备份');
      _toast('JSON 已导出');
    } catch (e) {
      _toast('导出失败：$e');
    }
  }

  Future<void> _syncToCalendar() async {
    final store = context.read<AppStore>();
    if (store.records.isEmpty) return;
    _toast('正在同步到系统日历…');
    final count = await store.syncToCalendar();
    _toast(count > 0
        ? '已同步 $count 条记录到系统日历'
        : '同步失败：未获得日历权限或无可用日历');
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final settings = store.settings;
    final recordCount = store.records.length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          _SettingsHeader(
              eyebrow: '设置',
              title: '偏好与数据',
              subtitle: '管理同步、备份与数据，掌握你自己的记录。'),
          const SizedBox(height: 20),
          // 同步区
          _Card(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.sync,
                                  size: 16, color: AppColors.moss),
                              const SizedBox(width: 6),
                              Text('同步到系统日历',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: kDisplayFont,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.moss)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '开启后，可一键将所有完成记录写入 Android 系统日历（需授权日历权限）。',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.inkMute,
                                height: 1.5),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => setState(
                                () => _showSyncInfo = !_showSyncInfo),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline,
                                    size: 12,
                                    color: AppColors.amberDeep),
                                const SizedBox(width: 4),
                                Text('了解同步原理',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.amberDeep,
                                        decoration:
                                            TextDecoration.underline)),
                              ],
                            ),
                          ),
                          if (_showSyncInfo) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.paperCard
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Flutter 原生应用可直接调用系统日历 API 写入事件，'
                                '同时保留 ICS 导出作为通用兼容方案。',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.inkSoft,
                                    height: 1.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: settings.calendarSyncEnabled,
                      onChanged: (v) => store.toggleSync(v),
                      activeColor: AppColors.moss,
                    ),
                  ],
                ),
                if (settings.calendarSyncEnabled) ...[
                  const Divider(
                      height: 24, color: AppColors.paperEdge),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        settings.lastExportDate != null
                            ? '上次同步：${settings.lastExportDate}'
                            : '尚未同步',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.inkSoft),
                      ),
                      _SmallButton(
                        label: '立即同步',
                        icon: Icons.sync,
                        onPressed:
                            recordCount == 0 ? null : _syncToCalendar,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 数据管理
          _Card(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.storage,
                          size: 16, color: AppColors.moss),
                      const SizedBox(width: 6),
                      Text('数据管理',
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: kDisplayFont,
                              fontWeight: FontWeight.w600,
                              color: AppColors.moss)),
                      const Spacer(),
                      Text('共 $recordCount 条记录',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.inkMute)),
                    ],
                  ),
                ),
                const Divider(color: AppColors.paperEdge),
                _DataRow(
                  label: '导出全部数据 (JSON)',
                  description: '含记录与设置，可用于备份与迁移',
                  action: _SmallButton(
                    label: '导出',
                    icon: Icons.download,
                    onPressed:
                        recordCount == 0 ? null : _exportJson,
                  ),
                ),
                _DataRow(
                  label: '导出为日历事件 (ICS)',
                  description: '分享到任意支持 ICS 的日历应用',
                  action: _SmallButton(
                    label: '导出',
                    icon: Icons.calendar_month,
                    onPressed:
                        recordCount == 0 ? null : _exportIcs,
                  ),
                ),
                _DataRow(
                  label: '清空全部记录',
                  description: '此操作不可恢复，请谨慎操作',
                  danger: true,
                  action: _SmallButton(
                    label: '清空',
                    icon: Icons.delete_outline,
                    danger: true,
                    onPressed: recordCount == 0
                        ? null
                        : _confirmClear,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 关于
          _Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('关于 DoneList',
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: kDisplayFont,
                          fontWeight: FontWeight.w600,
                          color: AppColors.moss)),
                  const SizedBox(height: 8),
                  Text(
                    'DoneList 是一款反向清单应用——它不记录你要做什么，而记录你已经做到了什么。'
                    '每一条记录，都是对自己努力的肯定。数据完全保存在本地，只属于你。',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.inkSoft,
                        height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Badge('v1.0.0'),
                      _Badge('Flutter 原生'),
                      _Badge('本地存储'),
                      _Badge('离线可用'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const _SettingsHeader({
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

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.paperEdge),
        boxShadow: [
          BoxShadow(
            color: AppColors.mossDeep.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String? description;
  final Widget action;
  final bool danger;

  const _DataRow({
    required this.label,
    this.description,
    required this.action,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: danger ? AppColors.clay : AppColors.ink)),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(description!,
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.inkMute)),
                ],
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool danger;

  const _SmallButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: danger
              ? AppColors.clay.withValues(alpha: enabled ? 1 : 0.3)
              : (enabled ? AppColors.mossSoft : AppColors.paperCard),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 12,
                color: danger
                    ? AppColors.paper
                    : (enabled ? AppColors.paper : AppColors.inkMute)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12,
                  color: danger
                      ? AppColors.paper
                      : (enabled ? AppColors.paper : AppColors.inkMute),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.paperCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 11, color: AppColors.inkMute)),
    );
  }
}
