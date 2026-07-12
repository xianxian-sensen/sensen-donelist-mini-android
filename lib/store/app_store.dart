import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/done_record.dart';
import '../services/storage_service.dart';
import '../services/calendar_service.dart';
import '../utils/date_utils.dart';

/// 应用全局状态
/// 对应 React 版的 Zustand store
class AppStore extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final CalendarService _calendar = CalendarService();
  final Uuid _uuid = const Uuid();

  List<DoneRecord> _records = [];
  AppSettings _settings = AppSettings();
  bool _initialized = false;
  String? _lastSyncMessage;

  List<DoneRecord> get records => List.unmodifiable(_records);
  AppSettings get settings => _settings;
  bool get initialized => _initialized;
  String? get lastSyncMessage => _lastSyncMessage;

  /// 初始化：加载本地数据
  Future<void> init() async {
    await _storage.init();
    _records = _storage.loadRecords();
    _settings = _storage.loadSettings();
    _initialized = true;
    notifyListeners();
  }

  // ===== 记录操作 =====

  /// 添加一条记录
  Future<void> addRecord(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now();
    final record = DoneRecord(
      id: _uuid.v4(),
      content: trimmed,
      date: todayKey(),
      createdAt: now.toIso8601String(),
    );
    _records = [record, ..._records];
    await _storage.saveRecords(_records);
    notifyListeners();
  }

  /// 删除一条记录
  Future<void> removeRecord(String id) async {
    _records = _records.where((r) => r.id != id).toList();
    await _storage.saveRecords(_records);
    notifyListeners();
  }

  /// 清空全部记录
  Future<void> clearAll() async {
    _records = [];
    await _storage.saveRecords(_records);
    notifyListeners();
  }

  // ===== 设置操作 =====

  Future<void> toggleSync(bool value) async {
    _settings = _settings.copyWith(calendarSyncEnabled: value);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setLastExport(String date) async {
    _settings = _settings.copyWith(lastExportDate: date);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // ===== 系统日历同步 =====

  /// 同步全部记录到系统日历，返回成功条数
  Future<int> syncToCalendar() async {
    if (_records.isEmpty) return 0;
    final count = await _calendar.syncRecords(_records);
    _lastSyncMessage = count > 0 ? '已同步 $count 条记录到系统日历' : '同步失败：未获得日历权限或无可用日历';
    await setLastExport(todayKey());
    return count;
  }

  /// 生成 ICS 文本（用于分享导出）
  String buildIcs() => buildIcsContent(_records);

  // ===== 派生数据 =====

  List<DoneRecord> get todayRecords =>
      _records.where((r) => r.date == todayKey()).toList();

  Set<String> get datesWithRecords =>
      _records.map((r) => r.date).toSet();

  int monthCount(int year, int month) => _records
      .where((r) {
        final d = DateTime.tryParse(r.date);
        return d != null && d.year == year && d.month == month;
      })
      .length;

  int get streak => computeStreak(datesWithRecords.toList());

  List<DoneRecord> recordsOn(String dateKey) =>
      _records.where((r) => r.date == dateKey).toList();
}
