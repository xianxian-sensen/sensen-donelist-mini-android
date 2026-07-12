import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../store/app_store.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart';
import '../widgets/section_title.dart';
import '../widgets/empty_state.dart';

/// 日历页：月度网格 + 当日记录列表
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late int _viewYear;
  late int _viewMonth; // 1-12
  late String _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewYear = now.year;
    _viewMonth = now.month;
    _selectedDate = todayKey();
  }

  void _goPrevMonth() {
    setState(() {
      if (_viewMonth == 1) {
        _viewMonth = 12;
        _viewYear--;
      } else {
        _viewMonth--;
      }
    });
  }

  void _goNextMonth() {
    setState(() {
      if (_viewMonth == 12) {
        _viewMonth = 1;
        _viewYear++;
      } else {
        _viewMonth++;
      }
    });
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _viewYear = now.year;
      _viewMonth = now.month;
      _selectedDate = todayKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final today = DateTime.now();
    final grid = buildMonthGrid(_viewYear, _viewMonth, today);
    final datesWithRecords = store.datesWithRecords;
    final streak = store.streak;
    final monthCount = store.monthCount(_viewYear, _viewMonth);
    final selectedRecords = store.recordsOn(_selectedDate);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          SectionTitle(
            eyebrow: '日历视图',
            title: '已完成的足迹',
            subtitle: '在日历上回望每一个被点亮的日期——它们是真实的努力。',
          ),
          const SizedBox(height: 16),
          // 统计卡片
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: '本月完成',
                  value: monthCount,
                  unit: '件',
                  icon: Icons.checklist,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: '连续记录',
                  value: streak,
                  unit: '天',
                  icon: Icons.local_fire_department,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 日历卡片
          Container(
            decoration: BoxDecoration(
              color: AppColors.paper,
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
            child: Column(
              children: [
                // 月份导航
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _goPrevMonth,
                        icon: const Icon(Icons.chevron_left,
                            size: 20, color: AppColors.inkSoft),
                      ),
                      GestureDetector(
                        onTap: _goToday,
                        child: Column(
                          children: [
                            Text(
                              monthLabel(_viewYear, _viewMonth),
                              style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: kDisplayFont,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.moss),
                            ),
                            const SizedBox(height: 2),
                            Text('回到今天',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.inkMute,
                                    decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _goNextMonth,
                        icon: const Icon(Icons.chevron_right,
                            size: 20, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                ),
                // 星期标签
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: weekdayLabels()
                        .map((w) => Expanded(
                              child: Center(
                                child: Text(w,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.inkMute)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const Divider(height: 1, color: AppColors.paperEdge),
                // 6 行 × 7 列网格
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Column(
                    children: grid.map((row) {
                      return Row(
                        children: row.map((cell) {
                          final hasRecord = datesWithRecords.contains(cell.key);
                          final isSelected = cell.key == _selectedDate;
                          return Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _selectedDate = cell.key;
                                  // 不在当月时跳转
                                  if (!cell.inMonth) {
                                    _viewYear = cell.date.year;
                                    _viewMonth = cell.date.month;
                                  }
                                }),
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.amber.withValues(alpha: 0.15)
                                        : (cell.inMonth
                                            ? AppColors.paperWarm
                                                .withValues(alpha: 0.4)
                                            : Colors.transparent),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${cell.date.day}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: cell.inMonth
                                              ? (cell.isToday
                                                  ? AppColors.amberDeep
                                                  : AppColors.ink)
                                              : AppColors.inkMute
                                                  .withValues(alpha: 0.4),
                                          fontWeight: cell.isToday
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                      if (hasRecord)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.amberDeep
                                                : AppColors.amber,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 选中日期的记录
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                relativeDayLabel(_selectedDate),
                style: TextStyle(
                    fontSize: 17,
                    fontFamily: kDisplayFont,
                    fontWeight: FontWeight.w600,
                    color: AppColors.moss),
              ),
              if (selectedRecords.isNotEmpty)
                Text('${selectedRecords.length} 件完成',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.inkMute)),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedRecords.isEmpty)
            EmptyState(
              icon: Icons.calendar_today,
              title: '这一天没有记录',
              description: formatFullDate(_selectedDate),
            )
          else
            Column(
              children: selectedRecords.map((r) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: AppColors.paperWarm,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.paperEdge.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: AppColors.amber,
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          r.content,
                          style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.ink,
                              height: 1.55),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.paperEdge),
        boxShadow: [
          BoxShadow(
            color: AppColors.mossDeep.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.amberTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: AppColors.amberDeep),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: AppColors.inkMute)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$value',
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: kDisplayFont,
                          fontWeight: FontWeight.w600,
                          color: AppColors.moss)),
                  const SizedBox(width: 4),
                  Text(unit,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.inkMute)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
