import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';

class RatingSection extends StatefulWidget {
  const RatingSection({super.key});

  @override
  State<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<RatingSection> {
  int _selectedStars = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ratings & Reviews',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        const Text('Leave a Review',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
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
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'What did you think of this resource?',
            hintStyle: const TextStyle(color: AppColors.mediumGrey, fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            filled: true,
            fillColor: AppColors.white,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 140,
          child: CustomButton(
            label: 'Submit Review',
            onPressed: () {},
            backgroundColor: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 20),
        _ReviewItem(
          initial: '',
          name: '',
          date: '2023-10-18',
          comment: 'Saved my life on the midterm! Super clear.',
          rating: 5,
          isAnonymous: true,
        ),
        const SizedBox(height: 12),
        _ReviewItem(
          initial: 'M',
          name: 'Mike T.',
          date: '2023-10-20',
          comment: 'Good, but missing some details on sorting algorithms.',
          rating: 4,
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
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!isAnonymous)
                    Text(name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const Spacer(),
                  Row(
                    children: List.generate(
                        5,
                        (i) => Icon(
                              i < rating ? Icons.star : Icons.star_outline,
                              size: 12,
                              color: AppColors.starColor,
                            )),
                  ),
                ],
              ),
              Text(date, style: const TextStyle(fontSize: 11, color: AppColors.mediumGrey)),
              const SizedBox(height: 4),
              Text(comment, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}