import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  // Create a picture recorder
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Define the icon size (1024x1024)
  const size = Size(1024, 1024);
  
  // Draw main icon
  await drawIcon(canvas, size, withBackground: true);
  
  // Create the image
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
  
  // Save the file
  final iconDir = Directory(path.join(Directory.current.path, 'assets', 'icon'));
  if (!await iconDir.exists()) {
    await iconDir.create(recursive: true);
  }
  
  final file = File(path.join(iconDir.path, 'icon.png'));
  await file.writeAsBytes(pngBytes!.buffer.asUint8List());
  
  // Create foreground icon (without background)
  final recorderFg = ui.PictureRecorder();
  final canvasFg = Canvas(recorderFg);
  await drawIcon(canvasFg, size, withBackground: false);
  
  final pictureFg = recorderFg.endRecording();
  final imageFg = await pictureFg.toImage(size.width.toInt(), size.height.toInt());
  final pngBytesFg = await imageFg.toByteData(format: ui.ImageByteFormat.png);
  
  final fileFg = File(path.join(iconDir.path, 'icon_foreground.png'));
  await fileFg.writeAsBytes(pngBytesFg!.buffer.asUint8List());
}

Future<void> drawIcon(Canvas canvas, Size size, {required bool withBackground}) async {
  final paint = Paint()
    ..style = PaintingStyle.fill;
  
  if (withBackground) {
    // Draw background
    paint.color = const Color(0xFF42A5F5); // Sky blue background
    canvas.drawRect(Offset.zero & size, paint);
  }
  
  // Draw sun
  paint.color = Colors.yellow;
  final center = Offset(size.width * 0.6, size.height * 0.4);
  canvas.drawCircle(center, size.width * 0.25, paint);
  
  // Draw cloud
  paint.color = Colors.white;
  final cloudPath = Path()
    ..moveTo(size.width * 0.3, size.height * 0.5)
    ..quadraticBezierTo(
      size.width * 0.2, size.height * 0.4,
      size.width * 0.3, size.height * 0.3)
    ..quadraticBezierTo(
      size.width * 0.4, size.height * 0.2,
      size.width * 0.5, size.height * 0.3)
    ..quadraticBezierTo(
      size.width * 0.6, size.height * 0.4,
      size.width * 0.7, size.height * 0.4)
    ..quadraticBezierTo(
      size.width * 0.8, size.height * 0.4,
      size.width * 0.7, size.height * 0.5)
    ..close();
  
  canvas.drawPath(cloudPath, paint);
}
