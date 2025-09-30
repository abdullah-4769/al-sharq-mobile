import 'package:flutter/material.dart';

import '../app_colors/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final IconData? suffixIcon;
  final Color? suffixIconColor;
  final bool readOnly;
  final bool obscureText;
  final VoidCallback? onSuffixIconTap; // Added optional parameter

  const CustomTextField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.suffixIconColor,
    this.readOnly = false,
    this.onSuffixIconTap, // Added to constructor
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
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          validator: widget.validator,
          readOnly: widget.readOnly,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.darkgrey,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              fontSize: 16,
              color: AppColors.darkgrey,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryColor,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: widget.suffixIcon != null
                ? IconButton(
              icon: Icon(
                widget.suffixIcon,
                color: widget.suffixIconColor ?? Colors.grey[400],
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText; // Toggle obscureText
                });
                if (widget.onSuffixIconTap != null) {
                  widget.onSuffixIconTap!(); // Call custom callback if provided
                }
              },
            )
                : null,
          ),
        ),
      ],
    );
  }
}