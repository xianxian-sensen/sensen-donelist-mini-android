import 'package:device_calendar/device_calendar.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../models/done_record.dart';

/// 系统日历同步服务
/// 与 React 版只能导出 ICS 文件不同，
/// Flutter 原生可写入 Android 系统日历
class CalendarService {
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();
  bool _tzInitialized = false;

  /// 初始化时区数据库（device_calendar 依赖）
  void _ensureTz() {
    if (_tzInitialized) return;
    tzdata.initializeTimeZones();
    _tzInitialized = true;
  }

  /// 请求日历权限
  Future<bool> requestPermissions() async {
    final res = await _plugin.requestPermissions();
    return res.data ?? false;
  }

  /// 是否已授权
  Future<bool> hasPermissions() async {
    final res = await _plugin.hasPermissions();
    return res.data ?? false;
  }

  /// 获取可写日历，优先选本地账户
  Future<String?> _pickWritableCalendar() async {
    final res = await _plugin.retrieveCalendars();
    if (!res.isSuccess || res.data == null) return null;
    final calendars = res.data!.where((c) => c.isReadOnly == false).toList();
    if (calendars.isEmpty) return null;
    // 优先本地账户
    final local = calendars.where((c) =>
        (c.accountType ?? '').toLowerCase() == 'local' ||
        (c.accountName ?? '').toLowerCase() == 'local').toList();
    return (local.isNotEmpty ? local.first : calendars.first).id;
  }

  /// 将记录同步到系统日历
  /// 返回成功写入的数量
  Future<int> syncRecords(List<DoneRecord> records) async {
    if (records.isEmpty) return 0;
    _ensureTz();
    final hasPerm = await hasPermissions();
    if (!hasPerm) {
      final ok = await requestPermissions();
      if (!ok) return 0;
    }
    final calendarId = await _pickWritableCalendar();
    if (calendarId == null) return 0;

    int success = 0;
    for (final r in records) {
      final date = DateTime.tryParse(r.date);
      if (date == null) continue;
      // 当日 9:00-10:00 的事件
      final start = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        9,
      );
      final end = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        10,
      );
      final event = Event(calendarId)
        ..title = r.content
        ..start = start
        ..end = end
        ..description = '由 DoneList 记录'
        ..allDay = false;

      final res = await _plugin.createOrUpdateEvent(event);
      if (res?.isSuccess ?? false) success++;
    }
    return success;
  }

  /// 清除此前同步到日历的 DoneList 事件（按 description 匹配）
  Future<void> clearSyncedEvents() async {
    final hasPerm = await hasPermissions();
    if (!hasPerm) return;
    final calendarId = await _pickWritableCalendar();
    if (calendarId == null) return;

    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 365));
    final end = now.add(const Duration(days: 365));
    final res = await _plugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(startDate: start, endDate: end),
    );
    if (!res.isSuccess || res.data == null) return;

    for (final e in res.data!) {
      if (e.description == '由 DoneList 记录' && e.eventId != null) {
        await _plugin.deleteEvent(calendarId, e.eventId!);
      }
    }
  }
}

/// 生成 ICS 文本（保留作为导出选项，对应 React 版的下载 ICS）
String buildIcsContent(List<DoneRecord> records) {
  final buf = StringBuffer()
    ..writeln('BEGIN:VCALENDAR')
    ..writeln('VERSION:2.0')
    ..writeln('PRODID:-//DoneList//sensen//CN')
    ..writeln('CALSCALE:GREGORIAN');

  for (final r in records) {
    final d = DateTime.tryParse(r.date);
    if (d == null) continue;
    final dt = DateFormat('yyyyMMdd').format(d);
    final dtEnd = DateFormat('yyyyMMdd').format(d.add(const Duration(days: 1)));
    final uid = r.id;
    final escaped = r.content
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('\n', '\\n');
    buf
      ..writeln('BEGIN:VEVENT')
      ..writeln('UID:$uid@donelist.sensen')
      ..writeln('DTSTAMP:${DateFormat("yyyyMMdd'T'HHmmss'Z'").format(DateTime.now().toUtc())}')
      ..writeln('DTSTART;VALUE=DATE:$dt')
      ..writeln('DTEND;VALUE=DATE:$dtEnd')
      ..writeln('SUMMARY:$escaped')
      ..writeln('DESCRIPTION:由 DoneList 记录')
      ..writeln('END:VEVENT');
  }
  buf.writeln('END:VCALENDAR');
  return buf.toString();
}
