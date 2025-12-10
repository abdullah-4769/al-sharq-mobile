import 'package:flutter/material.dart';
import '../app_colors/app_colors.dart';
import 'app_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final bool isLoading;
  final String? imagePath;
  final Widget? icon;
  final Widget? child; // Custom child for loader or other widgets

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
    this.height,
    this.width,
    this.isLoading = false,
    this.imagePath,
    this.icon,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 48,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: (isLoading || child != null) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: borderWidth ?? 1.0)
                : BorderSide.none,
          ),
          elevation: 0,
          disabledBackgroundColor: backgroundColor?.withOpacity(0.7) ?? AppColors.primaryColor.withOpacity(0.7),
        ),
        child: (isLoading || child != null)
            ? (child ?? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: textColor ?? Colors.white,
            strokeWidth: 2,
          ),
        ))
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Optional icon takes priority
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
              fontSize: fontSize ?? 16,
              fontWeight: fontWeight ?? FontWeight.w600,
              color: textColor ?? Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}