import 'package:flutter/material.dart';

class SettingsDrawer extends StatelessWidget {
  final int totalClicks;
  final bool showCounter;
  final ValueChanged<bool> onToggleCounter;
  final VoidCallback onResetSession;

  const SettingsDrawer({
    super.key,
    required this.totalClicks,
    required this.showCounter,
    required this.onToggleCounter,
    required this.onResetSession,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.brown,
              image: DecorationImage(
                image: AssetImage('assets/marmot.png'), // 可以放一張土撥鼠當背景
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '設定與資訊',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'cjk',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.ads_click),
            title: const Text('生涯總點擊次數'),
            trailing: Text(
              '$totalClicks',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility),
            title: const Text('顯示畫面計數器'),
            value: showCounter,
            onChanged: onToggleCounter,
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('重新計算當次點擊'),
            onTap: () {
              onResetSession();
              Navigator.pop(context); // 點擊後自動收起側邊欄
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text('全球排行榜 (即將推出)'),
            subtitle: const Text('串接中...'),
            onTap: () {
              // 預留給 Firebase 實作
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('更新公告'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('更新公告'),
                  content: const Text(
                    'v1.0.1\n'
                        '- UI 介面全面升級\n'
                        '- 加入 5% 機率黃金土撥鼠\n'
                        '- 新增設定側邊欄與本地紀錄\n',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('關閉'),
                    )
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('關於作者'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '土撥鼠紓壓器',
                applicationVersion: '2.0.0',
                applicationLegalese: '© 2026 Terry. All rights reserved.',
                applicationIcon: const Icon(Icons.pets, size: 48),
              );
            },
          ),
        ],
      ),
    );
  }
}