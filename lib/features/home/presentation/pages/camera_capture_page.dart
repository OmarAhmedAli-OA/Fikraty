import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CameraCaptureResult {
  final String path;
  final bool isVideo;
  final String? duration;

  CameraCaptureResult({
    required this.path,
    required this.isVideo,
    this.duration,
  });
}

class CameraCapturePage extends StatefulWidget {
  final bool initialVideoMode;

  const CameraCapturePage({
    super.key,
    this.initialVideoMode = false,
  });

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isInitializing = true;
  String? _errorMessage;

  late bool _isVideoMode;
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;

  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _isVideoMode = widget.initialVideoMode;
    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Prefer front camera or first available
        _selectedCameraIndex = 0;
        for (int i = 0; i < _cameras.length; i++) {
          if (_cameras[i].lensDirection == CameraLensDirection.front) {
            _selectedCameraIndex = i;
            break;
          }
        }
        await _setupController(_cameras[_selectedCameraIndex]);
      } else {
        if (!mounted) return;
        setState(() {
          _isInitializing = false;
          _isCameraInitialized = false;
          _errorMessage = 'No camera found on this device';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _isCameraInitialized = false;
        _errorMessage = 'Could not access camera: $e';
      });
    }
  }

  Future<void> _setupController(CameraDescription camera) async {
    final prevController = _controller;
    final newController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await prevController?.dispose();

    try {
      await newController.initialize();
      if (!mounted) return;
      setState(() {
        _controller = newController;
        _isCameraInitialized = true;
        _isInitializing = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = false;
        _isInitializing = false;
        _errorMessage = 'Camera initialization failed: $e';
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_isCameraInitialized) return;
    try {
      setState(() {
        _flashOn = !_flashOn;
      });
      await _controller!.setFlashMode(
        _flashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (_) {}
  }

  // --- Real Photo Capture from Camera ---
  Future<void> _takePhoto() async {
    if (!_isCameraInitialized || _controller == null) return;

    try {
      final XFile photo = await _controller!.takePicture();
      String finalPath = photo.path;
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final mediaDir = Directory('${appDir.path}/fikraty_media');
        if (!await mediaDir.exists()) {
          await mediaDir.create(recursive: true);
        }
        final persistentPath = '${mediaDir.path}/IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await File(photo.path).copy(persistentPath);
        finalPath = persistentPath;
      } catch (_) {}
      if (!mounted) return;
      Navigator.pop(
        context,
        CameraCaptureResult(path: finalPath, isVideo: false),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take photo: $e')),
      );
    }
  }

  // --- Real Video Recording from Camera ---
  Future<void> _toggleVideoRecord() async {
    if (!_isCameraInitialized || _controller == null) return;

    if (_isRecording) {
      // Stop Recording
      _recordTimer?.cancel();
      try {
        final XFile video = await _controller!.stopVideoRecording();
        final durationStr = _formatDuration(_recordSeconds);
        String finalPath = video.path;
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final mediaDir = Directory('${appDir.path}/fikraty_media');
          if (!await mediaDir.exists()) {
            await mediaDir.create(recursive: true);
          }
          final persistentPath = '${mediaDir.path}/VID_${DateTime.now().millisecondsSinceEpoch}.mp4';
          await File(video.path).copy(persistentPath);
          finalPath = persistentPath;
        } catch (_) {}
        if (!mounted) return;
        Navigator.pop(
          context,
          CameraCaptureResult(
            path: finalPath,
            isVideo: true,
            duration: durationStr,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save video: $e')),
        );
      }
    } else {
      // Start Recording
      try {
        await _controller!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _recordSeconds = 0;
        });

        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          setState(() {
            _recordSeconds++;
          });
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Real Camera Preview
          if (_isCameraInitialized && _controller != null)
            Center(
              child: CameraPreview(_controller!),
            )
          else
            _buildLoadingOrErrorView(),

          // Top Controls (Close, Flash, Switch Camera, REC Timer)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    if (_isRecording)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDuration(_recordSeconds),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        if (!kIsWeb)
                          IconButton(
                            icon: Icon(
                              _flashOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              color: _flashOn ? Colors.amber : Colors.white,
                              size: 26,
                            ),
                            onPressed: _toggleFlash,
                          ),
                        if (_cameras.length > 1)
                          IconButton(
                            icon: const Icon(Icons.flip_camera_ios_rounded,
                                color: Colors.white, size: 26),
                            onPressed: _switchCamera,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls (Modes + Shutter Button)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.only(bottom: 32, top: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mode Selector (PHOTO | VIDEO)
                  if (!_isRecording)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isVideoMode = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: !_isVideoMode
                                  ? Colors.white24
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'PHOTO',
                              style: TextStyle(
                                color:
                                    !_isVideoMode ? Colors.white : Colors.white60,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => setState(() => _isVideoMode = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isVideoMode
                                  ? Colors.white24
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'VIDEO',
                              style: TextStyle(
                                color:
                                    _isVideoMode ? Colors.white : Colors.white60,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Shutter Button (Tap to Shoot / Record)
                  GestureDetector(
                    onTap: _isCameraInitialized
                        ? (_isVideoMode ? _toggleVideoRecord : _takePhoto)
                        : null,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isVideoMode
                              ? const Color(0xFFEF4444)
                              : Colors.white,
                          width: 4,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isVideoMode
                              ? const Color(0xFFEF4444)
                              : (_isCameraInitialized
                                  ? Colors.white
                                  : Colors.white38),
                          shape: _isRecording
                              ? BoxShape.rectangle
                              : BoxShape.circle,
                          borderRadius: _isRecording
                              ? BorderRadius.circular(10)
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isVideoMode
                        ? (_isRecording ? 'Tap to Stop' : 'Tap to Record Video')
                        : 'Tap to Take Photo & Send',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOrErrorView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: _isInitializing
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Starting camera...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.videocam_off_rounded,
                      color: Colors.white54,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ?? 'Camera unavailable',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                      ),
                      onPressed: _initCamera,
                      child: const Text(
                        'Retry Camera',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
