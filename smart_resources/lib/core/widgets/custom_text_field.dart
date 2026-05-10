import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int maxLines;
  final String? label;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            hintStyle: const TextStyle(color: AppColors.mediumGrey, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
