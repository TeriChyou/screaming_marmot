import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_page.dart';

void main() {
  // 讓手機頂部狀態列變透明，畫面更具沉浸感
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '土撥鼠紓壓器',
      debugShowCheckedModeBanner: false, // 隱藏右上角的 DEBUG 標籤
      theme: ThemeData(
        // 改用棕色/大地色系作為基礎，呼應土撥鼠
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '土撥鼠紓壓器'),
    );
  }
}