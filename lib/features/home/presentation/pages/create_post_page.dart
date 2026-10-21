import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/post.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';

class PostAttachment {
  final String path;
  final String name;
  final int sizeInBytes;
  final bool isImage;
  final bool isPdf;
  final Uint8List? bytes;

  PostAttachment({
    required this.path,
    required this.name,
    required this.sizeInBytes,
    required this.isImage,
    required this.isPdf,
    this.bytes,
  });

  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  PostType _selectedType = PostType.update;
  final List<String> _selectedTags = ['#StartupUpdate'];
  final List<PostAttachment> _attachedFiles = [];
  final List<String> _attachedMedia = [];

  final List<String> _availableTags = [
    '#FinTech',
    '#SeedRound',
    '#AIStartups',
    '#HealthTech',
    '#MENA',
    '#EdTech',
    '#StartupUpdate',
    '#Founders',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    _pollQuestionController.dispose();
    for (var c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _attachedFiles.add(
            PostAttachment(
              path: image.path,
              name: image.name,
              sizeInBytes: bytes.length,
              isImage: true,
              isPdf: false,
              bytes: bytes,
            ),
          );
        });
      }
    } catch (_) {
      _pickFilesFallback(FileType.image);
    }
  }

  Future<void> _pickPdf() async {
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (files.isNotEmpty) {
        final f = files.first;
        final bytes = await f.readAsBytes();
        final len = await f.length() ?? bytes.length;
        setState(() {
          _attachedFiles.add(
            PostAttachment(
              path: f.path ?? f.name,
              name: f.name,
              sizeInBytes: len,
              isImage: false,
              isPdf: true,
              bytes: bytes,
            ),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick PDF: $e')),
      );
    }
  }

  Future<void> _pickAnyFile() async {
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.any,
      );
      if (files.isNotEmpty) {
        final f = files.first;
        final ext = f.extension?.toLowerCase() ?? '';
        final isImg = ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext);
        final isPdf = ext == 'pdf';
        final bytes = await f.readAsBytes();
        final len = await f.length() ?? bytes.length;
        setState(() {
          _attachedFiles.add(
            PostAttachment(
              path: f.path ?? f.name,
              name: f.name,
              sizeInBytes: len,
              isImage: isImg,
              isPdf: isPdf,
              bytes: bytes,
            ),
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  Future<void> _pickFilesFallback(FileType type) async {
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: type,
      );
      if (files.isNotEmpty) {
        final f = files.first;
        final ext = f.extension?.toLowerCase() ?? '';
        final isImg = ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext);
        final isPdf = ext == 'pdf';
        final bytes = await f.readAsBytes();
        final len = await f.length() ?? bytes.length;
        setState(() {
          _attachedFiles.add(
            PostAttachment(
              path: f.path ?? f.name,
              name: f.name,
              sizeInBytes: len,
              isImage: isImg,
              isPdf: isPdf,
              bytes: bytes,
            ),
          );
        });
      }
    } catch (_) {}
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Add Attachment to Post',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.purpleLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.image_rounded,
                        color: AppColors.primaryPurple),
                  ),
                  title: const Text('Photo / Image',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('JPG, PNG, WebP from gallery or files',
                      style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded,
                        color: Color(0xFFEF4444)),
                  ),
                  title: const Text('PDF Document',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Pitch deck, financial model, reports',
                      style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickPdf();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.attach_file_rounded,
                        color: Color(0xFF10B981)),
                  ),
                  title: const Text('Any Device File',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Documents, spreadsheets, zip archives',
                      style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAnyFile();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitPost() {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter post content')),
      );
      return;
    }

    String? pollQuestion;
    List<String>? pollOptions;

    if (_selectedType == PostType.poll) {
      pollQuestion = _pollQuestionController.text.trim();
      if (pollQuestion.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a poll question')),
        );
        return;
      }
      pollOptions = _pollOptionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      if (pollOptions.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter at least 2 poll options')),
        );
        return;
      }
    }

    final mediaUrls = _attachedFiles.isNotEmpty
        ? _attachedFiles.map((f) => f.path).toList()
        : _attachedMedia;

    context.read<FeedBloc>().add(
          CreatePostEvent(
            content: content,
            postType: _selectedType,
            tags: _selectedTags,
            mediaUrls: mediaUrls,
            pollQuestion: pollQuestion,
            pollOptions: pollOptions,
          ),
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text(
                'Publish',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info row
            Row(
              children: [
                ClipOval(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You (Founder)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      'Founder @ Fikraty Startup',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Select Post Type row
            const Text(
              'Select Post Category:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip(PostType.update, 'Update', Icons.edit_note),
                  _buildTypeChip(
                      PostType.funding, 'Funding', Icons.monetization_on_outlined),
                  _buildTypeChip(
                      PostType.insight, 'Insight', Icons.lightbulb_outline),
                  _buildTypeChip(
                      PostType.opportunity, 'Opportunity', Icons.handshake_outlined),
                  _buildTypeChip(
                      PostType.poll, 'Poll', Icons.poll_outlined),
                  _buildTypeChip(
                      PostType.milestone, 'Milestone', Icons.flag_outlined),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Content TextField
            TextField(
              controller: _contentController,
              maxLines: 6,
              style: const TextStyle(fontSize: 15, height: 1.5),
              decoration: const InputDecoration(
                hintText:
                    'Share your startup wins, metrics, pitch decks, questions or new rounds...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
              ),
            ),
            // Poll Fields (if poll selected)
            if (_selectedType == PostType.poll) ...[
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 10),
              const Text(
                'Poll Question & Options',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _pollQuestionController,
                decoration: InputDecoration(
                  hintText: 'Ask a question...',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ..._pollOptionControllers.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: entry.value,
                    decoration: InputDecoration(
                      hintText: 'Option ${entry.key + 1}',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                );
              }),
              if (_pollOptionControllers.length < 4)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _pollOptionControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add, color: AppColors.primaryPurple),
                  label: const Text('Add Option'),
                ),
            ],

            // Attached Files Previews (Images, PDFs, Documents)
            if (_attachedFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                children: _attachedFiles.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final att = entry.value;
                  return _buildAttachmentPreview(att, idx);
                }).toList(),
              ),
            ],

            if (_attachedMedia.isNotEmpty && _attachedFiles.isEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _attachedMedia.first,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0)),
            // Tags selector
            const Text(
              'Add Tags:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  selectedColor: AppColors.purpleLight,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryPurple
                        : AppColors.textSecondary,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Bottom Action buttons (Photo, PDF, Attachment, Poll)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Attach:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Image
                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined,
                        color: AppColors.primaryPurple),
                    tooltip: 'Attach Image / Photo',
                  ),
                  // PDF Document
                  IconButton(
                    onPressed: _pickPdf,
                    icon: const Icon(Icons.picture_as_pdf_outlined,
                        color: Color(0xFFEF4444)),
                    tooltip: 'Attach PDF Document',
                  ),
                  // Any File
                  IconButton(
                    onPressed: _showAttachmentOptions,
                    icon: const Icon(Icons.attach_file_rounded,
                        color: AppColors.ink),
                    tooltip: 'Attach Any File',
                  ),
                  const Spacer(),
                  // Add Poll
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = PostType.poll;
                      });
                    },
                    icon: const Icon(Icons.poll_outlined,
                        color: AppColors.primaryPurple),
                    tooltip: 'Add Poll',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview(PostAttachment att, int index) {
    if (att.isImage) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: att.bytes != null
                  ? Image.memory(
                      att.bytes!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : (!kIsWeb && File(att.path).existsSync()
                      ? Image.file(
                          File(att.path),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 120,
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: Icon(Icons.image,
                                size: 40, color: AppColors.textMuted),
                          ),
                        )),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _attachedFiles.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // PDF or Other Document
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: att.isPdf
                  ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                  : AppColors.primaryPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              att.isPdf
                  ? Icons.picture_as_pdf_rounded
                  : Icons.insert_drive_file_rounded,
              color: att.isPdf ? const Color(0xFFEF4444) : AppColors.primaryPurple,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  att.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${att.formattedSize} · ${att.isPdf ? 'PDF Document' : 'Attachment File'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
            onPressed: () {
              setState(() {
                _attachedFiles.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(PostType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? AppColors.white : AppColors.primaryPurple,
        ),
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primaryPurple,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.white : AppColors.ink,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (val) {
          if (val) {
            setState(() {
              _selectedType = type;
            });
          }
        },
      ),
    );
  }
}
