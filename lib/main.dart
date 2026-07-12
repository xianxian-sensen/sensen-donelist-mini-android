import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_colors.dart';
import 'store/app_store.dart';
import 'pages/record_page.dart';
import 'pages/calendar_page.dart';
import 'pages/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 锁定竖屏
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  runApp(const DoneListApp());
}

class DoneListApp extends StatelessWidget {
  const DoneListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStore(),
      child: MaterialApp(
        title: 'DoneList',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const _SplashGate(),
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.moss,
        secondary: AppColors.amber,
        surface: AppColors.paper,
        error: AppColors.clay,
      ),
      dividerColor: AppColors.paperEdge,
      iconTheme: const IconThemeData(color: AppColors.ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.moss,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: AppColors.moss,
            fontSize: 16,
            fontWeight: FontWeight.w600),
      ),
      textTheme: base.textTheme.copyWith(
        bodyLarge: const TextStyle(color: AppColors.ink, fontSize: 15),
        bodyMedium: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
        bodySmall: const TextStyle(color: AppColors.inkMute, fontSize: 12),
      ),
    );
  }
}

/// 启动加载页（等待 store init 完成）
class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStore>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    if (!store.initialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.moss,
            strokeWidth: 2,
          ),
        ),
      );
    }
    return const _MainShell();
  }
}

/// 主壳：底部导航 + 三个页面
class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _index = 0;
  final _pages = const [
    RecordPage(),
    CalendarPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// 自定义底部导航（对应 React 版的 BottomNav）
class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(
            top: BorderSide(color: AppColors.paperEdge, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavTab(
                icon: Icons.edit_note,
                label: '记录',
                selected: index == 0,
                onTap: () => onChanged(0),
              ),
              _NavTab(
                icon: Icons.calendar_month_outlined,
                label: '日历',
                selected: index == 1,
                onTap: () => onChanged(1),
              ),
              _NavTab(
                icon: Icons.settings_outlined,
                label: '设置',
                selected: index == 2,
                onTap: () => onChanged(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.amber.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.moss : AppColors.inkMute,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? AppColors.moss : AppColors.inkMute,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
