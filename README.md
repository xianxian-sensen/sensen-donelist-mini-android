# sensen-donelist-mini-android

> 记录你已完成的事，而非未完成的事 — Flutter 原生 Android 版。

一个反向清单（Done List）应用。传统 to-do 让人焦虑，DoneList 让你看见自己已经做到了什么——每一条记录都是对今日努力的小小肯定。

## 特性

- **记录页**：单一输入框，快速记录今日完成的事，支持删除与时间戳
- **日历页**：月度网格视图，有记录的日期以琥珀金圆点标记，点击查看当日详情，附本月完成数与连续记录天数统计
- **设置页**：系统日历原生写入、ICS/JSON 导出分享、清空全部数据（二次确认）
- **本地存储**：基于 SharedPreferences，无需账号、无需联网，完全离线可用
- **系统日历同步**：直接写入 Android 系统日历（需授权），同时保留 ICS 导出作为通用兼容方案

## 技术栈

- Flutter 3.27 + Dart 3.6
- Provider + ChangeNotifier（状态管理）
- shared_preferences（本地持久化）
- device_calendar（原生写入系统日历）
- share_plus + path_provider（ICS/JSON 导出分享）
- timezone（时区处理）

## 快速开始

### 环境要求

- Flutter SDK ≥ 3.27
- JDK 17
- Android SDK（Platform 36 + Build-Tools 36.0.0）
- 配置 PUB_HOSTED_URL 镜像（中国大陆）：`https://pub.flutter-io.cn`

### 安装依赖

```bash
flutter pub get
```

### 运行

```bash
# 连接设备或模拟器后
flutter run

# 构建 debug APK
flutter build apk --debug

# 构建 release APK（体积更小，约 22MB）
flutter build apk --release
```

构建完成后，APK 位于：

```
build/app/outputs/flutter-apk/app-release.apk
```

## 项目结构

```
lib/
├── main.dart                  # 入口 + 全局主题 + 底部导航
├── theme/
│   └── app_colors.dart        # 颜色常量（暖米白/深墨绿/琥珀金）
├── models/
│   └── done_record.dart       # 数据模型（DoneRecord / AppSettings）
├── store/
│   └── app_store.dart         # AppStore（ChangeNotifier）
├── services/
│   ├── storage_service.dart   # 本地持久化
│   └── calendar_service.dart  # 系统日历同步 + ICS 生成
├── pages/
│   ├── record_page.dart       # 记录页
│   ├── calendar_page.dart     # 日历页
│   └── settings_page.dart     # 设置页
├── widgets/
│   ├── section_title.dart     # 区块标题
│   └── empty_state.dart       # 空状态占位
└── utils/
    └── date_utils.dart        # 日期工具
```

## 设计系统

| 角色 | 色值 | 说明 |
|------|------|------|
| 纸张背景 | `#F5F1E8` | 暖米白，主背景 |
| 深墨绿 | `#1F3A2E` | 主色，标题/导航 |
| 琥珀金 | `#C9A961` | 强调色，圆点/高亮 |
| 黏土红 | `#B85042` | 危险操作 |

## 与 Web 版的关系

Web 版仓库：[sensen-donelist-mini](https://github.com/xianxian-sensen/sensen-donelist-mini)（React + Vite，部署于 Vercel）

两个版本数据模型一致，可互相导出导入 JSON 备份。

## 许可证

MIT