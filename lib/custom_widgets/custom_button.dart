import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'app_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final bool isLoading;
  final String? imagePath;
  final Color? borderColor;
  final double? borderWidth;
  final Widget? icon; // ✅ new optional icon
  final double? width; // ✅ NEW optional width field

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.isLoading = false,
    this.imagePath,
    this.borderColor,
    this.borderWidth,
    this.icon,
    this.width, // ✅ NEW added here
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 48,
      width: width ?? double.infinity, // ✅ NEW width property
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: borderWidth ?? 1.0)
                : BorderSide.none,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ optional icon takes priority
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ] else if (imagePath != null) ...[
              Image.asset(
                imagePath!,
                height: 20,
                width: 20,
              ),
              const SizedBox(width: 8),
            ],
            AppText(
              text: text,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}