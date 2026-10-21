import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/chat_service.dart';
import '../../data/services/sound_generator.dart';
import 'camera_capture_page.dart';

class ChatDetailPage extends StatefulWidget {
  final String? conversationId;
  final String userName;
  final String userAvatar;
  final bool isOnline;
  final String? initialMessage;
  final String? initialTime;

  const ChatDetailPage({
    super.key,
    this.conversationId,
    required this.userName,
    required this.userAvatar,
    this.isOnline = false,
    this.initialMessage,
    this.initialTime,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  // Audio recording & playback
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _recordedAudioPath;

  late String _conversationId;
  List<ChatMessage> _messages = [];
  ChatMessage? _editingMessage;

  // Voice recording state
  bool _isRecordingVoice = false;
  int _voiceSeconds = 0;
  Timer? _voiceTimer;

  // Voice note playback state
  String? _currentlyPlayingId;
  double _playbackProgress = 0.0;
  int _currentDurationMs = 3000;

  // Video note recording state

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }
    _conversationId = widget.conversationId ??
        ChatService.instance.getConversationIdByName(
          widget.userName,
          avatarUrl: widget.userAvatar,
        );

    _initAudioListeners();
    _loadMessages();
  }

  void _initAudioListeners() {
    // Configure speakerphone audio context so voice notes play loud & clear through speakers
    try {
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playAndRecord,
            options: const {
              AVAudioSessionOptions.defaultToSpeaker,
            },
          ),
        ),
      );
    } catch (_) {}

    _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted || _currentlyPlayingId == null) return;
      if (duration.inMilliseconds > 0) {
        setState(() {
          _currentDurationMs = duration.inMilliseconds;
        });
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        setState(() {
          _currentlyPlayingId = null;
          _playbackProgress = 0.0;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted || _currentlyPlayingId == null) return;
      if (_currentDurationMs > 0) {
        setState(() {
          _playbackProgress =
              (position.inMilliseconds / _currentDurationMs).clamp(0.0, 1.0);
        });
      }
    });
  }

  void _loadMessages() {
    final loaded = ChatService.instance.getMessages(_conversationId);
    if (loaded.isEmpty &&
        widget.initialMessage != null &&
        widget.initialMessage!.isNotEmpty) {
      ChatService.instance.sendMessage(
        conversationId: _conversationId,
        text: widget.initialMessage!,
      );
      _messages = ChatService.instance.getMessages(_conversationId);
    } else {
      _messages = loaded;
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      BrowserContextMenu.enableContextMenu();
    }
    _messageController.dispose();
    _scrollController.dispose();
    _voiceTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_editingMessage != null) {
      final msgToEdit = _editingMessage!;
      if (DateTime.now().difference(msgToEdit.createdAt).inMinutes >= 15) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot edit message: 15-minute time window expired.'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
        _cancelEditing();
        return;
      }

      final success = ChatService.instance.editMessage(
        conversationId: _conversationId,
        messageId: msgToEdit.id,
        newText: text,
      );

      _editingMessage = null;
      _messageController.clear();

      if (success) {
        setState(() {
          _messages = ChatService.instance.getMessages(_conversationId);
        });
      }
      return;
    }

    ChatService.instance.sendMessage(
      conversationId: _conversationId,
      text: text,
    );

    setState(() {
      _messages = ChatService.instance.getMessages(_conversationId);
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _startEditingMessage(ChatMessage msg) {
    if (!msg.canEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot edit message: 15 minutes time limit exceeded.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _editingMessage = msg;
      _messageController.text = msg.text;
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingMessage = null;
      _messageController.clear();
    });
  }

  // --- Permission Request Handler ---
  Future<bool> _requestPermission(
    Permission permission,
    String featureName,
  ) async {
    if (kIsWeb) return true;
    try {
      final status = await permission.request();
      if (status.isGranted || status.isLimited) {
        return true;
      } else if (status.isPermanentlyDenied) {
        _showPermissionDeniedDialog(featureName, isPermanentlyDenied: true);
        return false;
      } else {
        _showPermissionDeniedDialog(featureName, isPermanentlyDenied: false);
        return false;
      }
    } catch (_) {
      return true;
    }
  }

  void _showPermissionDeniedDialog(
    String featureName, {
    required bool isPermanentlyDenied,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.security_rounded, color: AppColors.primaryPurple),
            const SizedBox(width: 8),
            Text(
              '$featureName Permission',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Fikraty needs access to your $featureName to send media in the chat. Please grant permission to continue.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (isPermanentlyDenied) {
                openAppSettings();
              }
            },
            child: Text(
              isPermanentlyDenied ? 'Open Settings' : 'Allow',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- Real Audio Recording via Microphone ---
  Future<void> _handleVoiceRecordTrigger() async {
    try {
      if (kIsWeb) {
        final hasPerm = await _audioRecorder.hasPermission();
        if (!hasPerm) {
          _showPermissionDeniedDialog('Microphone', isPermanentlyDenied: false);
          return;
        }
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.opus),
          path: '',
        );
      } else {
        final granted =
            await _requestPermission(Permission.microphone, 'Microphone');
        if (!granted) return;

        final tempDir = await getTemporaryDirectory();
        _recordedAudioPath =
            '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        if (await _audioRecorder.hasPermission()) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: _recordedAudioPath!,
          );
        }
      }
    } catch (_) {}

    setState(() {
      _isRecordingVoice = true;
      _voiceSeconds = 0;
    });

    _voiceTimer?.cancel();
    _voiceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _voiceSeconds++;
      });
    });
  }

  Future<void> _cancelVoiceRecording() async {
    _voiceTimer?.cancel();
    try {
      await _audioRecorder.stop();
      if (!kIsWeb && _recordedAudioPath != null) {
        final f = File(_recordedAudioPath!);
        if (f.existsSync()) f.deleteSync();
      }
    } catch (_) {}

    setState(() {
      _isRecordingVoice = false;
      _voiceSeconds = 0;
      _recordedAudioPath = null;
    });
  }

  Future<void> _sendVoiceRecording() async {
    _voiceTimer?.cancel();
    String? finalPath;
    try {
      finalPath = await _audioRecorder.stop();
    } catch (_) {}

    finalPath ??= _recordedAudioPath;
    final durationStr = _formatDuration(_voiceSeconds);

    ChatService.instance.sendMediaMessage(
      conversationId: _conversationId,
      type: MessageType.voice,
      mediaUrl: finalPath ?? 'voice_note',
      duration: durationStr,
    );

    setState(() {
      _isRecordingVoice = false;
      _voiceSeconds = 0;
      _recordedAudioPath = null;
      _messages = ChatService.instance.getMessages(_conversationId);
    });

    _scrollToBottom();
  }

  // --- Real Audio Playback via Device Speakers ---
  Future<void> _toggleAudioPlayback(ChatMessage msg) async {
    final totalDurationSeconds =
        _parseDurationSeconds(msg.duration ?? '0:03');

    if (_currentlyPlayingId == msg.id) {
      await _audioPlayer.pause();
      setState(() {
        _currentlyPlayingId = null;
      });
      return;
    }

    await _audioPlayer.stop();

    setState(() {
      _currentlyPlayingId = msg.id;
      _currentDurationMs = (totalDurationSeconds <= 0 ? 3 : totalDurationSeconds) * 1000;
      _playbackProgress = 0.0;
    });

    try {
      await _audioPlayer.setVolume(1.0);
      final mediaUrl = msg.mediaUrl ?? '';

      bool played = false;

      if (kIsWeb) {
        if (mediaUrl.startsWith('blob:') || mediaUrl.startsWith('http')) {
          await _audioPlayer.play(UrlSource(mediaUrl));
          played = true;
        }
      } else {
        if (mediaUrl.isNotEmpty && File(mediaUrl).existsSync()) {
          await _audioPlayer.play(DeviceFileSource(mediaUrl));
          played = true;
        } else if (mediaUrl.startsWith('http')) {
          await _audioPlayer.play(UrlSource(mediaUrl));
          played = true;
        }
      }

      // If local recording wasn't playable or is mock, play the synthesized clear voice chime
      // so sound is 100% guaranteed to come out of speakers!
      if (!played) {
        final toneBytes = SoundGenerator.generateVoiceNoteTone(
          durationSeconds: totalDurationSeconds.toDouble().clamp(1.5, 5.0),
        );
        await _audioPlayer.play(BytesSource(toneBytes, mimeType: 'audio/wav'));
      }
    } catch (_) {
      try {
        final toneBytes = SoundGenerator.generateVoiceNoteTone(
          durationSeconds: totalDurationSeconds.toDouble().clamp(1.5, 5.0),
        );
        await _audioPlayer.play(BytesSource(toneBytes, mimeType: 'audio/wav'));
      } catch (_) {}
    }
  }

  // --- Camera Shooting: Take Photo or Record Video Directly ---
  Future<void> _openCameraCapturePage({bool isVideo = false}) async {
    if (!kIsWeb) {
      final cameraGranted =
          await _requestPermission(Permission.camera, 'Camera');
      if (!cameraGranted) return;

      if (isVideo) {
        final micGranted =
            await _requestPermission(Permission.microphone, 'Microphone');
        if (!micGranted) return;
      }
    }

    if (!mounted) return;

    // Opens camera viewfinder directly with big shoot/record button!
    final result = await Navigator.push<CameraCaptureResult>(
      context,
      MaterialPageRoute(
        builder: (_) => CameraCapturePage(initialVideoMode: isVideo),
      ),
    );

    if (result != null) {
      if (!result.isVideo) {
        // Photo shot directly: send to chat immediately!
        _sendImageMessage(result.path);
      } else {
        // Video recorded directly: send to chat immediately!
        _sendVideoMessage(result.path, duration: result.duration);
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked != null) {
        _sendImageMessage(picked.path);
      }
    } catch (_) {
      _showPresetMediaPicker(isImage: true);
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final XFile? picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );

      if (picked != null) {
        _sendVideoMessage(picked.path);
      }
    } catch (_) {
      _showPresetMediaPicker(isImage: false);
    }
  }

  void _sendImageMessage(String imagePath, [String? caption]) {
    ChatService.instance.sendMediaMessage(
      conversationId: _conversationId,
      type: MessageType.image,
      mediaUrl: imagePath,
      text: caption,
    );

    setState(() {
      _messages = ChatService.instance.getMessages(_conversationId);
    });
    _scrollToBottom();
  }

  void _sendVideoMessage(String videoPath, {String? caption, String? duration}) {
    ChatService.instance.sendMediaMessage(
      conversationId: _conversationId,
      type: MessageType.video,
      mediaUrl: videoPath,
      text: caption,
      duration: duration ?? '0:35',
    );

    setState(() {
      _messages = ChatService.instance.getMessages(_conversationId);
    });
    _scrollToBottom();
  }

  Future<void> _pickDocument() async {
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (files.isNotEmpty) {
        final platformFile = files.first;
        final name = platformFile.name;
        final path = platformFile.path ?? name;

        ChatService.instance.sendMediaMessage(
          conversationId: _conversationId,
          type: MessageType.document,
          mediaUrl: path,
          fileName: name,
        );

        setState(() {
          _messages = ChatService.instance.getMessages(_conversationId);
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error picking document: $e');
    }
  }

  // --- Quick Circular Video Note Recording ---
  Future<void> _handleVideoNoteTrigger() async {
    if (!kIsWeb) {
      final cameraGranted =
          await _requestPermission(Permission.camera, 'Camera');
      if (!cameraGranted) return;

      final micGranted =
          await _requestPermission(Permission.microphone, 'Microphone');
      if (!micGranted) return;
    }

    if (!mounted) return;
    _showVideoNoteRecorderModal();
  }

  void _showVideoNoteRecorderModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return VideoNoteRecorderModal(
          onRecorded: (path, duration) {
            _sendVideoNoteMessage(path, duration: duration);
          },
        );
      },
    );
  }

  void _sendVideoNoteMessage(String videoPath, {required String duration}) {
    ChatService.instance.sendMediaMessage(
      conversationId: _conversationId,
      type: MessageType.videoNote,
      mediaUrl: videoPath,
      duration: duration,
    );

    setState(() {
      _messages = ChatService.instance.getMessages(_conversationId);
    });

    _scrollToBottom();
  }

  void _showGalleryTypePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_rounded, color: Color(0xFF6366F1)),
              title: const Text('Photos from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library_rounded,
                  color: Color(0xFF10B981)),
              title: const Text('Videos from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                _pickVideoFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WhatsApp-style Attachment Bottom Sheet ---
  void _showWhatsAppAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.insert_drive_file_rounded,
                    label: 'Document',
                    color: const Color(0xFF7C3AED),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickDocument();
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: const Color(0xFF6366F1),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showGalleryTypePicker();
                    },
                  ),
                  _buildAttachmentOption(
                    icon: Icons.videocam_rounded,
                    label: 'Video Note',
                    color: const Color(0xFF06B6D4),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleVideoNoteTrigger();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  void _showPresetMediaPicker({required bool isImage}) {
    final presets = isImage
        ? [
            {
              'title': 'Traction Metrics',
              'url':
                  'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800',
            },
            {
              'title': 'Founder Pitch',
              'url':
                  'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=800',
            },
            {
              'title': 'Product Architecture',
              'url':
                  'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800',
            },
          ]
        : [
            {
              'title': 'Product Demo Video',
              'url':
                  'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
            },
          ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isImage ? 'Select Image' : 'Select Video'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final item = presets[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    item['url']!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(item['title']!),
                onTap: () {
                  Navigator.pop(ctx);
                  if (isImage) {
                    _sendImageMessage(item['url']!, item['title']);
                  } else {
                    _sendVideoMessage(item['url']!, caption: item['title']);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: Image.network(
                    widget.userAvatar,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const CircleAvatar(
                      radius: 19,
                      backgroundColor: AppColors.purpleLight,
                      child: Icon(Icons.person, color: AppColors.primaryPurple),
                    ),
                  ),
                ),
                if (widget.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                if (widget.isOnline)
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Direct conversation with ${widget.userName}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg.isMe) {
                  return _buildMyMessage(msg);
                } else {
                  return _buildOtherMessage(msg);
                }
              },
            ),
          ),
          _buildBottomInputBar(),
        ],
      ),
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_editingMessage != null) _buildEditingBanner(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: _isRecordingVoice
                  ? _buildVoiceRecordingRow()
                  : _buildStandardInputRow(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditingBanner() {
    final remainingMinutes = 15 -
        DateTime.now().difference(_editingMessage!.createdAt).inMinutes;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.08),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: AppColors.primaryPurple,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Editing message',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${remainingMinutes > 0 ? remainingMinutes : 1}m left)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  _editingMessage!.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _cancelEditing,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: const Color(0xFF64748B),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceRecordingRow() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatDuration(_voiceSeconds),
          style: const TextStyle(
            color: Color(0xFFEF4444),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(12, (index) {
              final heights = [
                10.0, 18.0, 26.0, 14.0, 22.0, 30.0,
                16.0, 24.0, 12.0, 20.0, 28.0, 14.0
              ];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 3.5,
                height: heights[(index + _voiceSeconds) % heights.length],
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: _cancelVoiceRecording,
          icon: const Icon(Icons.delete_outline_rounded,
              color: Color(0xFF94A3B8), size: 24),
          tooltip: 'Cancel',
        ),
        GestureDetector(
          onTap: _sendVoiceRecording,
          child: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.primaryPurple,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardInputRow() {
    final hasText = _messageController.text.trim().isNotEmpty;

    return Row(
      children: [
        IconButton(
          onPressed: _showWhatsAppAttachmentSheet,
          icon: const Icon(
            Icons.attach_file_rounded,
            color: Color(0xFF64748B),
            size: 24,
          ),
          tooltip: 'Attach files',
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Message ${widget.userName}...',
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13.5,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                // Camera Button inside textfield:
                // Tap -> Opens CameraCapturePage (Take photo & shoot directly!)
                // Long press -> Video Note circular recording!
                GestureDetector(
                  onTap: () => _openCameraCapturePage(isVideo: false),
                  onLongPress: _handleVideoNoteTrigger,
                  child: const Tooltip(
                    message: 'Tap to Take Photo, Long press for Video Note',
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF64748B),
                        size: 21,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        hasText
            ? GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _editingMessage != null
                          ? Icons.check_rounded
                          : Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              )
            : GestureDetector(
                onTap: _handleVoiceRecordTrigger,
                onLongPress: _handleVoiceRecordTrigger,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC7D2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mic_rounded,
                      color: AppColors.primaryPurple,
                      size: 22,
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  void _onMessageDoubleTap(ChatMessage msg) {
    if (msg.isDeletedForEveryone) return;
    _toggleReaction(msg, '❤️');
  }

  void _toggleReaction(ChatMessage msg, String emoji) {
    ChatService.instance.toggleReaction(
      conversationId: _conversationId,
      messageId: msg.id,
      reactionEmoji: emoji,
    );

    setState(() {
      _messages = ChatService.instance.getMessages(_conversationId);
    });
  }

  void _showMessageContextMenu(ChatMessage msg, {Offset? position}) {
    if (msg.isDeletedForEveryone) {
      _showDeleteOptions(msg);
      return;
    }

    final quickEmojis = ['❤️', '👍', '😂', '😮', '😢', '🙏'];
    final moreEmojis = ['🔥', '👏', '🎉', '💡', '💯', '✨', '😍', '🤝', '🚀', '🥳'];

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'MessageContextMenu',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogCtx, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (dialogCtx, anim, secondaryAnim, child) {
        final media = MediaQuery.of(dialogCtx);
        final screenSize = media.size;
        final viewPadding = media.padding;

        const double menuWidth = 280.0;
        final double maxMenuHeight = screenSize.height * 0.70;

        // Clamped horizontal position to strictly prevent horizontal overflow
        double left;
        if (position != null) {
          final maxLeft = (screenSize.width - menuWidth - 16.0);
          left = (position.dx - (menuWidth / 2)).clamp(
            16.0,
            maxLeft > 16.0 ? maxLeft : 16.0,
          );
        } else {
          final centerLeft = (screenSize.width - menuWidth) / 2;
          left = centerLeft > 16.0 ? centerLeft : 16.0;
        }

        // Clamped vertical position to strictly prevent vertical overflow
        double? top;
        double? bottom;
        const double estimatedHeight = 260.0;

        if (position != null) {
          final spaceBelow = screenSize.height - position.dy - viewPadding.bottom;
          if (spaceBelow < estimatedHeight + 30) {
            bottom = (screenSize.height - position.dy + 8).clamp(
              viewPadding.bottom + 16,
              screenSize.height - 80,
            );
          } else {
            final maxTop = screenSize.height - estimatedHeight - viewPadding.bottom - 16;
            final minTop = viewPadding.top + 16;
            top = (position.dy + 8).clamp(
              minTop,
              maxTop > minTop ? maxTop : minTop,
            );
          }
        } else {
          final centerTop = (screenSize.height - estimatedHeight) / 2;
          final minTop = viewPadding.top + 16;
          top = centerTop > minTop ? centerTop : minTop;
        }

        bool showMore = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final minutesLeft =
                15 - DateTime.now().difference(msg.createdAt).inMinutes;

            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.pop(dialogCtx),
                    onSecondaryTap: () => Navigator.pop(dialogCtx),
                    child: const SizedBox.expand(),
                  ),
                ),
                Positioned(
                  left: left,
                  top: top,
                  bottom: bottom,
                  child: FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                        parent: anim,
                        curve: Curves.easeOutCubic,
                      ),
                      alignment: position != null
                          ? (top != null ? Alignment.topCenter : Alignment.bottomCenter)
                          : Alignment.center,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: menuWidth,
                          constraints: BoxConstraints(
                            maxHeight: maxMenuHeight,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ...quickEmojis.map((emoji) {
                                        final isSelected = msg.reaction == emoji;
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(dialogCtx);
                                            _toggleReaction(msg, emoji);
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 2),
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primaryPurple
                                                      .withValues(alpha: 0.15)
                                                  : Colors.transparent,
                                              shape: BoxShape.circle,
                                              border: isSelected
                                                  ? Border.all(
                                                      color: AppColors.primaryPurple,
                                                      width: 1.5)
                                                  : null,
                                            ),
                                            child: Text(
                                              emoji,
                                              style: const TextStyle(fontSize: 22),
                                            ),
                                          ),
                                        );
                                      }),
                                      GestureDetector(
                                        onTap: () {
                                          setDialogState(() {
                                            showMore = !showMore;
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 4),
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: showMore
                                                ? const Color(0xFFE2E8F0)
                                                : const Color(0xFFF1F5F9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            showMore
                                                ? Icons.close_rounded
                                                : Icons.add_rounded,
                                            size: 20,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (showMore) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.only(top: 8),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: Color(0xFFF1F5F9)),
                                      ),
                                    ),
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      alignment: WrapAlignment.center,
                                      children: moreEmojis.map((emoji) {
                                        final isSelected = msg.reaction == emoji;
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.pop(dialogCtx);
                                            _toggleReaction(msg, emoji);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primaryPurple
                                                      .withValues(alpha: 0.15)
                                                  : Colors.transparent,
                                              shape: BoxShape.circle,
                                              border: isSelected
                                                  ? Border.all(
                                                      color: AppColors.primaryPurple,
                                                      width: 1.5)
                                                  : null,
                                            ),
                                            child: Text(
                                              emoji,
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                const SizedBox(height: 6),
                                if (msg.canEdit)
                                  _buildMenuActionTile(
                                    icon: Icons.edit_outlined,
                                    iconColor: AppColors.primaryPurple,
                                    title: 'Edit',
                                    badge: '${minutesLeft > 0 ? minutesLeft : 1}m left',
                                    onTap: () {
                                      Navigator.pop(dialogCtx);
                                      _startEditingMessage(msg);
                                    },
                                  ),
                                if (msg.text.isNotEmpty && !msg.isDeletedForEveryone)
                                  _buildMenuActionTile(
                                    icon: Icons.copy_rounded,
                                    iconColor: const Color(0xFF64748B),
                                    title: 'Copy',
                                    onTap: () {
                                      Navigator.pop(dialogCtx);
                                      Clipboard.setData(ClipboardData(text: msg.text));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Copied to clipboard'),
                                          duration: Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                  ),
                                _buildMenuActionTile(
                                  icon: Icons.delete_outline_rounded,
                                  iconColor: const Color(0xFFEF4444),
                                  title: 'Delete',
                                  titleColor: const Color(0xFFEF4444),
                                  onTap: () {
                                    Navigator.pop(dialogCtx);
                                    _showDeleteOptions(msg);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMenuActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? AppColors.ink,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteOptions(ChatMessage msg) {
    final canDeleteForEveryone = msg.isMe && !msg.isDeletedForEveryone;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Delete message?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  canDeleteForEveryone
                      ? 'Choose how you want to delete this message.'
                      : 'This message will be removed from your chat.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                if (canDeleteForEveryone) ...[
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    tileColor: const Color(0xFFFEF2F2),
                    leading: const Icon(
                      Icons.delete_forever_rounded,
                      color: Color(0xFFDC2626),
                      size: 24,
                    ),
                    title: const Text(
                      'Delete for everyone',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                        fontSize: 15,
                      ),
                    ),
                    subtitle: const Text(
                      'Everyone in this chat will see that this message was deleted',
                      style: TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      ChatService.instance.deleteMessageForEveryone(
                        conversationId: _conversationId,
                        messageId: msg.id,
                      );
                      setState(() {
                        _messages =
                            ChatService.instance.getMessages(_conversationId);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: const Color(0xFFF8FAFC),
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFF475569),
                    size: 24,
                  ),
                  title: const Text(
                    'Delete for me',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: const Text(
                    'This message will be removed from this device only',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ChatService.instance.deleteMessageForMe(
                      conversationId: _conversationId,
                      messageId: msg.id,
                    );
                    setState(() {
                      _messages =
                          ChatService.instance.getMessages(_conversationId);
                    });
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubbleWithReaction(ChatMessage msg, {required bool isMe}) {
    final hasReaction =
        !msg.isDeletedForEveryone && msg.reaction != null && msg.reaction!.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onSecondaryTapDown: (details) =>
              _showMessageContextMenu(msg, position: details.globalPosition),
          onLongPressStart: (details) =>
              _showMessageContextMenu(msg, position: details.globalPosition),
          onDoubleTap: () => _onMessageDoubleTap(msg),
          child: _buildMessageContent(msg, isMe: isMe),
        ),
        if (hasReaction)
          Positioned(
            bottom: -9,
            right: isMe ? 8 : null,
            left: isMe ? null : 8,
            child: GestureDetector(
              onTapDown: (details) =>
                  _showMessageContextMenu(msg, position: details.globalPosition),
              onSecondaryTapDown: (details) =>
                  _showMessageContextMenu(msg, position: details.globalPosition),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.reaction!,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOtherMessage(ChatMessage msg) {
    final hasReaction =
        !msg.isDeletedForEveryone && msg.reaction != null && msg.reaction!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Image.network(
              widget.userAvatar,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageBubbleWithReaction(msg, isMe: false),
                SizedBox(height: hasReaction ? 10 : 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (msg.isEdited && !msg.isDeletedForEveryone) ...[
                        const SizedBox(width: 4),
                        const Text(
                          '· Edited',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMessage(ChatMessage msg) {
    final hasReaction =
        !msg.isDeletedForEveryone && msg.reaction != null && msg.reaction!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMessageBubbleWithReaction(msg, isMe: true),
                SizedBox(height: hasReaction ? 10 : 4),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (msg.isEdited && !msg.isDeletedForEveryone) ...[
                        const Text(
                          'Edited · ',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      Text(
                        msg.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (!msg.isDeletedForEveryone) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: Color(0xFF818CF8),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage msg, {required bool isMe}) {
    if (msg.isDeletedForEveryone) {
      return _buildDeletedBubble(msg, isMe: isMe);
    }

    switch (msg.messageType) {
      case MessageType.image:
        return _buildImageBubble(msg, isMe);
      case MessageType.voice:
        return _buildVoiceBubble(msg, isMe);
      case MessageType.video:
        return _buildVideoBubble(msg, isMe);
      case MessageType.videoNote:
        return _buildVideoNoteBubble(msg, isMe);
      case MessageType.document:
        return _buildDocumentBubble(msg, isMe);
      case MessageType.text:
        return _buildTextBubble(msg, isMe);
    }
  }

  Widget _buildDeletedBubble(ChatMessage msg, {required bool isMe}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 290),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.block_rounded,
            size: 16,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              isMe ? 'You deleted this message' : 'This message was deleted',
              style: TextStyle(
                fontSize: 13.5,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBubble(ChatMessage msg, bool isMe) {
    final hasStoryReply = msg.storyReply != null;
    final isEmoji = _isEmojiOnly(msg.text);

    return Container(
      constraints: const BoxConstraints(maxWidth: 290),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryPurple : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: isMe
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasStoryReply)
            _buildStoryReplyWidget(msg.storyReply!, isMe),
          Text(
            msg.text,
            style: TextStyle(
              fontSize: isEmoji ? 26 : 13.5,
              color: isMe ? AppColors.white : AppColors.ink,
              height: 1.35,
              fontWeight: isEmoji ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageBubble(ChatMessage msg, bool isMe) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(msg.mediaUrl ?? ''),
      onSecondaryTapDown: (details) =>
          _showMessageContextMenu(msg, position: details.globalPosition),
      onLongPressStart: (details) =>
          _showMessageContextMenu(msg, position: details.globalPosition),
      onDoubleTap: () => _onMessageDoubleTap(msg),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 270),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryPurple : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                width: 260,
                child: _buildMediaImage(msg.mediaUrl ?? ''),
              ),
            ),
            if (msg.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : AppColors.ink,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceBubble(ChatMessage msg, bool isMe) {
    final isPlaying = _currentlyPlayingId == msg.id;

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryPurple : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _toggleAudioPlayback(msg),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isMe ? Colors.white : AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isMe ? AppColors.primaryPurple : Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(22, (i) {
                    final waveHeights = [
                      6.0, 14.0, 22.0, 10.0, 18.0, 26.0, 12.0, 20.0,
                      8.0, 16.0, 24.0, 10.0, 18.0, 26.0, 12.0, 22.0,
                      14.0, 8.0, 16.0, 20.0, 12.0, 8.0
                    ];
                    final progressIndex = (_playbackProgress * 22).floor();
                    final isHighlighted = isPlaying && i <= progressIndex;

                    return Container(
                      width: 2.8,
                      height: waveHeights[i % waveHeights.length],
                      decoration: BoxDecoration(
                        color: isMe
                            ? (isHighlighted
                                ? const Color(0xFF67E8F9)
                                : Colors.white60)
                            : (isHighlighted
                                ? AppColors.primaryPurple
                                : const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      msg.duration ?? '0:14',
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe ? Colors.white70 : AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.mic_rounded,
                      size: 14,
                      color: isMe ? Colors.white60 : AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Video & Video Note Interactive Player Modals ---
  void _playVideoModal(ChatMessage msg) {
    showDialog(
      context: context,
      builder: (ctx) => InteractiveVideoPlayerDialog(
        message: msg,
        isVideoNote: false,
      ),
    );
  }

  void _playVideoNoteModal(ChatMessage msg) {
    showDialog(
      context: context,
      builder: (ctx) => InteractiveVideoPlayerDialog(
        message: msg,
        isVideoNote: true,
      ),
    );
  }


  Widget _buildVideoBubble(ChatMessage msg, bool isMe) {
    return GestureDetector(
      onTap: () => _playVideoModal(msg),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 270),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryPurple : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 180,
                    width: 260,
                    child: ChatVideoBubblePreview(
                      videoUrl: msg.mediaUrl ?? '',
                      isCircular: false,
                      width: 260,
                      height: 180,
                      fallback: _buildMediaImage(msg.mediaUrl ?? ''),
                    ),
                  ),
                  Container(
                    height: 180,
                    width: 260,
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 2),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.videocam_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            msg.duration ?? '0:35',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (msg.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : AppColors.ink,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoNoteBubble(ChatMessage msg, bool isMe) {
    return GestureDetector(
      onTap: () => _playVideoNoteModal(msg),
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isMe ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
            width: 3.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ChatVideoBubblePreview(
                videoUrl: msg.mediaUrl ?? '',
                isCircular: true,
                width: 170,
                height: 170,
                fallback: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF1E1B4B)],
                      radius: 0.85,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.videocam_rounded,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.black.withValues(alpha: 0.2),
              ),
              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF4F46E5),
                    size: 32,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, size: 8, color: Color(0xFFEF4444)),
                        const SizedBox(width: 4),
                        Text(
                          msg.duration ?? '0:05',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentBubble(ChatMessage msg, bool isMe) {
    final fileName = msg.fileName ?? 'Document';
    final ext = fileName.contains('.') ? fileName.split('.').last.toUpperCase() : 'DOC';
    final isPdf = ext == 'PDF';

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryPurple : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.2)
                  : (isPdf ? const Color(0xFFFEE2E2) : AppColors.purpleLight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
              color: isMe
                  ? Colors.white
                  : (isPdf ? const Color(0xFFDC2626) : AppColors.primaryPurple),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isMe ? Colors.white : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$ext · File',
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.white70 : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.download_rounded,
            size: 20,
            color: isMe ? Colors.white70 : AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryReplyWidget(StoryReplyInfo storyReply, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.black.withValues(alpha: 0.22)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? Colors.white24 : const Color(0xFFCBD5E1),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 42,
              height: 56,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    storyReply.storyImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.primaryPurple,
                      child: const Center(
                        child: Icon(
                          Icons.history_edu_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.reply_rounded,
                      size: 13,
                      color: isMe ? Colors.white : AppColors.primaryPurple,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Replied to story',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isMe ? Colors.white : AppColors.primaryPurple,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  storyReply.storyCaption.isNotEmpty
                      ? storyReply.storyCaption
                      : 'Story by ${storyReply.storyAuthorName}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white70 : const Color(0xFF64748B),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaImage(String pathOrUrl) {
    if (pathOrUrl.startsWith('http') ||
        pathOrUrl.startsWith('blob:') ||
        pathOrUrl.startsWith('data:')) {
      return Image.network(
        pathOrUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildMediaFallback(),
      );
    } else {
      if (!kIsWeb && pathOrUrl.isNotEmpty) {
        final f = File(pathOrUrl);
        final lower = pathOrUrl.toLowerCase();
        final isVideo = lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi');
        if (f.existsSync() && !isVideo) {
          return Image.file(
            f,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildMediaFallback(),
          );
        }
      }
      return _buildMediaFallback();
    }
  }

  Widget _buildMediaFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_display_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Video Attachment',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: _buildMediaImage(url),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isEmojiOnly(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final emojis = {
      '❤️', '🔥', '👏', '🚀', '😍', '💡', '💯', '👍', '🎉', '🙌', '✨', '🥰', '🤩'
    };
    return emojis.contains(trimmed);
  }

  int _parseDurationSeconds(String duration) {
    final parts = duration.split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]) ?? 0;
      final s = int.tryParse(parts[1]) ?? 0;
      return m * 60 + s;
    }
    return 3;
  }
}

class VideoNoteRecorderModal extends StatefulWidget {
  final Function(String path, String duration) onRecorded;

  const VideoNoteRecorderModal({super.key, required this.onRecorded});

  @override
  State<VideoNoteRecorderModal> createState() => _VideoNoteRecorderModalState();
}

class _VideoNoteRecorderModalState extends State<VideoNoteRecorderModal> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isRecording = false;
  int _seconds = 0;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'No camera found on this device';
        });
        return;
      }

      CameraDescription selected = cameras.first;
      for (final cam in cameras) {
        if (cam.lensDirection == CameraLensDirection.front) {
          selected = cam;
          break;
        }
      }

      final controller = CameraController(
        selected,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Camera access error: $e';
      });
    }
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_isInitialized || _isRecording) return;
    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _seconds = 0;
      });

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          _seconds++;
        });
        if (_seconds >= 60) {
          _stopAndSend();
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  Future<void> _stopAndSend() async {
    if (_controller == null || !_isRecording) return;
    _timer?.cancel();
    try {
      final file = await _controller!.stopVideoRecording();
      final m = _seconds ~/ 60;
      final s = _seconds % 60;
      final durationStr = '$m:${s.toString().padLeft(2, '0')}';
      String finalPath = file.path;
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final mediaDir = Directory('${appDir.path}/fikraty_media');
        if (!await mediaDir.exists()) {
          await mediaDir.create(recursive: true);
        }
        final persistentPath = '${mediaDir.path}/VNOTE_${DateTime.now().millisecondsSinceEpoch}.mp4';
        await File(file.path).copy(persistentPath);
        finalPath = persistentPath;
      } catch (_) {}
      if (!mounted) return;
      Navigator.pop(context);
      widget.onRecorded(finalPath, durationStr);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to finish recording: $e')),
      );
    }
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();
    if (_isRecording && _controller != null) {
      try {
        await _controller!.stopVideoRecording();
      } catch (_) {}
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'REC ${_formatDuration(_seconds)} / 1:00',
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Row(
                  children: [
                    Icon(Icons.videocam_rounded, color: Colors.white70, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Video Note',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: _cancelRecording,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _isRecording ? const Color(0xFFEF4444) : AppColors.primaryPurple,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? const Color(0xFFEF4444) : AppColors.primaryPurple)
                      .withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: _buildCameraFeed(),
            ),
          ),
          const SizedBox(height: 24),
          if (!_isRecording)
            ElevatedButton.icon(
              onPressed: _isInitialized ? _startRecording : null,
              icon: const Icon(Icons.fiber_manual_record_rounded, color: Colors.white, size: 22),
              label: const Text(
                'Start Recording',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                disabledBackgroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _cancelRecording,
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70, size: 28),
                  tooltip: 'Cancel',
                ),
                ElevatedButton.icon(
                  onPressed: _stopAndSend,
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  label: const Text(
                    'Send Video Note',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCameraFeed() {
    if (_errorMessage != null) {
      return Container(
        color: const Color(0xFF1E293B),
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      );
    }
    if (!_isInitialized || _controller == null) {
      return Container(
        color: const Color(0xFF1E293B),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
          ),
        ),
      );
    }

    return CameraPreview(_controller!);
  }
}

class ChatVideoBubblePreview extends StatefulWidget {
  final String videoUrl;
  final bool isCircular;
  final double width;
  final double height;
  final Widget fallback;

  const ChatVideoBubblePreview({
    super.key,
    required this.videoUrl,
    required this.isCircular,
    required this.width,
    required this.height,
    required this.fallback,
  });

  @override
  State<ChatVideoBubblePreview> createState() => _ChatVideoBubblePreviewState();
}

class _ChatVideoBubblePreviewState extends State<ChatVideoBubblePreview> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initPreview();
  }

  @override
  void didUpdateWidget(covariant ChatVideoBubblePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _initPreview();
    }
  }

  Future<void> _initPreview() async {
    final path = widget.videoUrl.trim();
    if (path.isEmpty) return;

    try {
      if (path.startsWith('http://') ||
          path.startsWith('https://') ||
          path.startsWith('blob:')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(path));
      } else {
        File? fileToUse;
        final file = File(path);
        if (await file.exists()) {
          fileToUse = file;
        } else {
          final baseName = path.split('/').last.split(r'\').last;
          try {
            final appDir = await getApplicationDocumentsDirectory();
            final candidate1 = File('${appDir.path}/fikraty_media/$baseName');
            final candidate2 = File('${appDir.path}/chat_videos/$baseName');
            if (await candidate1.exists()) {
              fileToUse = candidate1;
            } else if (await candidate2.exists()) {
              fileToUse = candidate2;
            }
          } catch (_) {}
        }
        if (fileToUse != null) {
          _controller = VideoPlayerController.file(fileToUse);
        } else {
          return;
        }
      }

      await _controller!.initialize();
      await _controller!.setVolume(0.0);
      await _controller!.pause();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (_) {
      // Gracefully fallback if preview fails to decode
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized && _controller != null) {
      final videoContent = SizedBox(
        width: widget.width,
        height: widget.height,
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _controller!.value.size.width > 0
                ? _controller!.value.size.width
                : widget.width,
            height: _controller!.value.size.height > 0
                ? _controller!.value.size.height
                : widget.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      );

      if (widget.isCircular) {
        return ClipOval(child: videoContent);
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: videoContent,
      );
    }

    return widget.fallback;
  }
}

class InteractiveVideoPlayerDialog extends StatefulWidget {
  final ChatMessage message;
  final bool isVideoNote;

  const InteractiveVideoPlayerDialog({
    super.key,
    required this.message,
    required this.isVideoNote,
  });

  @override
  State<InteractiveVideoPlayerDialog> createState() =>
      _InteractiveVideoPlayerDialogState();
}

class _InteractiveVideoPlayerDialogState
    extends State<InteractiveVideoPlayerDialog> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final path = widget.message.mediaUrl?.trim() ?? '';
    if (path.isEmpty) {
      setState(() {
        _errorMessage = 'No video media found';
      });
      return;
    }

    try {
      if (path.startsWith('http://') ||
          path.startsWith('https://') ||
          path.startsWith('blob:')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(path));
      } else {
        File? fileToUse;
        final file = File(path);
        if (await file.exists()) {
          fileToUse = file;
        } else {
          final baseName = path.split('/').last.split(r'\').last;
          try {
            final appDir = await getApplicationDocumentsDirectory();
            final candidate1 = File('${appDir.path}/fikraty_media/$baseName');
            final candidate2 = File('${appDir.path}/chat_videos/$baseName');
            if (await candidate1.exists()) {
              fileToUse = candidate1;
            } else if (await candidate2.exists()) {
              fileToUse = candidate2;
            }
          } catch (_) {}
        }
        if (fileToUse != null) {
          _controller = VideoPlayerController.file(fileToUse);
        } else {
          final baseName = path.split('/').last.split(r'\').last;
          setState(() {
            _errorMessage = 'Recorded Video Clip (${widget.message.duration ?? "0:03"})\nFile saved: $baseName';
          });
          return;
        }
      }

      await _controller!.initialize();
      _controller!.addListener(_onPlayerUpdate);
      await _controller!.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = true;
          _duration = _controller!.value.duration;
        });
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Could not load video player';
        if (e is PlatformException && (e.code == 'channel-error' || e.message?.contains('connection on channel') == true)) {
          msg = 'Video recorded & saved!\n\nTo activate native hardware video rendering, please restart the app with a full rebuild (flutter run).';
        }
        setState(() {
          _errorMessage = msg;
        });
      }
    }
  }

  void _onPlayerUpdate() {
    if (!mounted || _controller == null) return;
    final value = _controller!.value;
    setState(() {
      _position = value.position;
      _duration = value.duration;
      _isPlaying = value.isPlaying;
    });
  }

  Future<void> _togglePlayPause() async {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      await _controller!.pause();
    } else {
      if (_controller!.value.position >= _controller!.value.duration) {
        await _controller!.seekTo(Duration.zero);
      }
      await _controller!.play();
    }
  }

  Future<void> _replay() async {
    if (_controller == null || !_isInitialized) return;
    await _controller!.seekTo(Duration.zero);
    await _controller!.play();
  }

  Future<void> _toggleMute() async {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
    });
    await _controller!.setVolume(_isMuted ? 0.0 : 1.0);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onPlayerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, "0")}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: widget.isVideoNote ? _buildVideoNoteView() : _buildStandardVideoView(),
    );
  }

  Widget _buildVideoNoteView() {
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress indicator track around video note
            SizedBox(
              width: 270,
              height: 270,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF818CF8)),
                backgroundColor: const Color(0xFF312E81),
              ),
            ),
            // The circular video
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F172A),
                  border: Border.all(color: const Color(0xFF6366F1), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.45),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_isInitialized && _controller != null)
                        FittedBox(
                          fit: BoxFit.cover,
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        )
                      else if (_errorMessage != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        )
                      else
                        const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF818CF8)),
                          ),
                        ),
                      if (!_isPlaying && _isInitialized)
                        Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Time badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Text(
            '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 18),
        // Controls: Replay, Play/Pause, Mute, Close
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filled(
              onPressed: _replay,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.replay_rounded),
              tooltip: 'Replay',
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: _togglePlayPause,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
              ),
              icon: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 28,
              ),
              tooltip: _isPlaying ? 'Pause' : 'Play',
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: _toggleMute,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
              ),
              icon: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              ),
              tooltip: _isMuted ? 'Unmute' : 'Mute',
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF334155),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Close',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStandardVideoView() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.videocam_rounded,
                      color: Color(0xFF818CF8), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    widget.message.text.isNotEmpty
                        ? widget.message.text
                        : 'Video Player',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Video viewport
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  if (_isInitialized && _controller != null)
                    Center(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio > 0
                            ? _controller!.value.aspectRatio
                            : (16 / 9),
                        child: VideoPlayer(_controller!),
                      ),
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF818CF8)),
                      ),
                    ),
                  if (!_isPlaying && _isInitialized)
                    Center(
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70, width: 2),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Scrubber slider
          if (_isInitialized)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 3,
                activeTrackColor: const Color(0xFF818CF8),
                inactiveTrackColor: const Color(0xFF334155),
                thumbColor: const Color(0xFF818CF8),
              ),
              child: Slider(
                value: _position.inMilliseconds
                    .clamp(0, _duration.inMilliseconds)
                    .toDouble(),
                max: _duration.inMilliseconds.toDouble() > 0
                    ? _duration.inMilliseconds.toDouble()
                    : 1.0,
                onChanged: (val) {
                  _controller?.seekTo(Duration(milliseconds: val.toInt()));
                },
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_rounded,
                        color: Colors.white70, size: 22),
                    onPressed: _replay,
                    tooltip: 'Replay',
                  ),
                  IconButton(
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_filled_rounded,
                      color: const Color(0xFF818CF8),
                      size: 32,
                    ),
                    onPressed: _togglePlayPause,
                    tooltip: _isPlaying ? 'Pause' : 'Play',
                  ),
                  IconButton(
                    icon: Icon(
                      _isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                    onPressed: _toggleMute,
                    tooltip: _isMuted ? 'Unmute' : 'Mute',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
