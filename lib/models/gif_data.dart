import 'package:just_audio/just_audio.dart';

class GifData {
  final String assetPath;
  final double left;
  final double top;
  final double rotation;
  final double size;
  final bool flip;
  final bool rotate;
  bool isDisposed = false;
  final AudioPlayer audioPlayer; // 這裡已經換成 just_audio 的 AudioPlayer

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