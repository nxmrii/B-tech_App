import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  late List<CameraDescription> cameras;

  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Error initializing cameras: $e');
  }

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: FaceIDScreen(camera: cameras.first),
    );
  }
}


class FaceIDScreen extends StatefulWidget {
  final CameraDescription camera;

  const FaceIDScreen({super.key, required this.camera});

  @override
  _FaceIDScreenState createState() => _FaceIDScreenState();
}

class _FaceIDScreenState extends State<FaceIDScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureAndRecognizeFace() async {
    try {
      await _initializeControllerFuture;

      final image = await _controller.takePicture();

      if (!mounted) return;

      // Mock recognition process
      final faceRecognized = await _mockFaceRecognition(image.path);

      if (faceRecognized) {
        _showMessage('Face recognized successfully!');
      } else {
        _showMessage('Face not recognized. Please try again.');
      }

      // Clean up the captured image
      final file = File(image.path);
      if (file.existsSync()) {
        await file.delete();
      }
    } catch (e) {
      _showMessage('Error capturing image: $e');
      print(e);
    }
  }


  Future<bool> _mockFaceRecognition(String imagePath) async {
    // Simulate recognition logic (replace this with actual implementation)
    await Future.delayed(const Duration(seconds: 2)); // Simulate processing time
    return true; // Assume face recognition success
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face ID Recognition')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureAndRecognizeFace,
        child: const Icon(Icons.face),
      ),
    );
  }
}
