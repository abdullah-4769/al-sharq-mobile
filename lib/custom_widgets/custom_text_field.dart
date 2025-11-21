import 'package:flutter/material.dart';
import '../app_colors/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted; // Added onSubmitted parameter
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? suffixIcon;
  final Color? suffixIconColor;
  final bool readOnly;
  final bool obscureText;
  final VoidCallback? onSuffixIconTap;
  final bool enabled;
  final IconData? prefixIcon;
  final int? maxLines;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted, // Added to constructor
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.suffixIconColor,
    this.readOnly = false,
    this.onSuffixIconTap,
    this.enabled = true,
    this.prefixIcon,
    this.maxLines,
    this.onTap,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted, // Use onFieldSubmitted for TextFormField
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          validator: widget.validator,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          onTap: widget.onTap,
          // FIX: Set maxLines to 1 when obscureText is true, otherwise use provided maxLines or 4 for error display
          maxLines: _obscureText ? 1 : (widget.maxLines ?? 1),
          minLines: 1,
          style: TextStyle(
            fontSize: 16,
            color: widget.enabled ? AppColors.darkgrey : Colors.grey[400],
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontSize: 16,
              color: widget.enabled ? AppColors.darkgrey : Colors.grey[400],
            ),
            filled: true,
            fillColor: widget.enabled ? Colors.grey[50] : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.enabled ? Colors.grey[300]! : Colors.grey[400]!,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
              widget.prefixIcon,
              color: widget.enabled ? AppColors.darkgrey : Colors.grey[400],
              size: 20,
            )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? IconButton(
              icon: Icon(
                widget.suffixIcon,
                color: widget.enabled
                    ? (widget.suffixIconColor ?? Colors.grey[400])
                    : Colors.grey[400],
                size: 20,
              ),
              onPressed: widget.enabled
                  ? () {
                setState(() {
                  _obscureText = !_obscureText;
                });
                if (widget.onSuffixIconTap != null) {
                  widget.onSuffixIconTap!();
                }
              }
                  : null,
            )
                : null,
            errorMaxLines: 6, // Allow error messages to show up to 4 lines
          ),
        ),
      ],
    );
  }
}