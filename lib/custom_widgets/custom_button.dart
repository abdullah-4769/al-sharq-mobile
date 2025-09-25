import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:flutter/material.dart';

import 'app_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor; // optional
  final Color? textColor; // optional
  final double? height;
  final bool isLoading;
  final String? imagePath; // optional image
  final Color? borderColor; // optional border
  final double? borderWidth; // optional border width

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryColor, // default primaryColor
          foregroundColor: textColor ?? Colors.white, // default white
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
            if (imagePath != null) ...[
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
              color: textColor ?? Colors.white, // default white
            ),
          ],
        ),
      ),
    );
  }
}
