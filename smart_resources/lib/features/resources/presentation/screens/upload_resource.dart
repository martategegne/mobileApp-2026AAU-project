import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:smart_resources/core/theme/app_colors.dart';
import 'package:smart_resources/core/widgets/custom_button.dart';
import 'package:smart_resources/core/widgets/custom_text_field.dart';
import 'package:smart_resources/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_resources/features/resources/data/models/resource_model.dart';
import 'package:smart_resources/features/resources/presentation/providers/resource_notifier.dart';

class UploadResource extends ConsumerStatefulWidget {
  final bool isAdmin;
  final ResourceModel? resourceToEdit;

  const UploadResource({super.key, required this.isAdmin, this.resourceToEdit});

  @override
  ConsumerState<UploadResource> createState() => _UploadResourceState();
}

class _UploadResourceState extends ConsumerState<UploadResource> {
  late TextEditingController _titleController;
  late TextEditingController _courseCodeController;
  late TextEditingController _descriptionController;

  String _selectedFileType = 'PDF';
  String _selectedCategory = 'Lecture Notes';

  // File bytes are used on all platforms (web has no path access)
  List<int>? _pickedFileBytes;
  String? _pickedFileName;

  final List<String> _fileTypes = ['PDF', 'DOCX', 'PPTX', 'ZIP'];
  final List<String> _categories = [
    'Lecture Notes',
    'Study Guide',
    'Past Exam',
    'Assignment',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.resourceToEdit?.title ?? '',
    );
    _courseCodeController = TextEditingController(
      text: widget.resourceToEdit?.courseCode ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.resourceToEdit?.description ?? '',
    );
    if (widget.resourceToEdit != null) {
      _selectedFileType = widget.resourceToEdit!.fileType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        withData: true, // Always request bytes — works on web + mobile
        allowedExtensions: ['pdf', 'docx', 'pptx', 'zip'],
        type: FileType.custom,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _pickedFileBytes = result.files.single.bytes!.toList();
          _pickedFileName = result.files.single.name;
          final extension = result.files.single.extension?.toUpperCase();
          if (extension != null && _fileTypes.contains(extension)) {
            _selectedFileType = extension;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  Future<void> _handleUpload() async {
    final title = _titleController.text.trim();
    final courseCode = _courseCodeController.text.trim();
    final description = _descriptionController.text.trim();
    final authState = ref.read(authNotifierProvider);
    final user = authState.user;

    if (title.isEmpty || courseCode.isEmpty || description.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (widget.resourceToEdit == null && _pickedFileBytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    if (widget.resourceToEdit != null) {
      // Editing existing resource — metadata update only
      final updatedResource = widget.resourceToEdit!.copyWith(
        title: title,
        courseCode: courseCode,
        description: description,
        fileType: _selectedFileType,
      );
      try {
        await ref
            .read(resourceNotifierProvider.notifier)
            .updateResource(updatedResource);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resource updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go(
            widget.isAdmin ? '/admin/resources' : '/student/resources',
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    } else {
      final resource = ResourceModel(
        id: 'res-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        courseCode: courseCode,
        rating: 0.0,
        reviewCount: 0,
        uses: 0,
        fileType: _selectedFileType,
        uploader: user?.name ?? 'Anonymous',
        isApproved: widget.isAdmin,
        isBookmarked: false,
        isDownloaded: false,
        filePath: null, // Server assigns this after storing the file
      );

      try {
        await ref
            .read(resourceNotifierProvider.notifier)
            .uploadResource(
              resource,
              fileBytes: _pickedFileBytes,
              fileName: _pickedFileName,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Force full refresh so new resource appears immediately
          ref.invalidate(resourceNotifierProvider);
          context.go(
            widget.isAdmin ? '/admin/resources' : '/student/resources',
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(
                      widget.isAdmin
                          ? '/admin/resources'
                          : '/student/resources',
                    ),
                    child: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.resourceToEdit != null
                        ? 'Edit Resource'
                        : 'Upload Resource',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File picker box
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _pickedFileBytes != null
                                ? AppColors.primary
                                : theme.dividerColor,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _pickedFileBytes != null
                                  ? Icons.file_present
                                  : Icons.cloud_upload_outlined,
                              size: 36,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _pickedFileName ??
                                  'Tap to select file from device',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_pickedFileName == null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'PDF, DOCX, PPTX, or ZIP',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.45),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Title *',
                      hintText: 'e.g. Midterm Study Guide',
                      controller: _titleController,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Course Code *',
                            hintText: 'e.g. CS101',
                            controller: _courseCodeController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'File Type',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  border: Border.all(color: theme.dividerColor),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedFileType,
                                    isExpanded: true,
                                    dropdownColor: theme.cardColor,
                                    items: _fileTypes
                                        .map(
                                          (t) => DropdownMenuItem(
                                            value: t,
                                            child: Text(
                                              t,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedFileType = v!),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Category',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          dropdownColor: theme.cardColor,
                          items: _categories
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Description *',
                      hintText: "Describe what's included in this resource...",
                      maxLines: 4,
                      controller: _descriptionController,
                    ),
                    const SizedBox(height: 28),
                    CustomButton(
                      label: widget.resourceToEdit != null
                          ? 'Update Resource'
                          : 'Upload Resource',
                      onPressed: _handleUpload,
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
