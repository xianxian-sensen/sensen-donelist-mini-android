import 'package:intl/intl.dart';

/// 今天的日期 key（YYYY-MM-DD）
String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

/// 格式化日期为完整中文（例如：2026年7月12日 星期六）
String formatFullDate(String dateKey) {
  final d = DateTime.tryParse(dateKey);
  if (d == null) return dateKey;
  const weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  return '${d.year}年${d.month}月${d.day}日 ${weekdays[d.weekday - 1]}';
}

/// 月份标签（例如：2026年7月）
String monthLabel(int year, int month) => '$year年$month月';

/// 星期标签（周一到周日）
List<String> weekdayLabels() => const ['一', '二', '三', '四', '五', '六', '日'];

/// 相对日期文案
String relativeDayLabel(String dateKey) {
  final today = todayKey();
  final yesterday = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(const Duration(days: 1)));
  if (dateKey == today) return '今天';
  if (dateKey == yesterday) return '昨天';
  return formatFullDate(dateKey);
}

/// 日历单元格
class CalendarCell {
  final DateTime date;
  final String key; // YYYY-MM-DD
  final bool inMonth;
  final bool isToday;
  CalendarCell(this.date, this.key, this.inMonth, this.isToday);
}

/// 构建月度网格：6 行 × 7 列 = 42 个 cell
List<List<CalendarCell>> buildMonthGrid(int year, int month, DateTime today) {
  final firstOfMonth = DateTime(year, month, 1);
  // 周一为一周第一天
  int offset = firstOfMonth.weekday - 1;
  final start = firstOfMonth.subtract(Duration(days: offset));

  final todayKey = DateFormat('yyyy-MM-dd').format(today);
  final result = <List<CalendarCell>>[];
  for (int r = 0; r < 6; r++) {
    final row = <CalendarCell>[];
    for (int c = 0; c < 7; c++) {
      final date = start.add(Duration(days: r * 7 + c));
      final key = DateFormat('yyyy-MM-dd').format(date);
      row.add(CalendarCell(
        date,
        key,
        date.month == month && date.year == year,
        key == todayKey,
      ));
    }
    result.add(row);
  }
  return result;
}

/// 计算连续记录天数（从今天往前数）
int computeStreak(List<String> datesWithRecords) {
  if (datesWithRecords.isEmpty) return 0;
  final set = datesWithRecords.toSet();
  int streak = 0;
  var cursor = DateTime.now();
  // 如果今天没记录，从昨天开始也算（保持与网页版一致的宽松规则）
  while (true) {
    final key = DateFormat('yyyy-MM-dd').format(cursor);
    if (set.contains(key)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    } else {
      if (streak == 0) {
        // 允许今天没有记录，从昨天开始
        cursor = cursor.subtract(const Duration(days: 1));
        final yKey = DateFormat('yyyy-MM-dd').format(cursor);
        if (set.contains(yKey)) {
          streak++;
          cursor = cursor.subtract(const Duration(days: 1));
          continue;
        }
      }
      break;
    }
  }
  return streak;
}
