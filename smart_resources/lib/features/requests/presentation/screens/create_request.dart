import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_resources/core/theme/app_colors.dart';
import 'package:smart_resources/core/widgets/custom_button.dart';
import 'package:smart_resources/core/widgets/custom_text_field.dart';
import 'package:smart_resources/features/auth/presentation/providers/auth_notifier.dart';
import 'package:smart_resources/features/requests/data/models/request_model.dart';
import 'package:smart_resources/features/requests/presentation/providers/request_notifier.dart';

class CreateRequest extends ConsumerStatefulWidget {
  final bool isAdmin;
  final RequestModel? requestToEdit;

  const CreateRequest({
    super.key,
    required this.isAdmin,
    this.requestToEdit,
  });

  @override
  ConsumerState<CreateRequest> createState() => _CreateRequestState();
}

class _CreateRequestState extends ConsumerState<CreateRequest> {
  late TextEditingController _titleController;
  late TextEditingController _courseCodeController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.requestToEdit?.title ?? '');
    _courseCodeController = TextEditingController(text: widget.requestToEdit?.courseCode ?? '');
    _descriptionController = TextEditingController(text: widget.requestToEdit?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final courseCode = _courseCodeController.text.trim();
    final description = _descriptionController.text.trim();
    final user = ref.read(authNotifierProvider).user;

    if (title.isEmpty || courseCode.isEmpty || description.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (widget.requestToEdit != null) {
      final updatedRequest = widget.requestToEdit!.copyWith(
        title: title,
        courseCode: courseCode,
        description: description,
      );
      try {
        await ref.read(requestNotifierProvider.notifier).updateRequest(updatedRequest);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go(widget.isAdmin ? '/admin/requests' : '/student/requests');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    } else {
      final request = RequestModel(
        id: 'req-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        courseCode: courseCode,
        requestedBy: user?.name ?? 'Anonymous',
        time: 'Just now',
        status: 'open',
      );

      try {
        await ref.read(requestNotifierProvider.notifier).createRequest(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your request has been submitted!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go(widget.isAdmin ? '/admin/requests' : '/student/requests');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add request: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestsState = ref.watch(requestNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(
                      widget.isAdmin ? '/admin/requests' : '/student/requests',
                    ),
                    child: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.requestToEdit != null ? 'Edit Request' : 'Resource Requests',
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.requestToEdit != null ? 'Update Details' : 'New Request',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            hintText: 'Request Title',
                            controller: _titleController,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            hintText: 'Course Code (e.g. CS101)',
                            controller: _courseCodeController,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            hintText: 'What exactly are you looking for?',
                            maxLines: 3,
                            controller: _descriptionController,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  label: widget.requestToEdit != null ? 'Update' : 'Submit',
                                  onPressed: _handleSubmit,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  label: 'Cancel',
                                  isOutlined: true,
                                  onPressed: () => context.go(
                                    widget.isAdmin ? '/admin/requests' : '/student/requests',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.requestToEdit == null) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Community Requests',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      requestsState.when(
                        data: (requests) {
                          final openRequests = requests.where((r) => r.status == 'open').toList();
                          if (openRequests.isEmpty) {
                            return const Center(child: Text('No community requests yet.'));
                          }
                          return Column(
                            children: openRequests
                                .map((r) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _CommunityRequestCard(
                                        courseCode: r.courseCode,
                                        title: r.title,
                                        description: r.description,
                                        requestedBy: r.requestedBy,
                                        onMarkFulfilled: widget.isAdmin
                                            ? () => ref
                                                .read(requestNotifierProvider.notifier)
                                                .fulfillRequest(r.id)
                                            : null,
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Text('Error: $err'),
                      ),
                    ],
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

class _CommunityRequestCard extends StatelessWidget {
  final String courseCode;
  final String title;
  final String description;
  final String requestedBy;
  final VoidCallback? onMarkFulfilled;

  const _CommunityRequestCard({
    required this.courseCode,
    required this.title,
    required this.description,
    required this.requestedBy,
    this.onMarkFulfilled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(courseCode,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
          const SizedBox(height: 8),
          Text(title,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(description,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.65), height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Requested by  ',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5))),
              Text(requestedBy,
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
              const Spacer(),
              if (onMarkFulfilled != null)
                GestureDetector(
                  onTap: onMarkFulfilled,
                  child: const Text('Mark Fulfilled',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
