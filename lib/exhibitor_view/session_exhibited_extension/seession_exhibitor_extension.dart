import 'package:flutter/material.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import 'package:al_sharq_conference/custom_widgets/app_text.dart';
import 'package:al_sharq_conference/custom_widgets/custom_button.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../images/images.dart';
import '../exhibitor_venue_details/exhibitor_venue_detail.dart';

class SessionsExhibitedExtensionScreen extends StatelessWidget {
  const SessionsExhibitedExtensionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const AppText(
          text: 'Sessions & Events',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(),
            SizedBox(height: 24.h),

            // Sessions List
            _buildSessionsSection(),
            SizedBox(height: 32.h),

            // Follow Us Section
            _buildFollowUsSection(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.lightGrey.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.event, color: Colors.white, size: 20.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppText(
                  text: 'Featured Sessions',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          AppText(
            text: 'Discover engaging sessions and connect with industry leaders',
            fontSize: 12.sp,
            color: AppColors.darkgrey,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: 'Upcoming Sessions',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: AppText(
                text: '2 Sessions',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Session Card 1 - Digital Transformation
        _buildEnhancedSessionCard(
          title: 'Digital Transformation in MENA',
          speaker: 'Dr. Sarah Hassan',
          speakerRole: 'Digital Innovation Director',
          time: '2:00 PM - 3:00 PM',
          duration: '90 minutes',
          room: 'Hall B',
          sessionType: 'Keynote',
          sessionTypeColor: Colors.blue,
          description: 'Exploring the role of diplomacy and collaboration in shaping future policies across the MENA region through digital innovation.',
          speakerImage: "", // Add your image path
          isBookmarked: false,
        ),

        SizedBox(height: 16.h),

        // Session Card 2 - Regional Cooperation
        _buildEnhancedSessionCard(
          title: 'The Future of Regional Cooperation',
          speaker: 'Prof. Omar Khalil',
          speakerRole: 'International Relations Expert',
          time: '10:00 AM - 11:30 AM',
          duration: '90 minutes',
          room: 'Hall B',
          sessionType: 'Panel Discussion',
          sessionTypeColor: Colors.orange,
          description: 'Exploring the role of diplomacy and collaboration in shaping future policies and economic partnerships.',
          speakerImage: "", // Add your image path
          isBookmarked: true,
        ),
      ],
    );
  }

  Widget _buildEnhancedSessionCard({
    required String title,
    required String speaker,
    required String speakerRole,
    required String time,
    required String duration,
    required String room,
    required String sessionType,
    required Color sessionTypeColor,
    required String description,
    required String speakerImage,
    required bool isBookmarked,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.lightGreyColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Session Type and Bookmark
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: sessionTypeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: sessionTypeColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8.w, color: sessionTypeColor),
                    SizedBox(width: 6.w),
                    AppText(
                      text: sessionType,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: sessionTypeColor,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle bookmark functionality
                },
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? AppColors.primaryColor : AppColors.mediumGreyColor,
                  size: 22.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Session Title
          AppText(
            text: title,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12.h),

          // Speaker Info with Image
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 1.5),
                  image: DecorationImage(
                    image: AssetImage(speakerImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: speaker,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    AppText(
                      text: speakerRole,
                      fontSize: 12.sp,
                      color: AppColors.darkgrey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Description
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: AppText(
              text: description,
              fontSize: 12.sp,
              color: AppColors.darkgrey,
              // lineHeight: 1.4,
            ),
          ),
          SizedBox(height: 16.h),

          // Session Details Grid
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(
                  icon: Icons.access_time,
                  title: 'Time',
                  value: time,
                ),
                _buildDetailItem(
                  icon: Icons.timer,
                  title: 'Duration',
                  value: duration,
                ),
                _buildDetailItem(
                  icon: Icons.location_on,
                  title: 'Room',
                  value: room,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 40,
                  child: CustomButton(
                    text: 'Add to Agenda',
                    onPressed: () {
                      // Add to agenda functionality
                    },
                    backgroundColor: Colors.transparent,
                    textColor: AppColors.primaryColor,
                    height: 44.h,
                    borderColor: AppColors.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 12.w),

            ],
          ),
          SizedBox(height: 10.h,),
          CustomButton(
            text: 'View Details',
            onPressed: () {
              Get.to(() => ExhibitorVenueDetails());
            },
            backgroundColor: AppColors.primaryColor,
            height: 44.h,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18.w, color: AppColors.primaryColor),
        SizedBox(height: 4.h),
        AppText(
          text: title,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.darkgrey,
        ),
        SizedBox(height: 2.h),
        AppText(
          text: value,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFollowUsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withOpacity(0.05),
            AppColors.lightGrey.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGreyColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_alt, color: AppColors.primaryColor, size: 20.w),
              SizedBox(width: 8.w),
              AppText(
                text: 'Stay Connected',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          AppText(
            text: 'Follow us on social media for updates and insights',
            fontSize: 12.sp,
            color: AppColors.darkgrey,
          ),
          SizedBox(height: 16.h),

          // Social Media Buttons
          Column(
            children: [
              CustomButton(
                imagePath: Images.linkedin2,
                text: 'Follow on LinkedIn',
                onPressed: () {},
                backgroundColor: AppColors.darkBlue,
                height: 48.h,
                // borderRadius: 12.r,
                // iconSize: 20.w,
              ),
              SizedBox(height: 12.h),
              CustomButton(
                imagePath: Images.twitterIcon,
                text: 'Follow on Twitter',
                onPressed: () {},
                backgroundColor: AppColors.lightBlue,
                height: 48.h,
                // borderRadius: 12.r,
                // iconSize: 20.w,
              ),
              SizedBox(height: 12.h),
              CustomButton(
                imagePath: Images.youtube,
                text: 'Subscribe on YouTube',
                onPressed: () {},
                backgroundColor: AppColors.primaryColor,
                height: 48.h,
                // borderRadius: 12.r,
                // iconSize: 20.w,
              ),
            ],
          ),
        ],
      ),
    );
  }
}