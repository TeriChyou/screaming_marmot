import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class GifData {
  final String assetPath;
  final double left;
  final double top;
  final double rotation;
  final double size;
  final bool flip;
  final bool rotate;
  bool isDisposed = false;
  final AudioPlayer audioPlayer;

  GifData({
    required this.assetPath,
    required this.left,
    required this.top,
    required this.rotation,
    required this.size,
    required this.flip,
    required this.rotate,
    required this.audioPlayer,
  });
}
class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{
  final List<GifData> _gifs = [];
  final Random _random = Random();
  late AnimationController _controller;
  void _playSegment() {
    setState(() {
      // Generate random position
      double left = _random.nextDouble() * (MediaQuery.of(context).size.width);
      double top = _random.nextDouble() * (MediaQuery.of(context).size.height);
      double rotation = _random.nextDouble() * 360; // Random rotation from -45 to +45 degrees
      bool flip = _random.nextBool(); // Randomly flip left/right
      double size = _random.nextDouble() * 150 + 100;
      bool rotate = _random.nextDouble() <= 0.25;
      // Create a new instance of AudioPlayer for concurrent audio playback
      AudioPlayer newAudioPlayer = AudioPlayer();
      newAudioPlayer.play(AssetSource('marmotAudio.mp3'), mode: PlayerMode.lowLatency, volume: 0.08);

      // Create new GIF instance
      var gifData = GifData(
        assetPath: 'assets/marmot.gif',
        left: left,
        top: top,
        rotation: rotation,
        size: size,
        flip: flip,
        rotate: rotate,
        audioPlayer: newAudioPlayer,
      );
      _gifs.add(gifData);
      print("GIF added");

      // Remove the GIF after a delay (assuming GIF length matches audio length)
      Future.delayed(const Duration(seconds: 3), () {
        if (!gifData.isDisposed) {
          setState(() {
            _gifs.remove(gifData);
          });
          gifData.audioPlayer.dispose();
        }
      });
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    for (var gif in _gifs) {
      gif.audioPlayer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '土撥鼠紓壓器',
          style: TextStyle(
            fontFamily: 'cjk',
            fontSize: 48,
            fontWeight: FontWeight.w500
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
          onTap: (){
            _playSegment();
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/marmot.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
            child: Stack(
              children: _gifs.map((gif) {
                return Positioned(
                  left: gif.left - 100,
                  top: gif.top - 100,
                  child: gif.rotate ?
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * 3.14159, // Rotate full circle
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: gif.size,
                      height: gif.size,
                      child: Image.asset(gif.assetPath),
                    ),
                  ):
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationZ(gif.rotation * pi / 180)..scale(gif.flip ? -1.0 : 1.0, 1.0),
                    child: SizedBox(
                      width: gif.size,
                      height: gif.size,
                      child: Image.asset(gif.assetPath),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
      ),
    );
  }
}
