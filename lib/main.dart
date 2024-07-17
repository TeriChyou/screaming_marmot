import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  late VideoPlayerController _controller;
  Future<void>? _playFuture; // Track the current play segment future

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/screaming_marmot.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playSegment() {
    const start = Duration(seconds: 1, milliseconds: 500); // Adjust to your segment start

    // Cancel any previous play segment


    // Seek to the start of the segment and play
    _controller.seekTo(start);
    _controller.play();
    if (_playFuture != null) {
      _controller.seekTo(start);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '土撥鼠紓壓器',
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Center(
        child:GestureDetector(
          onTap:(){
            _playSegment();
          },
          child: _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : const CircularProgressIndicator(),
        )
      ),
    );
  }
}
