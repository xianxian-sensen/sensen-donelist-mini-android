import 'dart:convert';

/// 单条完成记录
class DoneRecord {
  final String id;
  final String content;
  final String date; // YYYY-MM-DD
  final String createdAt; // ISO 8601

  DoneRecord({
    required this.id,
    required this.content,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'date': date,
        'created_at': createdAt,
      };

  factory DoneRecord.fromJson(Map<String, dynamic> json) => DoneRecord(
        id: json['id'] as String,
        content: json['content'] as String,
        date: json['date'] as String,
        createdAt: json['created_at'] as String,
      );
}

/// 应用设置
class AppSettings {
  final bool calendarSyncEnabled;
  final String theme; // 'light' | 'dark'
  final String? lastExportDate;

  AppSettings({
    this.calendarSyncEnabled = false,
    this.theme = 'light',
    this.lastExportDate,
  });

  AppSettings copyWith({
    bool? calendarSyncEnabled,
    String? theme,
    String? lastExportDate,
  }) =>
      AppSettings(
        calendarSyncEnabled: calendarSyncEnabled ?? this.calendarSyncEnabled,
        theme: theme ?? this.theme,
        lastExportDate: lastExportDate ?? this.lastExportDate,
      );

  Map<String, dynamic> toJson() => {
        'calendar_sync_enabled': calendarSyncEnabled,
        'theme': theme,
        'last_export_date': lastExportDate,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        calendarSyncEnabled: json['calendar_sync_enabled'] as bool? ?? false,
        theme: json['theme'] as String? ?? 'light',
        lastExportDate: json['last_export_date'] as String?,
      );
}

/// 序列化辅助：列表 <--> JSON 字符串
String recordsToJson(List<DoneRecord> records) =>
    jsonEncode(records.map((r) => r.toJson()).toList());

List<DoneRecord> recordsFromJson(String raw) {
  if (raw.isEmpty) return [];
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => DoneRecord.fromJson(e as Map<String, dynamic>))
      .toList();
}
