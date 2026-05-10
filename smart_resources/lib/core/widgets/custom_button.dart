import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        (isOutlined ? Colors.transparent : AppColors.primary);
    final fgColor =
        textColor ?? (isOutlined ? AppColors.primary : AppColors.white);

    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: isOutlined ? 0 : 2,
          side: isOutlined ? const BorderSide(color: AppColors.primary) : null,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          overlayColor: isOutlined
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.primaryDark.withOpacity(0.2),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: fgColor,
                    ),
                  ),
                  if (icon != null) icon!,
                ],
              ),
      ),
    );
  }
}
