import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';

class DrawingPoint {
  final Offset offset;
  final Paint paint;
  DrawingPoint({required this.offset, required this.paint});
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i]!.offset,
          points[i + 1]!.offset,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawCircle(
          points[i]!.offset,
          points[i]!.paint.strokeWidth / 2,
          points[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class StoryOverlayItem {
  String text;
  final bool isMention;
  final bool isEmoji;
  Color textColor;
  Color bgColor;
  Offset position;

  StoryOverlayItem({
    required this.text,
    this.isMention = false,
    this.isEmoji = false,
    this.textColor = Colors.white,
    this.bgColor = const Color(0x99000000),
    required this.position,
  });
}

class CreateStoryPage extends StatefulWidget {
  const CreateStoryPage({super.key});

  @override
  State<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends State<CreateStoryPage> {
  final GlobalKey _canvasKey = GlobalKey();

  // Camera state
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  int _selectedCameraIndex = 0;
  bool _isCameraReady = false;
  bool _isRecordingVideo = false;
  int _videoSeconds = 0;
  Timer? _videoTimer;

  // Story media & editor state
  String? _capturedMediaPath;
  bool _isCanvasMode = false;
  int _selectedGradientIndex = 0;

  // Drawing tool state
  bool _isDrawingMode = false;
  Color _selectedBrushColor = Colors.white;
  final List<DrawingPoint?> _drawingPoints = [];

  // Overlays (Text, Mentions, Emojis)
  final List<StoryOverlayItem> _overlayItems = [];
  final TextEditingController _captionController = TextEditingController();

  final List<List<Color>> _backgroundGradients = [
    [const Color(0xFF4F46E5), const Color(0xFF7C3AED)], // Indigo to Purple
    [const Color(0xFF0F172A), const Color(0xFF1E293B)], // Midnight Slate
    [const Color(0xFF059669), const Color(0xFF0D9488)], // Emerald Teal
    [const Color(0xFFEA580C), const Color(0xFFE11D48)], // Sunset Red
    [const Color(0xFF2563EB), const Color(0xFF06B6D4)], // Ocean Blue
    [const Color(0xFF833AB4), const Color(0xFFFD1D1D)], // Instagram Classic
  ];

  final List<Color> _brushColors = [
    Colors.white,
    const Color(0xFFEF4444), // Red
    const Color(0xFFF59E0B), // Amber
    const Color(0xFF10B981), // Emerald
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF6366F1), // Indigo
    const Color(0xFFA855F7), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _selectedCameraIndex = 0;
        // Prefer front camera for selfie stories
        for (int i = 0; i < _cameras.length; i++) {
          if (_cameras[i].lensDirection == CameraLensDirection.front) {
            _selectedCameraIndex = i;
            break;
          }
        }
        await _setupCameraController(_cameras[_selectedCameraIndex]);
      } else {
        if (!mounted) return;
        setState(() {
          _isCanvasMode = true;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCanvasMode = true;
      });
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    final prev = _cameraController;
    final newController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await prev?.dispose();

    try {
      await newController.initialize();
      if (!mounted) return;
      setState(() {
        _cameraController = newController;
        _isCameraReady = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCameraReady = false;
        _isCanvasMode = true;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  // --- Real Camera Shutter (Take Photo or Record Video) ---
  Future<void> _takePhoto() async {
    if (!_isCameraReady || _cameraController == null) return;
    try {
      final XFile photo = await _cameraController!.takePicture();
      if (!mounted) return;
      setState(() {
        _capturedMediaPath = photo.path;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take photo: $e')),
      );
    }
  }

  Future<void> _startVideoRecording() async {
    if (!_isCameraReady || _cameraController == null || _isRecordingVideo) return;
    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecordingVideo = true;
        _videoSeconds = 0;
      });

      _videoTimer?.cancel();
      _videoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          _videoSeconds++;
        });
        if (_videoSeconds >= 30) {
          _stopVideoRecording();
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!_isRecordingVideo || _cameraController == null) return;
    _videoTimer?.cancel();
    try {
      final XFile video = await _cameraController!.stopVideoRecording();
      if (!mounted) return;
      setState(() {
        _isRecordingVideo = false;
        _capturedMediaPath = video.path;
      });
    } catch (e) {
      setState(() {
        _isRecordingVideo = false;
      });
    }
  }

  // --- Upload Media from Device Gallery ---
  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (file != null) {
        setState(() {
          _capturedMediaPath = file.path;
        });
      }
    } catch (_) {
      try {
        final List<PlatformFile> files = await FilePicker.pickFiles(
          type: FileType.media,
        );
        if (files.isNotEmpty) {
          final p = files.first.path ?? files.first.name;
          setState(() {
            _capturedMediaPath = p;
          });
        }
      } catch (_) {}
    }
  }

  // --- Add Text Overlay (Aa) ---
  void _openTextDialog() {
    final textController = TextEditingController();
    Color textColor = Colors.white;
    Color bgColor = Colors.black54;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: textController,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          cursorColor: Colors.white,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            filled: false,
                            fillColor: Colors.transparent,
                            hintText: 'Type text here...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Color picker
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _brushColors.map((c) {
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                textColor = c;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: textColor == c
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.white70)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              final text = textController.text.trim();
                              if (text.isNotEmpty) {
                                setState(() {
                                  _overlayItems.add(
                                    StoryOverlayItem(
                                      text: text,
                                      textColor: textColor,
                                      bgColor: bgColor,
                                      position: const Offset(80, 220),
                                    ),
                                  );
                                });
                              }
                              Navigator.pop(ctx);
                            },
                            child: const Text('Done',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Add Mention Overlay (@) ---
  void _openMentionDialog() {
    final suggestions = [
      '@tariq_hassan',
      '@novamed_ai',
      '@green_stack',
      '@wamda_capital',
      '@omar_khalil',
      '@fikraty_hq',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mention Someone (@)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions.map((tag) {
                  return ActionChip(
                    backgroundColor:
                        AppColors.primaryPurple.withValues(alpha: 0.2),
                    side: const BorderSide(color: AppColors.primaryPurple),
                    label: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _overlayItems.add(
                          StoryOverlayItem(
                            text: tag,
                            isMention: true,
                            textColor: Colors.white,
                            bgColor: AppColors.primaryPurple,
                            position: const Offset(100, 300),
                          ),
                        );
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- Add Stickers / Emojis Sheet ---
  void _openStickersSheet() {
    final stickers = [
      '🚀 Seed Round',
      '💡 Startup Update',
      '📈 100K ARR',
      '🤝 New Partnership',
      '🔥 Hiring Tech Lead',
      '🎯 MVP Launched',
      '✨ Demo Day',
      '🏆 Top Pitch',
    ];
    final emojis = [
      '❤️', '🔥', '🚀', '💡', '🎉', '👏', '📈', '🤝', '💯', '✨', '😍', '🤩'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stickers & Emojis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Emojis row
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: emojis.map((e) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _overlayItems.add(
                          StoryOverlayItem(
                            text: e,
                            isEmoji: true,
                            position: const Offset(140, 260),
                          ),
                        );
                      });
                    },
                    child: Text(e, style: const TextStyle(fontSize: 32)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 8),
              // Startup stickers
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stickers.map((st) {
                  return ActionChip(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    side: const BorderSide(color: Colors.white38),
                    label: Text(
                      st,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _overlayItems.add(
                          StoryOverlayItem(
                            text: st,
                            position: const Offset(80, 240),
                          ),
                        );
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _captureCanvas() async {
    try {
      // Small delay to allow any modal or keyboard to settle before capturing
      await Future.delayed(const Duration(milliseconds: 60));
      final boundary =
          _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final bytes = byteData.buffer.asUint8List();
          final base64String = base64Encode(bytes);
          return 'data:image/png;base64,$base64String';
        }
      }
    } catch (e) {
      debugPrint('Error capturing canvas: $e');
    }
    return 'gradient:$_selectedGradientIndex';
  }

  Future<void> _shareStory() async {
    String media;
    if (_capturedMediaPath != null &&
        _drawingPoints.isEmpty &&
        _overlayItems.isEmpty) {
      media = _capturedMediaPath!;
    } else {
      media = await _captureCanvas();
    }

    final caption = _captionController.text.trim().isNotEmpty
        ? _captionController.text.trim()
        : (_overlayItems.isNotEmpty ? _overlayItems.first.text : '');

    if (!mounted) return;
    context.read<FeedBloc>().add(
          AddStoryEvent(
            caption: caption,
            imageUrl: media,
          ),
        );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoTimer?.cancel();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If media is captured or canvas mode active, show the Editor View.
    // Otherwise show the Live Camera Capture View!
    final hasMedia = _capturedMediaPath != null || _isCanvasMode;

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: hasMedia ? _buildEditorView() : _buildCameraCaptureView(),
      ),
    );
  }

  // ==========================================
  // VIEW 1: LIVE INSTAGRAM CAMERA CAPTURE VIEW
  // ==========================================
  Widget _buildCameraCaptureView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        if (_isCameraReady && _cameraController != null)
          Center(
            child: CameraPreview(_cameraController!),
          )
        else
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            ),
          ),

        // Gradient top/bottom for controls
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black87,
                Colors.transparent,
                Colors.transparent,
                Colors.black87,
              ],
              stops: [0.0, 0.15, 0.70, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Top Bar (Close, Flash, Switch Camera, Text Mode)
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
                  if (_isRecordingVideo)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'REC 0:${_videoSeconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      // Text Canvas Mode (Aa)
                      IconButton(
                        icon: const Icon(Icons.text_fields_rounded,
                            color: Colors.white, size: 26),
                        onPressed: () {
                          setState(() {
                            _isCanvasMode = true;
                          });
                        },
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

        // Bottom Controls (Gallery, Shutter Ring, Canvas Toggle)
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gallery Pick Button
                  GestureDetector(
                    onTap: _pickFromGallery,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white54, width: 2),
                      ),
                      child: const Icon(
                        Icons.photo_library_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),

                  // Instagram Shutter Ring
                  GestureDetector(
                    onTap: _takePhoto,
                    onLongPressStart: (_) => _startVideoRecording(),
                    onLongPressEnd: (_) => _stopVideoRecording(),
                    child: Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isRecordingVideo
                              ? const Color(0xFFEF4444)
                              : Colors.white,
                          width: 4,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isRecordingVideo
                              ? const Color(0xFFEF4444)
                              : Colors.white,
                          shape: _isRecordingVideo
                              ? BoxShape.rectangle
                              : BoxShape.circle,
                          borderRadius: _isRecordingVideo
                              ? BorderRadius.circular(10)
                              : null,
                        ),
                      ),
                    ),
                  ),

                  // Create Gradient Canvas Mode
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCanvasMode = true;
                      });
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF833AB4), Color(0xFFFD1D1D)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white54, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'Aa',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW 2: INSTAGRAM STORY EDITOR VIEW
  // ==========================================
  Widget _buildEditorView() {
    final currentGradient = _backgroundGradients[_selectedGradientIndex];

    return Stack(
      fit: StackFit.expand,
      children: [
        // Story Canvas captured by _canvasKey (Background + Drawings + Overlays)
        RepaintBoundary(
          key: _canvasKey,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background (Captured Image or Gradient Canvas)
              if (_capturedMediaPath != null)
                _buildCapturedMediaImage(_capturedMediaPath!)
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: currentGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

              // 2. Interactive Drawing Canvas
              GestureDetector(
                onPanStart: _isDrawingMode
                    ? (details) {
                        setState(() {
                          _drawingPoints.add(
                            DrawingPoint(
                              offset: details.localPosition,
                              paint: Paint()
                                ..color = _selectedBrushColor
                                ..isAntiAlias = true
                                ..strokeWidth = 4.5
                                ..strokeCap = StrokeCap.round,
                            ),
                          );
                        });
                      }
                    : null,
                onPanUpdate: _isDrawingMode
                    ? (details) {
                        setState(() {
                          _drawingPoints.add(
                            DrawingPoint(
                              offset: details.localPosition,
                              paint: Paint()
                                ..color = _selectedBrushColor
                                ..isAntiAlias = true
                                ..strokeWidth = 4.5
                                ..strokeCap = StrokeCap.round,
                            ),
                          );
                        });
                      }
                    : null,
                onPanEnd: _isDrawingMode
                    ? (_) {
                        setState(() {
                          _drawingPoints.add(null);
                        });
                      }
                    : null,
                child: CustomPaint(
                  painter: DrawingPainter(points: _drawingPoints),
                  size: Size.infinite,
                ),
              ),

              // 3. Draggable Overlays (Text, Mention, Stickers)
              ..._overlayItems.map((item) {
                return Positioned(
                  left: item.position.dx,
                  top: item.position.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        item.position += details.delta;
                      });
                    },
                    child: Container(
                      padding: item.isEmoji
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                      decoration: item.isEmoji
                          ? null
                          : BoxDecoration(
                              color: item.bgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white24),
                            ),
                      child: Text(
                        item.text,
                        style: TextStyle(
                          color: item.textColor,
                          fontSize: item.isEmoji ? 42 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // 4. Drawing Color Palette (When Drawing Mode is active)
        if (_isDrawingMode)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.undo_rounded, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      if (_drawingPoints.isNotEmpty) {
                        _drawingPoints.clear();
                      }
                    });
                  },
                ),
                ..._brushColors.map((c) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBrushColor = c;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedBrushColor == c
                              ? Colors.white
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

        // 5. Top Editor Action Bar (Close, Aa Text, @ Mention, Stickers, Brush)
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 24),
                    onPressed: () {
                      setState(() {
                        _capturedMediaPath = null;
                        _isCanvasMode = false;
                        _drawingPoints.clear();
                        _overlayItems.clear();
                      });
                    },
                  ),
                  const Spacer(),
                  // Aa Text Tool
                  IconButton(
                    icon: const Icon(Icons.title_rounded,
                        color: Colors.white, size: 26),
                    onPressed: _openTextDialog,
                    tooltip: 'Add Text',
                  ),
                  // @ Mention Tool
                  IconButton(
                    icon: const Icon(Icons.alternate_email_rounded,
                        color: Colors.white, size: 24),
                    onPressed: _openMentionDialog,
                    tooltip: 'Mention Someone',
                  ),
                  // Stickers & Emojis
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined,
                        color: Colors.white, size: 26),
                    onPressed: _openStickersSheet,
                    tooltip: 'Add Stickers',
                  ),
                  // Brush / Doodle Tool
                  IconButton(
                    icon: Icon(
                      Icons.gesture_rounded,
                      color: _isDrawingMode
                          ? AppColors.primaryPurple
                          : Colors.white,
                      size: 26,
                    ),
                    onPressed: () {
                      setState(() {
                        _isDrawingMode = !_isDrawingMode;
                      });
                    },
                    tooltip: 'Draw on Story',
                  ),
                  // Change Background Gradient (if in canvas mode)
                  if (_capturedMediaPath == null)
                    IconButton(
                      icon: const Icon(Icons.palette_outlined,
                          color: Colors.white, size: 24),
                      onPressed: () {
                        setState(() {
                          _selectedGradientIndex =
                              (_selectedGradientIndex + 1) %
                                  _backgroundGradients.length;
                        });
                      },
                      tooltip: 'Change Background',
                    ),
                ],
              ),
            ),
          ),
        ),

        // 6. Bottom Bar (Caption + "Your Story" Share Button)
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Caption input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.2),
                    ),
                    child: TextField(
                      controller: _captionController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        hintText: 'Add a caption to your story...',
                        hintStyle:
                            TextStyle(color: Colors.white70, fontSize: 13.5),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Instagram "Your Story" Share Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _shareStory,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF833AB4), Color(0xFFFD1D1D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFD1D1D)
                                    .withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.person,
                                    color: Colors.white, size: 16),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Your Story',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapturedMediaImage(String pathOrUrl) {
    if (pathOrUrl.startsWith('http') ||
        pathOrUrl.startsWith('blob:') ||
        pathOrUrl.startsWith('data:')) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(color: const Color(0xFF0F172A)),
      );
    } else {
      if (!kIsWeb) {
        final f = File(pathOrUrl);
        if (f.existsSync()) {
          return Image.file(
            f,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: const Color(0xFF0F172A)),
          );
        }
      }
      return Container(color: const Color(0xFF0F172A));
    }
  }
}
