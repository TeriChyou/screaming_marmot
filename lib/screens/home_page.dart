import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 引入套件
import '../models/gif_data.dart';
import 'settings_drawer.dart'; // 引入剛寫好的側邊欄

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  final List<GifData> _gifs = [];
  final Random _random = Random();
  late AnimationController _controller;

  int _currentSessionClicks = 0;
  int _totalClicks = 0; // 生涯總點擊
  bool _showCounter = true; // 計數器開關
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _initPrefs(); // 初始化本地資料
  }

  // 讀取本地端資料
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalClicks = _prefs?.getInt('totalClicks') ?? 0;
      _showCounter = _prefs?.getBool('showCounter') ?? true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var gif in _gifs) {
      gif.audioPlayer.dispose();
    }
    super.dispose();
  }

  void _playSegment() async {
    // 同時更新當次與總次數，並寫入本地
    setState(() {
      _currentSessionClicks++;
      _totalClicks++;
    });
    // 為了效能，背景非同步寫入即可，不需 await
    _prefs?.setInt('totalClicks', _totalClicks);

    double left = _random.nextDouble() * (MediaQuery.of(context).size.width);
    double top = _random.nextDouble() * (MediaQuery.of(context).size.height);
    double rotation = _random.nextDouble() * 360;
    bool flip = _random.nextBool();
    double size = _random.nextDouble() * 150 + 100;
    bool rotate = _random.nextDouble() <= 0.25;
    bool isGolden = _random.nextDouble() <= 0.05;

    AudioPlayer newAudioPlayer = AudioPlayer();
    await newAudioPlayer.setAsset('assets/marmotAudio.mp3');
    await newAudioPlayer.setVolume(0.08);
    newAudioPlayer.play();

    var gifData = GifData(
      assetPath: isGolden ? 'assets/marmot_golden.gif' : 'assets/marmot.gif',
      left: left,
      top: top,
      rotation: rotation,
      size: size,
      flip: flip,
      rotate: rotate,
      audioPlayer: newAudioPlayer,
    );

    setState(() {
      _gifs.add(gifData);
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _gifs.remove(gifData);
        });
      }
      gifData.audioPlayer.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'cjk',
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(offset: Offset(2.0, 2.0), blurRadius: 8.0, color: Colors.black87),
            ],
          ),
        ),
        centerTitle: true,
      ),
      // 掛載側邊欄
      drawer: SettingsDrawer(
        totalClicks: _totalClicks,
        showCounter: _showCounter,
        onToggleCounter: (value) {
          setState(() {
            _showCounter = value;
          });
          _prefs?.setBool('showCounter', value);
        },
        onResetSession: () {
          setState(() {
            _currentSessionClicks = 0;
          });
        },
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _playSegment();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/marmot.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // 根據設定決定是否顯示計數器
              if (_showCounter)
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12),
                    child: IgnorePointer(
                      child: Text(
                        _currentSessionClicks > 0 ? '$_currentSessionClicks' : '',
                        style: const TextStyle(
                          fontSize: 30, // 配合 Align 微調大小
                          fontWeight: FontWeight.w900,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
              ..._gifs.map((gif) {
                return Positioned(
                  left: gif.left - 100,
                  top: gif.top - 100,
                  child: gif.rotate
                      ? AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * pi,
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: gif.size,
                      height: gif.size,
                      child: Image.asset(gif.assetPath),
                    ),
                  )
                      : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationZ(gif.rotation * pi / 180)
                      ..scale(gif.flip ? -1.0 : 1.0, 1.0),
                    child: SizedBox(
                      width: gif.size,
                      height: gif.size,
                      child: Image.asset(gif.assetPath),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}