import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class VerificationCodeField extends StatelessWidget {
  final int length;
  final Function(String) onChanged;
  final Function(String)? onCompleted;

  const VerificationCodeField({
    Key? key,
    this.length = 4,
    required this.onChanged,
    this.onCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 72,
      height: 70,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.blackColor,
      ),
      decoration: BoxDecoration(
        color: Colors.white, // ✅ Default background is white
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Center(
      child: Pinput(
        length: length,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            color: AppColors.lightred, // ✅ Focused box background color
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
        ),
        submittedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            color: Colors.white, // ✅ Submitted box back to white
            border: Border.all(color: AppColors.primaryColor, width: 1.5),
          ),
        ),
        onChanged: onChanged,
        onCompleted: onCompleted,
        keyboardType: TextInputType.number,
        showCursor: true,
      ),
    );
  }
}
