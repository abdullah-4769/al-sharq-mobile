import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';

import 'app_text.dart';

class FormLabel extends StatelessWidget {
  final String text;
  final bool isRequired;
  final double fontSize;
  final FontWeight fontWeight;

  const FormLabel({
    super.key,
    required this.text,
    this.isRequired = false,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text:
            text,

              fontSize: fontSize,
              fontWeight: fontWeight,
              color: AppColors.blackColor,

          ),
          if (isRequired) ...[
            const SizedBox(width: 2),
            const Text(
              '*',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
