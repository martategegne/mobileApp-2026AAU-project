import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_resources/core/theme/app_colors.dart';
import 'package:smart_resources/core/widgets/custom_button.dart';
import 'package:smart_resources/features/auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/review.dart';
import '../providers/resource_notifier.dart';

class RatingSection extends ConsumerStatefulWidget {
  final String resourceId;
  const RatingSection({super.key, required this.resourceId});

  @override
  ConsumerState<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends ConsumerState<RatingSection> {
  int _selectedStars = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a review')),
      );
      return;
    }

    if (_selectedStars == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }

    final review = Review(
      id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
      resourceId: widget.resourceId,
      userId: user.id,
      userName: user.name,
      rating: _selectedStars.toDouble(),
      comment: _commentController.text.trim(),
      time: DateTime.now().toString().split(' ')[0],
    );

    try {
      await ref.read(resourceNotifierProvider.notifier).addReview(review);
      if (mounted) {
        setState(() {
          _selectedStars = 0;
          _commentController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(resourceReviewsProvider(widget.resourceId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ratings & Reviews',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Text('Leave a Review',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        // Star selector
        Row(
          children: List.generate(5, (i) {
            return GestureDetector(
              onTap: () => setState(() => _selectedStars = i + 1),
              child: Icon(
                i < _selectedStars ? Icons.star : Icons.star_outline,
                color: AppColors.starColor,
                size: 28,
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        // Review text field - theme aware
        TextField(
          controller: _commentController,
          maxLines: 3,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'What did you think of this resource?',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.45),
              fontSize: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            filled: true,
            fillColor: theme.cardColor,
          ),
        ),
        const SizedBox(height: 14),
        CustomButton(
          label: 'Submit Review',
          onPressed: _submitReview,
          backgroundColor: AppColors.darkGrey,
          width: 150,
        ),
        const SizedBox(height: 24),
        reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return Text(
                'No reviews yet. Be the first to review!',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ReviewItem(
                    initial: review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : '?',
                    name: review.userName,
                    date: review.time,
                    comment: review.comment,
                    rating: review.rating.toInt(),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error loading reviews: $err'),
        ),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String initial;
  final String name;
  final String date;
  final String comment;
  final int rating;
  final bool isAnonymous;

  const _ReviewItem({
    required this.initial,
    required this.name,
    required this.date,
    required this.comment,
    required this.rating,
    this.isAnonymous = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withOpacity(0.15),
          child: isAnonymous
              ? const Icon(Icons.person_outline, size: 16, color: AppColors.primary)
              : Text(initial,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!isAnonymous)
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < rating ? Icons.star : Icons.star_outline,
                        size: 12,
                        color: AppColors.starColor,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                date,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              if (comment.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.75),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
