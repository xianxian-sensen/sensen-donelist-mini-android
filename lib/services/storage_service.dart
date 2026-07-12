import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/done_record.dart';

/// 本地持久化服务（基于 SharedPreferences）
/// 对应 React 版的 localStorage，键名保持一致
class StorageService {
  static const _kRecords = 'donelist:records';
  static const _kSettings = 'donelist:settings';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ===== 记录 =====
  List<DoneRecord> loadRecords() {
    final raw = _prefs.getString(_kRecords);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => DoneRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveRecords(List<DoneRecord> records) async {
    final raw = jsonEncode(records.map((r) => r.toJson()).toList());
    await _prefs.setString(_kRecords, raw);
  }

  // ===== 设置 =====
  AppSettings loadSettings() {
    final raw = _prefs.getString(_kSettings);
    if (raw == null || raw.isEmpty) return AppSettings();
    return AppSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final raw = jsonEncode(settings.toJson());
    await _prefs.setString(_kSettings, raw);
  }

  // ===== 清空 =====
  Future<void> clearAll() async {
    await _prefs.remove(_kRecords);
    await _prefs.remove(_kSettings);
  }
}
