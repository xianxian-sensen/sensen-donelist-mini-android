import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/app_store.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart';
import '../widgets/section_title.dart';
import '../widgets/empty_state.dart';

/// 记录页：单一输入框 + 今日记录列表
class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final v = _controller.text.trim().isNotEmpty;
      if (v != _canSubmit) setState(() => _canSubmit = v);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await context.read<AppStore>().addRecord(text);
    _controller.clear();
    setState(() => _canSubmit = false);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final today = todayKey();
    final todayRecords = store.records
        .where((r) => r.date == today)
        .toList();
    final total = store.records.length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          SectionTitle(
            eyebrow: formatFullDate(today),
            title: '今日完成',
            subtitle: '不必再为待办焦虑——把已经做到的事写下来，让今日有迹可循。',
          ),
          const SizedBox(height: 16),
          // 今日统计
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 14, color: AppColors.amberDeep),
              const SizedBox(width: 6),
              Text('今日 ', style: _statStyle),
              Text('${todayRecords.length}',
                  style: _statStyle.copyWith(
                      color: AppColors.moss, fontWeight: FontWeight.w600)),
              Text(' 件', style: _statStyle),
              Container(
                  width: 1,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: AppColors.paperEdge),
              Text('累计 ', style: _statStyle),
              Text('$total',
                  style: _statStyle.copyWith(
                      color: AppColors.moss, fontWeight: FontWeight.w600)),
              Text(' 件成就', style: _statStyle),
            ],
          ),
          const SizedBox(height: 24),
          // 输入框
          _RecordInput(
            controller: _controller,
            focusNode: _focusNode,
            canSubmit: _canSubmit,
            onSubmit: _submit,
          ),
          const SizedBox(height: 28),
          // 今日成就列表标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('今日成就',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      color: AppColors.inkMute)),
              if (todayRecords.isNotEmpty)
                Text('共 ${todayRecords.length} 件',
                    style: TextStyle(fontSize: 12, color: AppColors.inkMute)),
            ],
          ),
          const SizedBox(height: 12),
          if (todayRecords.isEmpty)
            const EmptyState(
              icon: Icons.auto_awesome,
              title: '今天还没有记录',
              description: '写下第一件你已完成的事，开启今日的小成就。',
            )
          else
            Column(
              children: List.generate(todayRecords.length, (i) {
                final r = todayRecords[i];
                return _RecordItem(
                  content: r.content,
                  timeLabel: _formatTime(r.createdAt),
                  onDelete: () => store.removeRecord(r.id),
                );
              }),
            ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

const TextStyle _statStyle =
    TextStyle(fontSize: 13, color: AppColors.inkMute);

class _RecordInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSubmit;
  final VoidCallback onSubmit;

  const _RecordInput({
    required this.controller,
    required this.focusNode,
    required this.canSubmit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paperWarm,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.paperEdge),
        boxShadow: [
          BoxShadow(
            color: AppColors.mossDeep.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.edit_note, color: AppColors.moss, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              maxLines: null,
              style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.ink,
                  height: 1.5),
              decoration: InputDecoration(
                hintText: '写下一件今天完成的事…',
                hintStyle: TextStyle(color: AppColors.inkMute),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: canSubmit ? onSubmit : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: canSubmit ? AppColors.moss : AppColors.paperCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add,
                      size: 15,
                      color: canSubmit ? AppColors.paper : AppColors.inkMute),
                  const SizedBox(width: 4),
                  Text(
                    '记录',
                    style: TextStyle(
                      fontSize: 13,
                      color: canSubmit ? AppColors.paper : AppColors.inkMute,
                      fontWeight: FontWeight.w500,
                    ),
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

class _RecordItem extends StatelessWidget {
  final String content;
  final String timeLabel;
  final VoidCallback onDelete;

  const _RecordItem({
    required this.content,
    required this.timeLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.paperWarm,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.paperEdge.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.mossDeep.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration:
                const BoxDecoration(color: AppColors.amber, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.ink,
                      height: 1.55),
                ),
                if (timeLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(timeLabel,
                      style: TextStyle(
                          fontSize: 11, color: AppColors.inkMute)),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.close, size: 14, color: AppColors.inkMute),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            splashRadius: 16,
          ),
        ],
      ),
    );
  }
}
