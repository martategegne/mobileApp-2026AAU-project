import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class UploadResource extends StatefulWidget {
  final bool isAdmin;

  const UploadResource({
    super.key,
    required this.isAdmin,
  });

  @override
  State<UploadResource> createState() => _UploadResourceState();
}

class _UploadResourceState extends State<UploadResource> {
  String _selectedFileType = 'PDF';
  String _selectedCategory = 'Lecture Notes';

  final List<String> _fileTypes = ['PDF', 'DOCX', 'PPTX', 'ZIP'];
  final List<String> _categories = [
    'Lecture Notes',
    'Study Guide',
    'Past Exam',
    'Assignment'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
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
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  const Text('Upload Resource',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  const Icon(Icons.notifications_outlined,
                      color: AppColors.textPrimary),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File upload area
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.lightGrey,
                            style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined,
                              size: 36,
                              color: AppColors.primary.withOpacity(0.7)),
                          const SizedBox(height: 8),
                          const Text('Tap to select file',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          const Text('PDF, DOCX, PPTX, or ZIP up to 50MB',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.mediumGrey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Title *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    const CustomTextField(hintText: 'e.g. Midterm Study Guide'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Course Code *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary)),
                              SizedBox(height: 6),
                              CustomTextField(hintText: 'e.g. CS101'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('File Type',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  border:
                                      Border.all(color: AppColors.lightGrey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedFileType,
                                    isExpanded: true,
                                    items: _fileTypes
                                        .map((t) => DropdownMenuItem(
                                            value: t, child: Text(t)))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedFileType = v!),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Category',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items: _categories
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!),
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Description *',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    const CustomTextField(
                      hintText: "Describe what's included in this resource...",
                      maxLines: 4,
                    ),
                    const SizedBox(height: 28),
                    CustomButton(
                      label: 'Upload Resource',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('File uploaded successfully!',
                                style: TextStyle(color: AppColors.success)),
                            backgroundColor: AppColors.white,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        context.go(
                          widget.isAdmin
                              ? '/admin/resources'
                              : '/student/resources',
                        );
                      },
                    ),
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