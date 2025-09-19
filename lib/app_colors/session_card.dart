import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:al_sharq_conference/images/images.dart';
import 'package:flutter/material.dart';

class SessionCard extends StatelessWidget {
  final String title;
  final String speaker;
  final String speakerRole;
  final String description;
  final String time;
  final String duration;
  final String room;
  final String sessionType;
  final bool isBookmarked;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onViewDetails;

  const SessionCard({
    super.key,
    required this.title,
    required this.speaker,
    required this.speakerRole,
    required this.description,
    required this.time,
    required this.duration,
    required this.room,
    required this.sessionType,
    this.isBookmarked = false,
    this.onBookmarkTap,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    Color sessionTypeColor = sessionType == 'Keynote'
        ? AppColors.lightBlue
        : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and bookmark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
              GestureDetector(
                onTap: onBookmarkTap,
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked
                      ? AppColors.primaryColor
                      : AppColors.darkgrey,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Speaker info
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.darkgrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.whiteColor,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              AppText(
                text: speaker,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              const SizedBox(width: 4),
              AppText(
                text: "+$speakerRole",
                fontSize: 12,
                color: AppColors.primaryColor,
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(),
          AppText(text: description, fontSize: 12, color: AppColors.darkgrey),

          const SizedBox(height: 12),

          // Time and session type
          Row(
            children: [
              Image(image: AssetImage(Images.schedule11), height: 20),
              const SizedBox(width: 4),
              AppText(text: time, fontSize: 12, color: AppColors.darkgrey),
              const SizedBox(width: 16),
              Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sessionTypeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AppText(
                  text: sessionType,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Duration and Room
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              AppText(
                text: 'Duration',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              const SizedBox(width: 60),
              AppText(text: duration, fontSize: 12, color: AppColors.darkgrey),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: 'Room',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              const SizedBox(width: 80),
              AppText(text: room, fontSize: 12, color: AppColors.darkgrey),
            ],
          ),

          const SizedBox(height: 16),

          // View Details Button
          CustomButton(
            text: 'View Details',
            onPressed: onViewDetails ?? () {},
            backgroundColor: AppColors.primaryColor,
            textColor: AppColors.whiteColor,
          ),
        ],
      ),
    );
  }
}
