import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/gif_data.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose(); // 養成好習慣，釋放動畫控制器
    for (var gif in _gifs) {
      gif.audioPlayer.dispose();
    }
    super.dispose();
  }

  void _playSegment() async {
    // 產生隨機數值
    double left = _random.nextDouble() * (MediaQuery.of(context).size.width);
    double top = _random.nextDouble() * (MediaQuery.of(context).size.height);
    double rotation = _random.nextDouble() * 360;
    bool flip = _random.nextBool();
    double size = _random.nextDouble() * 150 + 100;
    bool rotate = _random.nextDouble() <= 0.25;
    bool isGolden = _random.nextDouble() <= 0.05;

    // 實例化 just_audio 播放器並設定音效
    AudioPlayer newAudioPlayer = AudioPlayer();
    await newAudioPlayer.setAsset('assets/marmotAudio.mp3');
    await newAudioPlayer.setVolume(0.08);
    newAudioPlayer.play();

    // 建立新的 GIF 實例
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

    // 設定 3 秒後移除
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) { // 確保畫面還在才執行 setState
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
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'cjk',
            fontSize: 48,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          _playSegment();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/marmot.png'), // 請確保你有這張背景圖
              fit: BoxFit.fitWidth,
            ),
          ),
          child: Stack(
            children: _gifs.map((gif) {
              return Positioned(
                left: gif.left - 100,
                top: gif.top - 100,
                child: gif.rotate
                    ? AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * 2 * pi, // 這裡改用 pi
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
            }).toList(),
          ),
        ),
      ),
    );
  }
}