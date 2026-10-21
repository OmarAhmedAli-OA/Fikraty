import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../startups/domain/entities/startups.dart';
import '../../../startups/presentation/bloc/startups_bloc.dart';
import '../../../startups/presentation/bloc/startups_event.dart';

class SubmitVerificationPage extends StatefulWidget {
  const SubmitVerificationPage({super.key, required this.startup});
  
  final StartupEntity startup;

  @override
  State<SubmitVerificationPage> createState() => _SubmitVerificationPageState();
}

class _SubmitVerificationPageState extends State<SubmitVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _regNumberController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedDocType = 'Commercial Register (Official)';
  bool _fileAttached = false;
  String? _attachedFileName;

  final List<String> _docTypes = [
    'Commercial Register (Official)',
    'Tax Identification Card',
  ];

  @override
  void dispose() {
    _regNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );

      if (file != null) {
        setState(() {
          _fileAttached = true;
          _attachedFileName = file.name;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Document attached: ${file.name}'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not attach document: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDocumentSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Legal Document',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Attach an official copy or photo of your legal credential',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.navy),
                ),
                title: const Text('Capture with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Take a live, clear photo of the physical document'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickDocument(ImageSource.camera);
                },
              ),
              const Divider(height: 10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.tint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.blue),
                ),
                title: const Text('Select from Gallery / Device Files', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Upload a scanned document from your device'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickDocument(ImageSource.gallery);
                },
              ),
              if (_fileAttached) ...[
                const Divider(height: 10),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  ),
                  title: const Text('Remove Attached Document', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _fileAttached = false;
                      _attachedFileName = null;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_fileAttached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload or attach your official legal document'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<StartupsBloc>().add(
          SubmitVerificationEvent(
            startupId: widget.startup.id,
            documentType: _selectedDocType,
            registrationNumber: _regNumberController.text.trim(),
            note: _notesController.text.trim(),
          ),
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 45,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Verification Submitted Successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The Fikraty compliance team will review your submitted legal credentials and update verification status within 24 to 48 business hours.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back to My Startup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        title: const Text(
          'Request Startup Verification',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.blue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded,
                        color: AppColors.navy, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.startup.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Verified startups receive the blue trust badge and attract 3x more investor deal flow.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.ink,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Legal Credentials & Verification Info',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 14),

              // Document Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedDocType,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Document Type *',
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.description_rounded, color: AppColors.navy),
                ),
                items: _docTypes
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(
                            d,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDocType = v!),
              ),

              const SizedBox(height: 16),

              // Registration Number
              TextFormField(
                controller: _regNumberController,
                decoration: const InputDecoration(
                  labelText: 'Official Registration / License Number *',
                  hintText: 'e.g. 1010456789',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers_rounded, color: AppColors.navy),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Registration or license number is required'
                    : null,
              ),

              const SizedBox(height: 16),

              // File Upload Box
              InkWell(
                onTap: _showDocumentSourceModal,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _fileAttached ? AppColors.success : AppColors.border,
                      width: _fileAttached ? 2 : 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _fileAttached
                            ? Icons.verified_rounded
                            : Icons.cloud_upload_outlined,
                        size: 44,
                        color: _fileAttached ? AppColors.success : AppColors.textMuted,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _fileAttached
                            ? (_attachedFileName ?? 'Document Attached')
                            : 'Click to capture photo or select official credential',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _fileAttached ? AppColors.navy : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fileAttached
                            ? 'File ready for verification review'
                            : 'Accepted formats: Camera photo, Gallery scan, Image file',
                        style: TextStyle(
                          fontSize: 11,
                          color: _fileAttached ? AppColors.success : AppColors.textMuted,
                          fontWeight: _fileAttached ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _showDocumentSourceModal,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.navy,
                              side: const BorderSide(color: AppColors.navy),
                            ),
                            icon: const Icon(Icons.attach_file_rounded, size: 18),
                            label: Text(_fileAttached ? 'Change Document' : 'Upload Document'),
                          ),
                          if (_fileAttached) ...[
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _fileAttached = false;
                                  _attachedFileName = null;
                                });
                              },
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                              tooltip: 'Remove document',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Additional Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes for Compliance Review (Optional)',
                  hintText: 'Any specific context regarding your company registration...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              SafeArea(
                top: false,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded),
                    label: const Text(
                      'Submit Verification Request',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
}
