import 'package:flutter/material.dart';

import '../../app_colors/app_colors.dart';
import '../../custom_widgets/app_text.dart';

class QuickAccessItem extends StatefulWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;

  const QuickAccessItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.iconBackgroundColor,
    this.onTap,
  });

  @override
  State<QuickAccessItem> createState() => _QuickAccessItemState();
}

class _QuickAccessItemState extends State<QuickAccessItem> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    Color containerColor = _isSelected ? AppColors.containerGreyColor : AppColors.whiteColor;
    Color titleColor = _isSelected ? AppColors.blackColor : AppColors.blackColor;
    Color subtitleColor = _isSelected ? AppColors.blackColor : AppColors.darkgrey;

    return InkWell(
      onTap: () {
        setState(() {
          _isSelected = true;
        });
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: widget.iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image(image: AssetImage(widget.imagePath)),
            ),
            const SizedBox(height: 12),
            AppText(
              text: widget.title,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
            const SizedBox(height: 4),
            AppText(
              text: widget.subtitle,
              fontSize: 12,
              color: subtitleColor,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}